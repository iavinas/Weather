import Foundation

struct WeatherResponse: Codable {
    let coord: Coordinates
    let main: MainWeather
    let weather: [Weather]
    let name: String
}

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct MainWeather: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}