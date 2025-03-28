import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiKey = "6528b4d25a3c3494f8041cb82ec4efd6"
    
    func searchCities(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        error = nil
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            error = WeatherError.invalidURL
            isLoading = false
            return
        }
        
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(encodedQuery)&limit=10&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            error = WeatherError.invalidURL
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(WeatherErrorResponse.self, from: data) {
                    throw WeatherError.apiError(errorResponse.message)
                } else {
                    throw WeatherError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            let results = try decoder.decode([SearchResult].self, from: data)
            searchResults = results
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
} 