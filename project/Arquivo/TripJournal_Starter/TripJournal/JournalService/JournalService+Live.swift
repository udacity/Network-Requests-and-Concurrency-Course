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
    case accept = "accept"
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
    case invalidValue
}

/// An unimplemented version of the `JournalService`.
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
        case trips
        case handleTrip(String)
        case event
        case events(String)
        case postMedia
        case deleteMedia(String)
        
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
            case .event:
                return EndPoints.base + "events"
            case .events(let eventId):
                return EndPoints.base + "events/\(eventId)"
            case .postMedia:
                return EndPoints.base + "media"
            case .deleteMedia(let mediaId):
                return EndPoints.base + "media/\(mediaId)"
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
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        do {
            request.httpBody = try JSONEncoder().encode(registerRequest)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response format.")
                throw NetworkError.badResponse
            }
            
            print("HTTP Status Code:", httpResponse.statusCode)
            print("Response Body:", String(data: data, encoding: .utf8) ?? "Unable to convert data to text.")
            
            do {
                let token = try JSONDecoder().decode(Token.self, from: data)
                self.token = token
                return token
            } catch {
                print("Failed to decode response:", error)
                throw NetworkError.failedToDecodeResponse
            }
        } catch {
            print("Error configuring the request:", error)
            throw NetworkError.badResponse
        }
    }
    
    func logOut() {
        token = nil
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
                print("Invalid response format.")
                throw NetworkError.badResponse
            }
            
            print("HTTP Status Code:", httpResponse.statusCode)
            print("Response Body:", String(data: data, encoding: .utf8) ?? "Unable to convert data to text.")
            
            guard httpResponse.statusCode == 200 else {
                print("Invalid HTTP status code.")
                throw NetworkError.badResponse
            }
            
            do {
                let token = try JSONDecoder().decode(Token.self, from: data)
                self.token = token
                return token
            } catch {
                print("Failed to decode response:", error)
                throw NetworkError.failedToDecodeResponse
            }
        } catch {
            print("Error configuring the request:", error)
            throw NetworkError.badResponse
        }
    }
    
    func createTrip(with request: TripCreate) async throws -> Trip {
        guard let url = EndPoints.trips.url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
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
        guard let url = EndPoints.trips.url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
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
    
    func getTrip(withId tripId: Trip.ID) async throws -> Trip {
        guard let url = EndPoints.handleTrip(tripId.description).url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
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
            return try decoder.decode(Trip.self, from: data)
        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }
    
    func updateTrip(withId tripId: Trip.ID, and request: TripUpdate) async throws -> Trip {
        guard let url = EndPoints.handleTrip(tripId.description).url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
        requestURL.httpMethod = HTTPMethods.PUT.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        do {
            requestURL.httpBody = try JSONSerialization.data(withJSONObject: request)
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
    
    func deleteTrip(withId tripId: Trip.ID) async throws {
        guard let url = EndPoints.handleTrip(tripId.description).url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
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
    
    func createEvent(with request: EventCreate) async throws -> Event {
        guard let url = EndPoints.event.url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
        requestURL.httpMethod = HTTPMethods.POST.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            requestURL.httpBody = try encoder.encode(request)
            
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
            return try decoder.decode(Event.self, from: data)
        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }
    
    func updateEvent(withId eventId: Event.ID, and request: EventUpdate) async throws -> Event {
        guard let url = EndPoints.events(eventId.description).url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
        requestURL.httpMethod = HTTPMethods.PUT.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            requestURL.httpBody = try encoder.encode(request)
            
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
            return try decoder.decode(Event.self, from: data)
        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }
    
    func deleteEvent(withId eventId: Event.ID) async throws {
        guard let url = EndPoints.events(eventId.description).url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
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
    
    @discardableResult
    func createMedia(with request: MediaCreate) async throws -> Media {
        guard let url = EndPoints.postMedia.url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: url)
        
        requestURL.httpMethod = HTTPMethods.POST.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            requestURL.httpBody = try encoder.encode(request)
            
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
            return try decoder.decode(Media.self, from: data)
        } catch {
            print("Error configuring the request or processing the response:", error)
            throw NetworkError.badResponse
        }
    }
    
    func deleteMedia(withId mediaId: Media.ID) async throws {
        guard let url = EndPoints.deleteMedia(mediaId.description).url else {
            throw NetworkError.badUrl
        }
        
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
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
