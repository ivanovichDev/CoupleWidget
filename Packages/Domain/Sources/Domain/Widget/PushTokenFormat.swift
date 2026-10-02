import Foundation

public enum PushTokenFormat {
    public static func hexString(from token: Data) -> String {
        token.map { String(format: "%02x", $0) }.joined()
    }
}
