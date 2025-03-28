import Foundation

struct SearchResult: Codable, Identifiable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    var id: String { "\(name)-\(lat)-\(lon)" }
    
    enum CodingKeys: String, CodingKey {
        case name
        case lat
        case lon
        case country
        case state
    }
} 