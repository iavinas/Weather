import Foundation

struct CachedWeatherData {
    let weather: WeatherResponse
    let forecast: ForecastResponse
    let timestamp: Date
    let location: String
}

class WeatherService {
    private let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }()
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private var cache: CachedWeatherData?
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    func fetchWeather(for location: String, forceFetch: Bool = false) async throws -> (WeatherResponse, ForecastResponse) {
        // Check cache if force fetch is not requested
        if !forceFetch,
           let cache = cache,
           cache.location.lowercased() == location.lowercased(),
           Date().timeIntervalSince(cache.timestamp) < cacheTimeout {
            print("Using cached weather data for \(location)")
            return (cache.weather, cache.forecast)
        }
        
        // Fetch new data
        print("Fetching fresh weather data for \(location)")
        async let weather = fetchCurrentWeather(for: location)
        async let forecast = fetch5DayForecast(for: location)
        
        do {
            let (weatherData, forecastData) = try await (weather, forecast)
            
            // Update cache
            cache = CachedWeatherData(
                weather: weatherData,
                forecast: forecastData,
                timestamp: Date(),
                location: location
            )
            
            return (weatherData, forecastData)
        } catch {
            cache = nil // Invalidate cache on error
            throw error
        }
    }
    
    private func fetchCurrentWeather(for city: String) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/weather?q=\(city)&appid=\(apiKey)&units=metric"
        print("Fetching weather with URL: \(urlString)")
        
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric") else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Weather HTTP Response Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 404 {
                throw WeatherError.cityNotFound
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherError.invalidResponse
            }
        }
        
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
    
    private func fetch5DayForecast(for city: String) async throws -> ForecastResponse {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric") else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Forecast HTTP Response Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 404 {
                throw WeatherError.cityNotFound
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherError.invalidResponse
            }
        }
        
        return try JSONDecoder().decode(ForecastResponse.self, from: data)
    }
    
    func invalidateCache() {
        cache = nil
    }
    
    func shouldRefresh(for location: String) -> Bool {
        guard let cache = cache else { return true }
        return cache.location.lowercased() != location.lowercased() ||
               Date().timeIntervalSince(cache.timestamp) >= cacheTimeout
    }
}

enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case cityNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the city name."
        case .invalidResponse:
            return "Invalid response from the server."
        case .invalidData:
            return "Invalid data received from the server."
        case .cityNotFound:
            return "City not found. Please check the city name."
        }
    }
}
