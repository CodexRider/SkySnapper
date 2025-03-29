import SwiftUI

struct WeatherSubViews {
    static func weatherView(for weather: WeatherResponse) -> some View {
        VStack(spacing: 25) {
            // Weather Icon
            Image(systemName: weatherIcon(for: weather.weather.first?.main ?? ""))
                .font(.system(size: 80))
                .foregroundStyle(.gray)
            
            // Location
            VStack(spacing: 8) {
                Text(weather.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                if let firstWeather = weather.weather.first {
                    Text(firstWeather.main)
                        .font(.title2)
                    Text(firstWeather.description.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Temperature
            Text("\(Int(weather.main.temp))°C")
                .font(.system(size: 60, weight: .bold))
                .symbolEffect(.bounce, options: .repeating)
            
            // Weather Details
            HStack(spacing: 30) {
                WeatherInfoView(title: "Feel like", value: "\(Int(weather.main.feelsLike))°C", icon: "thermometer")
                WeatherInfoView(title: "Humidity", value: "\(weather.main.humidity)%", icon: "humidity")
                WeatherInfoView(title: "Wind", value: "\(Int(weather.wind.speed)) m/s", icon: "wind")
            }
        }
        .padding()
    }
    
    static func errorView(for error: Error) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .symbolEffect(.bounce, options: .repeating)
            
            Text(error.localizedDescription)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    private static func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "rain":
            return "cloud.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        default:
            return "cloud.fill"
        }
    }
}

#Preview {
        WeatherSubViews.errorView(for: WeatherError.locationPermissionDenied)
    }