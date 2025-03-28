import SwiftUI

struct CitySearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    let onCitySelected: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = viewModel.error {
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List(viewModel.searchResults) { city in
                        Button(action: {
                            onCitySelected(city.name)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.name)
                                    .font(.headline)
                                HStack {
                                    Text(city.country)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    if let state = city.state {
                                        Text("• \(state)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a city")
            .onChange(of: searchText) { _, newValue in
                Task {
                    await viewModel.searchCities(query: newValue)
                }
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CitySearchView { city in
        print("Selected city: \(city)")
    }
} 