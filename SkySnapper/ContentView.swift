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
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else if let weather = viewModel.weatherData {
                        WeatherSubViews.weatherView(for: weather)
                    } else if let error = viewModel.error {
                        WeatherSubViews.errorView(for: error)
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
} 
   
// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
