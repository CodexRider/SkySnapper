import Foundation

// MARK: - Weather Response Models
struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let name: String
    let coord: Coordinates
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

// MARK: - Error Response Model
struct WeatherErrorResponse: Codable {
    let message: String
}

// MARK: - Error Types
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case locationError(Error)
    case locationPermissionDenied
    case locationServicesDisabled
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return message
        case .locationError(let error):
            return error.localizedDescription
        case .locationPermissionDenied:
            return "Location permission denied"
        case .locationServicesDisabled:
            return "Location services are disabled"
        }
    }
} 
