import Combine
import Foundation

enum HTTPMethods: String {
    case POST, GET, PUT, DELETE
}

enum MIMEType: String {
    case JSON = "application/json"
    case form = "application/x-www-form-urlencoded"
}

enum HTTPHeaders: String {
    case accept
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum NetworkError: Error {
    case badUrl
    case badResponse
    case failedToDecodeResponse
}

enum SessionError: Error {
    case expired
}

extension SessionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .expired:
            return "Your session has expired. Please log in again."
        }
    }
}

class JournalServiceLive: JournalService {
    // TODO: Add a property to track whether the user's token has expired, tokenExpired

    @Published private var token: Token? {
        didSet {
            if let token = token {
                try? KeychainHelper.shared.saveToken(token)
            } else {
                try? KeychainHelper.shared.deleteToken()
            }
        }
    }

    var isAuthenticated: AnyPublisher<Bool, Never> {
        $token
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    enum EndPoints {
        static let base = "http://localhost:8000/"

        case register
        case login

        private var stringValue: String {
            switch self {
            case .register:
                return EndPoints.base + "register"
            case .login:
                return EndPoints.base + "token"
            }
        }

        var url: URL? {
            return URL(string: stringValue)
        }
    }

    init() {
        if let savedToken = try? KeychainHelper.shared.getToken() {
            if !isTokenExpired(savedToken) {
                self.token = savedToken
            } else {
                // TODO: set tokenExpired to true
                self.token = nil
            }
        } else {
            self.token = nil
        }
    }

    func register(username: String, password: String) async throws -> Token {
        guard let url = EndPoints.register.url else {
            throw NetworkError.badUrl
        }

        let registerRequest = LoginRequest(username: username, password: password)

        var request = URLRequest(url: url)

        request.httpMethod = HTTPMethods.POST.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)

        do {
            request.httpBody = try JSONEncoder().encode(registerRequest)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.badResponse
            }

            do {
                var token = try JSONDecoder().decode(Token.self, from: data)
                // TODO: Set the token's expiration date after decoding to Token.defaultExpirationDate()
                self.token = token
                return token
            } catch {
                throw NetworkError.failedToDecodeResponse
            }
        } catch {
            throw NetworkError.badResponse
        }
    }

    func logIn(username: String, password: String) async throws -> Token {
        guard let url = EndPoints.login.url else {
            throw NetworkError.badUrl
        }

        var request = URLRequest(url: url)

        request.httpMethod = HTTPMethods.POST.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.form.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)

        let loginData = "grant_type=&username=\(username)&password=\(password)"
        request.httpBody = loginData.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw NetworkError.badResponse
            }

            do {
                var token = try JSONDecoder().decode(Token.self, from: data)
                // TODO: Set the token's expiration date after decoding to Token.defaultExpirationDate()
                self.token = token
                return token
            } catch {
                throw NetworkError.failedToDecodeResponse
            }
        } catch {
            throw NetworkError.badResponse
        }
    }

    func logOut() {
        token = nil
    }

    func checkIfTokenExpired() {
        // TODO: Check if the token is expired and update tokenExpired and token accordingly
    }

    private func isTokenExpired(_ token: Token) -> Bool {
        guard let expirationDate = token.expirationDate else {
            return false
        }
        return expirationDate <= Date()
    }
}
