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
    case invalidValue
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
    var tokenExpired: Bool = false

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
        case trips
        case handleTrip(String)

        private var stringValue: String {
            switch self {
            case .register:
                return EndPoints.base + "register"
            case .login:
                return EndPoints.base + "token"
            case .trips:
                return EndPoints.base + "trips"
            case .handleTrip(let tripId):
                return EndPoints.base + "trips/\(tripId)"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    init() {
        if let savedToken = try? KeychainHelper.shared.getToken() {
            if !isTokenExpired(savedToken) {
                self.token = savedToken
            } else {
                self.tokenExpired = true
                self.token = nil
            }
        } else {
            self.token = nil
        }
    }

    func register(username: String, password: String) async throws -> Token {
        let request = try createRegisterRequest(username: username, password: password)
        return try await performNetworkRequest(request)
    }

    func logIn(username: String, password: String) async throws -> Token {
        let request = try createLoginRequest(username: username, password: password)
        return try await performNetworkRequest(request)
    }

    private func createRegisterRequest(username: String, password: String) throws -> URLRequest {
        var request = URLRequest(url: EndPoints.register.url)
        request.httpMethod = HTTPMethods.POST.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)

        let registerRequest = LoginRequest(username: username, password: password)
        request.httpBody = try JSONEncoder().encode(registerRequest)

        return request
    }

    private func createLoginRequest(username: String, password: String) throws -> URLRequest {
        var request = URLRequest(url: EndPoints.login.url)
        request.httpMethod = HTTPMethods.POST.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.form.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)

        let loginData = "grant_type=&username=\(username)&password=\(password)"
        request.httpBody = loginData.data(using: .utf8)

        return request
    }

    private func performNetworkRequest(_ request: URLRequest) async throws -> Token {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }

        do {
            var token = try JSONDecoder().decode(Token.self, from: data)
            token.expirationDate = Token.defaultExpirationDate()
            self.token = token
            return token
        } catch {
            throw NetworkError.failedToDecodeResponse
        }
    }

    func logOut() {
        token = nil
    }

    func checkIfTokenExpired() {
        if let currentToken = token,
           isTokenExpired(currentToken) {
            tokenExpired = true
            token = nil
        }
    }

    private func isTokenExpired(_ token: Token) -> Bool {
        guard let expirationDate = token.expirationDate else {
            return false
        }
        return expirationDate <= Date()
    }

    func createTrip(with request: TripCreate) async throws -> Trip {
        guard let token = token else {
            throw NetworkError.invalidValue
        }

        var requestURL = URLRequest(url: EndPoints.trips.url)

        requestURL.httpMethod = HTTPMethods.POST.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        let tripData: [String: Any] = [
            "name": request.name,
            "start_date": dateFormatter.string(from: request.startDate),
            "end_date": dateFormatter.string(from: request.endDate)
        ]

        do {
            requestURL.httpBody = try JSONSerialization.data(withJSONObject: tripData)

            let (data, response) = try await URLSession.shared.data(for: requestURL)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response format.")
                throw NetworkError.badResponse
            }

            print("HTTP Status Code:", httpResponse.statusCode)
            print("Response Body:", String(data: data, encoding: .utf8) ?? "Unable to convert data to text.")

            print("Request URL:", requestURL)
            print("Request Headers:", requestURL.allHTTPHeaderFields ?? [:])
            print("Request Body:", String(data: requestURL.httpBody ?? Data(), encoding: .utf8) ?? "No request body")

            guard httpResponse.statusCode == 200 else {
                print("Invalid HTTP status code.")
                throw NetworkError.badResponse
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Trip.self, from: data)

        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }

    func getTrips() async throws -> [Trip] {
        guard let token = token else {
            throw NetworkError.invalidValue
        }

        var requestURL = URLRequest(url: EndPoints.trips.url)

        requestURL.httpMethod = HTTPMethods.GET.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)

        do {
            let (data, response) = try await URLSession.shared.data(for: requestURL)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response format.")
                throw NetworkError.badResponse
            }

            print("HTTP Status Code:", httpResponse.statusCode)
            print("Response Body:", String(data: data, encoding: .utf8) ?? "Unable to convert data to text.")

            print("Request URL:", requestURL)
            print("Request Headers:", requestURL.allHTTPHeaderFields ?? [:])
            print("Request Body:", String(data: requestURL.httpBody ?? Data(), encoding: .utf8) ?? "No request body")

            guard httpResponse.statusCode == 200 else {
                print("Invalid HTTP status code.")
                throw NetworkError.badResponse
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Trip].self, from: data)
        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }

    func deleteTrip(withId tripId: Trip.ID) async throws {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        let url = EndPoints.handleTrip(tripId.description).url
        var requestURL = URLRequest(url: url)

        requestURL.httpMethod = HTTPMethods.DELETE.rawValue
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)

        do {
            let (data, response) = try await URLSession.shared.data(for: requestURL)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response format.")
                throw NetworkError.badResponse
            }

            print("HTTP Status Code:", httpResponse.statusCode)
            print("Response Body:", String(data: data, encoding: .utf8) ?? "Unable to convert data to text.")

            print("Request URL:", requestURL)
            print("Request Headers:", requestURL.allHTTPHeaderFields ?? [:])
            print("Request Body:", String(data: requestURL.httpBody ?? Data(), encoding: .utf8) ?? "No request body")

            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                print("Invalid HTTP status code.")
                throw NetworkError.badResponse
            }
        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }
}
