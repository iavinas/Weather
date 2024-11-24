import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    
    init() {
        // Initialize with system theme
        let hour = Calendar.current.component(.hour, from: Date())
        self.currentTheme = (hour < 6 || hour > 18) ? .dark : .light
    }
    
    func updateThemeBasedOnTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        currentTheme = (hour < 6 || hour > 18) ? .dark : .light
    }
    
    func updateThemeBasedOnWeather(_ weatherIcon: String?) {
        guard let icon = weatherIcon else { return }
        let hour = Calendar.current.component(.hour, from: Date())
        if icon.contains("n") || hour < 6 || hour > 18 {
            currentTheme = .dark
        } else {
            currentTheme = .light
        }
    }
}
