# SkySnapper

SkySnapper is a weather application that shows current weather conditions for any location worldwide. The app uses the OpenWeatherMap API to fetch weather data and provides a clean, intuitive interface for viewing weather information.

## Features

- Current weather conditions
- Search for any city worldwide
- Location-based weather updates
- Detailed weather information including:
  - Temperature
  - Feels like temperature
  - Humidity
  - Wind speed
  - Weather conditions with icons

## Setup

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- An OpenWeatherMap API key (get one at [OpenWeatherMap](https://openweathermap.org/api))

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SkySnapper.git
cd SkySnapper
```

2. Create the API configuration file:
```bash
mkdir -p SkySnapper/Config
touch SkySnapper/Config/APIConfig.swift
```

3. Add your API key to `APIConfig.swift`:
```swift
import Foundation

// MARK: - API Configuration
struct WeatherAPIConfig {
    // MARK: - OpenWeather API
    struct OpenWeather {
        static let apiKey = "YOUR_API_KEY_HERE"
        
        static var baseURL: String {
            "https://api.openweathermap.org/data/2.5"
        }
        
        static var geoURL: String {
            "https://api.openweathermap.org/geo/1.0"
        }
    }
}
```

Replace `YOUR_API_KEY_HERE` with your actual OpenWeatherMap API key.

4. Open the project in Xcode:
```bash
open SkySnapper.xcodeproj
```

5. Build and run the project (⌘R)

### Important Note

The `APIConfig.swift` file is listed in `.gitignore` and will not be committed to the repository. This is to keep your API key private. Each developer needs to create their own `APIConfig.swift` file with their own API key.

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures for weather information
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and data processing

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Icons from SF Symbols by Apple 