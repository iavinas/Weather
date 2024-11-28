import Foundation

struct WeatherWidgetData {
    let temperature: Double
    let condition: String
    let location: String
    let icon: String
    let timestamp: Date
    
    static func from(weather: WeatherResponse) -> WeatherWidgetData {
        WeatherWidgetData(
            temperature: weather.main.temp,
            condition: weather.weather.first?.description ?? "",
            location: weather.name,
            icon: weather.weather.first?.icon ?? "",
            timestamp: Date()
        )
    }
} 