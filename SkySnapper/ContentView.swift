//
//  ContentView.swift
//  SkySnapper
//
//  Created by Sakis Siasios on 28/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showingCitySearch = false
    
    var body: some View {
        NavigationStack {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        loadingView
                    } else if let weather = viewModel.weatherData {
                        weatherView(for: weather)
                    } else if let error = viewModel.error {
                        errorView(for: error)
                    }
                }
                .padding()
                .navigationTitle("SkySnapper")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showingCitySearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
                .sheet(isPresented: $showingCitySearch) {
                    CitySearchView { city in
                        Task {
                            await viewModel.fetchWeather(for: city)
                        }
                    }
                }
                .task {
                    await viewModel.checkLocationAndFetchWeather()
                }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    private func weatherView(for weather: WeatherResponse) -> some View {
        VStack(spacing: 25) {
            weatherIconView(for: weather.weather.first?.main ?? "")
            
            locationView(for: weather)
            
            temperatureView(for: weather)
            
            weatherDetailsView(for: weather)
        }
        .padding()
    }
    
    private func weatherIconView(for condition: String) -> some View {
        Image(systemName: weatherIcon(for: condition))
            .font(.system(size: 80))
            .foregroundStyle(.gray)
    }
    
    private func locationView(for weather: WeatherResponse) -> some View {
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
    }
    
    private func temperatureView(for weather: WeatherResponse) -> some View {
        Text("\(Int(weather.main.temp))°C")
            .font(.system(size: 60, weight: .bold))
            .symbolEffect(.bounce, options: .repeating)
    }
    
    private func weatherDetailsView(for weather: WeatherResponse) -> some View {
        HStack(spacing: 30) {
            WeatherInfoView(title: "Feels like", value: "\(Int(weather.main.feelsLike))°C", icon: "thermometer")
            WeatherInfoView(title: "Humidity", value: "\(weather.main.humidity)%", icon: "humidity")
            WeatherInfoView(title: "Wind", value: "\(Int(weather.wind.speed)) m/s", icon: "wind")
        }
    }
    
    private func errorView(for error: Error) -> some View {
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
    
    // MARK: - Helper Methods
    
    private func weatherIcon(for condition: String) -> String {
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

// MARK: - Weather Info View
struct WeatherInfoView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.headline)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
