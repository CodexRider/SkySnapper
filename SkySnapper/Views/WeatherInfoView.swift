import SwiftUI

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

#Preview {
    WeatherInfoView(title: "Temperature", value: "25°C", icon: "thermometer")
}
