import WidgetKit
import SwiftUI

struct WeatherWidgetProvider: TimelineProvider {
    let weatherService = WeatherService()
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            data: WeatherWidgetData(
                temperature: 25,
                condition: "Clear sky",
                location: "Loading...",
                icon: "01d",
                timestamp: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(
            date: Date(),
            data: WeatherWidgetData(
                temperature: 25,
                condition: "Clear sky",
                location: "Bangalore",
                icon: "01d",
                timestamp: Date()
            )
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        Task {
            do {
                let location = UserDefaults.standard.string(forKey: "defaultLocation") ?? "Bangalore"
                let (weather, _) = try await weatherService.fetchWeather(for: location)
                let widgetData = WeatherWidgetData.from(weather: weather)
                
                let entry = WeatherEntry(date: .now, data: widgetData)
                let nextUpdate = Date().addingTimeInterval(300) // Update every 5 minutes
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                
                completion(timeline)
            } catch {
                print("Widget timeline error: \(error)")
                let entry = placeholder(in: context)
                let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60)))
                completion(timeline)
            }
        }
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let data: WeatherWidgetData
} 
