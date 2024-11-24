import Foundation

struct ForecastResponse: Codable {
    let list: [Forecast]
    let city: City
}

struct Forecast: Codable {
    let dt: Int
    let main: MainWeather
    let weather: [Weather]
    let dt_txt: String
}

struct City: Codable {
    let name: String
    let coord: Coordinates
    let country: String
} 