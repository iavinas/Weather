//
//  WeatherApp.swift
//  Weather
//
//  Created by Avinash Kumar on 24/11/24.
//

import SwiftUI

@main
struct WeatherApp: App {
    @StateObject private var themeManager = ThemeManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
    }
}
