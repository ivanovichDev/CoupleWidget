type Environment = "sandbox" | "production";

type Recipient = {
  token: string;
  kind: "alert" | "widget";
  environment: Environment;
};

type Note = {
  author_name: string;
  text: string;
  updated_at: number;
};

type NotificationRequest = {
  recipients: Recipient[];
  note: Note;
};

const apnsHosts: Record<Environment, string> = {
  sandbox: "https://api.sandbox.push.apple.com",
  production: "https://api.push.apple.com",
};

const providerTokenLifetimeSeconds = 50 * 60;
const widgetPushDelayMilliseconds = 1000;

let providerToken: { value: string; issuedAt: number } | undefined;

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`${name} is not set`);
  }
  return value;
}

function isAuthorized(request: Request): boolean {
  const expected = new TextEncoder().encode(requiredEnv("NOTE_PUSH_SECRET"));
  const received = new TextEncoder().encode(request.headers.get("X-Note-Push-Secret") ?? "");
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
  return { token: recipient.token, kind: recipient.kind, status: response.status, reason };
}

function sendAlert(recipient: Recipient, note: Note, token: string) {
  return post(recipient, token, {
    "apns-topic": requiredEnv("APNS_TOPIC"),
    "apns-push-type": "alert",
    "apns-priority": "10",
  }, {
    aps: {
      alert: { title: note.author_name, body: note.text },
      sound: "default",
      "mutable-content": 1,
    },
    note: { author_name: note.author_name, updated_at: note.updated_at },
  });
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

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return new Response(null, { status: 405 });
  }
  if (!isAuthorized(request)) {
    return new Response(null, { status: 401 });
  }
  const { recipients, note } = await request.json() as NotificationRequest;
  const token = await currentProviderToken();
  const alertRecipients = recipients.filter((recipient) => recipient.kind === "alert");
  const widgetRecipients = recipients.filter((recipient) => recipient.kind === "widget");
  const alertResults = await Promise.all(alertRecipients.map((recipient) => sendAlert(recipient, note, token)));
  if (widgetRecipients.length > 0) {
    await new Promise((resolve) => setTimeout(resolve, widgetPushDelayMilliseconds));
  }
  const widgetResults = await Promise.all(widgetRecipients.map((recipient) => sendWidgetReload(recipient, token)));
  return Response.json({ results: [...alertResults, ...widgetResults] });
});
