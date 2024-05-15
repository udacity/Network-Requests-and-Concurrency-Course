import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    // Define serviceName property with the value "com.TripJournal.service"
    // Define accountName property with the value "authToken"

    private init() {}

    func saveToken(_ token: Token) throws {
        // Encode the token to tokenData using JSONEncoder

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Delete any existing item matching the query
        // Use SecItemDelete for query as CFDictionary
        
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unableToSaveToken
        }
    }

    func getToken() throws -> Token? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess else {
            return nil
        }

        guard let data = dataTypeRef as? Data else {
            return nil
        }

        // return the decoded the token data to a Token object using JSONDecoder
    }

    func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            // Throw KeychainError.unableToDeleteToken if deletion fails
        }
    }

    enum KeychainError: Error {
        case unableToSaveToken
        // Define the case unableToDeleteToken for deletion errors
    }
}
