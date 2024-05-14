import Combine
import Foundation

enum HTTPMethods: String {
    case POST
}

enum MIMEType: String {
    case JSON = "application/json"
    case form = "application/x-www-form-urlencoded"
}

enum HTTPHeaders: String {
    case accept
    case contentType = "Content-Type"
}

enum NetworkError: Error {
    case badUrl
    case badResponse
    case failedToDecodeResponse
}

class JournalServiceLive: JournalService {
    @Published private var token: Token?

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

    func register(username: String, password: String) async throws -> Token {
        guard let url = EndPoints.register.url else {
            throw NetworkError.badUrl
        }

        let registerRequest = LoginRequest(username: username, password: password)

        var request = URLRequest(url: url)

        request.httpMethod = HTTPMethods.POST.rawValue

        // Add necessary HTTP headers

        do {
            request.httpBody = try JSONEncoder().encode(registerRequest)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // Throw NetworkError badResponse
            }

            do {
                // Decode token from response data and asint to token property
            } catch {
                // Throw failedToDecodeResponse NetworkError
            }
        } catch {
            // Throw badResponse NetworkError
        }
    }

    func logIn(username: String, password: String) async throws -> Token {
        guard let url = EndPoints.login.url else {
            throw NetworkError.badUrl
        }

        var request = URLRequest(url: url)

        request.httpMethod = HTTPMethods.POST.rawValue

        // Add necessary HTTP headers

        let loginData = "grant_type=&username=\(username)&password=\(password)"
        request.httpBody = loginData.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                // Throw NetworkError badResponse
            }

            guard httpResponse.statusCode == 200 else {
                // Throw badResponse NetworkError
            }

            do {
                // Decode token from response data and asignt to token variable and return token
            } catch {
                // Throw failedToDecodeResponse NetworkError
            }
        } catch {
            // Throw badResponse NetworkError
        }
    }

    func logOut() {
        token = nil
    }
}
