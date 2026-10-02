type Environment = "sandbox" | "production";

type Recipient = {
  token: string;
  environment: Environment;
};

type ReloadRequest = {
  recipients: Recipient[];
};

const apnsHosts: Record<Environment, string> = {
  sandbox: "https://api.sandbox.push.apple.com",
  production: "https://api.push.apple.com",
};

const providerTokenLifetimeSeconds = 50 * 60;

let providerToken: { value: string; issuedAt: number } | undefined;

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`${name} is not set`);
  }
  return value;
}

function isAuthorized(request: Request): boolean {
  const expected = new TextEncoder().encode(requiredEnv("SEND_WIDGET_PUSH_SECRET"));
  const received = new TextEncoder().encode(request.headers.get("X-Send-Widget-Push-Secret") ?? "");
  if (expected.length !== received.length) {
    return false;
  }
  let difference = 0;
  for (let index = 0; index < expected.length; index++) {
    difference |= expected[index] ^ received[index];
  }
  return difference === 0;
}

function base64Url(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}

function base64UrlJSON(value: unknown): string {
  return base64Url(new TextEncoder().encode(JSON.stringify(value)));
}

async function signingKey(): Promise<CryptoKey> {
  const pem = atob(requiredEnv("APNS_PRIVATE_KEY_BASE64"));
  const body = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const der = Uint8Array.from(atob(body), (character) => character.charCodeAt(0));
  return await crypto.subtle.importKey("pkcs8", der, { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"]);
}

async function currentProviderToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (providerToken && now - providerToken.issuedAt < providerTokenLifetimeSeconds) {
    return providerToken.value;
  }
  const header = base64UrlJSON({ alg: "ES256", kid: requiredEnv("APNS_KEY_ID") });
  const claims = base64UrlJSON({ iss: requiredEnv("APNS_TEAM_ID"), iat: now });
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    await signingKey(),
    new TextEncoder().encode(`${header}.${claims}`),
  );
  const value = `${header}.${claims}.${base64Url(new Uint8Array(signature))}`;
  providerToken = { value, issuedAt: now };
  return value;
}

async function post(recipient: Recipient, token: string, headers: Record<string, string>, payload: unknown) {
  const response = await fetch(`${apnsHosts[recipient.environment]}/3/device/${recipient.token}`, {
    method: "POST",
    headers: {
      "authorization": `bearer ${token}`,
      "content-type": "application/json",
      ...headers,
    },
    body: JSON.stringify(payload),
  });
  const reason = response.ok ? undefined : (await response.json().catch(() => undefined))?.reason;
  return { token: recipient.token, status: response.status, reason };
}

function sendWidgetReload(recipient: Recipient, token: string) {
  return post(recipient, token, {
    "apns-topic": `${requiredEnv("APNS_TOPIC")}.push-type.widgets`,
    "apns-push-type": "widgets",
    "apns-priority": "10",
  }, {
    aps: { "content-changed": true },
  });
}

function isDeadToken(result: { status: number; reason?: string }): boolean {
  return result.status === 410 || result.reason === "BadDeviceToken";
}

async function clearToken(token: string) {
  await fetch(`${requiredEnv("SUPABASE_URL")}/rest/v1/rpc/clear_push_token`, {
    method: "POST",
    headers: {
      "apikey": requiredEnv("SUPABASE_ANON_KEY"),
      "content-type": "application/json",
    },
    body: JSON.stringify({ widget_token: token, push_secret: requiredEnv("SEND_WIDGET_PUSH_SECRET") }),
  });
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return new Response(null, { status: 405 });
  }
  if (!isAuthorized(request)) {
    return new Response(null, { status: 401 });
  }
  const { recipients } = await request.json() as ReloadRequest;
  const token = await currentProviderToken();
  const results = await Promise.all(recipients.map((recipient) => sendWidgetReload(recipient, token)));
  await Promise.all(results.filter(isDeadToken).map((result) => clearToken(result.token)));
  return Response.json({ results });
});
