import SwiftUI

struct CitySearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var cities: [String] = []
    let onCitySelected: (String) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCities, id: \.self) { city in
                    Button(action: {
                        onCitySelected(city)
                        dismiss()
                    }) {
                        Text(city)
                            .font(.headline)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a city")
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Load some sample cities
                cities = [
                    "London", "New York", "Tokyo", "Paris", "Sydney",
                    "Berlin", "Moscow", "Dubai", "Singapore", "Hong Kong",
                    "Rome", "Madrid", "Amsterdam", "Vienna", "Prague",
                    "Seoul", "Bangkok", "Cairo", "Athens", "Rio de Janeiro"
                ]
            }
        }
    }
    
    private var filteredCities: [String] {
        if searchText.isEmpty {
            return cities
        }
        return cities.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
}

#Preview {
    CitySearchView { city in
        print("Selected city: \(city)")
    }
} 