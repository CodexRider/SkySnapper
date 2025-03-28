import Foundation
import SwiftUI
import CoreLocation

@MainActor
class WeatherViewModel: NSObject, ObservableObject {
    @Published var weatherData: WeatherResponse?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let locationManager = CLLocationManager()
    private let apiKey = "6528b4d25a3c3494f8041cb82ec4efd6"
    private var locationContinuation: CheckedContinuation<Void, Error>?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000 // Update location when moved more than 1km
    }
    
    func checkLocationAndFetchWeather() async {
        isLoading = true
        error = nil
        
        // Check current authorization status first
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // Request authorization and wait for the delegate callback
            do {
                try await withCheckedThrowingContinuation { continuation in
                    self.locationContinuation = continuation
                    self.locationManager.requestWhenInUseAuthorization()
                }
            } catch {
                self.error = error
                self.isLoading = false
                return
            }
        case .restricted, .denied:
            error = WeatherError.locationPermissionDenied
            isLoading = false
            return
        case .authorizedWhenInUse, .authorizedAlways:
            // We have permission, start updating location
            locationManager.startUpdatingLocation()
        @unknown default:
            error = WeatherError.locationError(NSError(domain: "WeatherViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"]))
            isLoading = false
            return
        }
    }
    
    func fetchWeather(for city: String) async {
        isLoading = true
        error = nil
        
        print("Fetching weather for city: \(city)")
        
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode city name")
            error = WeatherError.invalidURL
            isLoading = false
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        print("Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Failed to create URL")
            error = WeatherError.invalidURL
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw WeatherError.invalidResponse
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(WeatherErrorResponse.self, from: data) {
                    print("API Error: \(errorResponse.message)")
                    throw WeatherError.apiError(errorResponse.message)
                } else {
                    print("Invalid response status code")
                    throw WeatherError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            let weatherData = try decoder.decode(WeatherResponse.self, from: data)
            print("Successfully fetched weather for: \(weatherData.name)")
            
            self.weatherData = weatherData
            self.isLoading = false
        } catch {
            print("Error fetching weather: \(error.localizedDescription)")
            self.error = error
            self.isLoading = false
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            do {
                let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric")!
                
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
                let weatherData = try decoder.decode(WeatherResponse.self, from: data)
                
                self.weatherData = weatherData
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = WeatherError.locationError(error)
            self.isLoading = false
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                // User granted permission, start updating location
                manager.startUpdatingLocation()
                locationContinuation?.resume()
                locationContinuation = nil
            case .denied, .restricted:
                self.error = WeatherError.locationPermissionDenied
                self.isLoading = false
                locationContinuation?.resume(throwing: WeatherError.locationPermissionDenied)
                locationContinuation = nil
            case .notDetermined:
                // Still waiting for user response
                break
            @unknown default:
                self.error = WeatherError.locationError(NSError(domain: "WeatherViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"]))
                self.isLoading = false
                locationContinuation?.resume(throwing: WeatherError.locationError(NSError(domain: "WeatherViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"])))
                locationContinuation = nil
            }
        }
    }
} 
