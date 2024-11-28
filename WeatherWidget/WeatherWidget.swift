//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Avinash Kumar on 28/11/24.
//

import WidgetKit
import SwiftUI

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherWidgetProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather")
        .description("Shows current weather conditions.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: Date(), data: WeatherWidgetData(temperature: 25, condition: "Clear sky", location: "Bangalore", icon: "01d", timestamp: Date()))
    WeatherEntry(date: Date(), data: WeatherWidgetData(temperature: 30, condition: "Sunny", location: "Bangalore", icon: "01d", timestamp: Date()))
}
