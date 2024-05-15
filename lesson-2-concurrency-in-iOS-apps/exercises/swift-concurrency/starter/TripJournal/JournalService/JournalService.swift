import Combine
import Foundation

/// The journal service is used to perform networking operations in the app.
protocol JournalService {
    /// A publisher that can be observed to indicate whether the user is authenticated or not.
    var isAuthenticated: AnyPublisher<Bool, Never> { get }

    /// Indicates whether the user's token has expired.
    var tokenExpired: Bool { get }

    /// Create a new account.
    /// - Parameters:
    ///   - username: Username.
    ///   - password: Password.
    /// - Returns: A token that can be used to interact with the API.
    @discardableResult
    func register(username: String, password: String) async throws -> Token

    /// Login to an existing account.
    /// - Parameters:
    ///   - username: Username.
    ///   - password: Password.
    /// - Returns: A token that can be used to interact with the API.
    @discardableResult
    func logIn(username: String, password: String) async throws -> Token

    /// Log-outs the user, by deleting the token and updating the isAuthenticated publisher.
    func logOut()

    /// Checks if the user's token has expired.
    func checkIfTokenExpired()
}
