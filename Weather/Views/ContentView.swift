import SwiftUI

extension ContentView {
    static func iconName(for icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "cloud.snow.fill"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
}

struct RefreshIndicator: View {
    let isRefreshing: Bool
    let lastUpdated: Date?
    let theme: Theme
    
    var body: some View {
        if isRefreshing || lastUpdated != nil {
            TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                VStack(spacing: 4) {
                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.textColor))
                            .scaleEffect(0.8)
                    }
                    
                    if let lastUpdated = lastUpdated {
                        Text("Last updated: \(timeAgoString(from: lastUpdated))")
                            .font(.caption2)
                            .foregroundColor(theme.textColor.opacity(0.8))
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = -date.timeIntervalSinceNow
        
        if interval < 1 {
            return "Just now"
        } else if interval < 60 {
            let seconds = Int(interval)
            return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
    }
}

struct CurrentWeatherView: View {
    let weatherData: WeatherResponse
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 8) {
            if let description = weatherData.weather.first?.description {
                Text(description.capitalized)
                    .font(.title3)
                    .foregroundColor(theme.textColor)
            }
            
            if let icon = weatherData.weather.first?.icon {
                Image(systemName: ContentView.iconName(for: icon))
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
            }
            
            Text("\(Int(weatherData.main.temp))°C")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(theme.textColor)
            
            HStack(spacing: 20) {
                Text("Low: \(Int(weatherData.main.temp_min))°C")
                Text("High: \(Int(weatherData.main.temp_max))°C")
                Text("Feels like: \(Int(weatherData.main.feels_like))°C")
            }
            .font(.subheadline)
            .foregroundColor(theme.textColor)
        }
        .padding(.vertical, 10)
    }
}

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var weatherData: WeatherResponse?
    @State private var forecastData: ForecastResponse?
    @State private var isLoading = false
    @State private var error: Error?
    @AppStorage("defaultLocation") private var location: String = "Bangalore"
    @State private var previousLocation: String = ""
    @State private var lastUpdated: Date?
    @State private var isRefreshing = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var refreshTask: Task<Void, Never>?
    
    private let weatherService = WeatherService()
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor
                    .ignoresSafeArea()
                
                if let error = error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Button("Try Again") {
                            Task {
                                await fetchWeather(forceFetch: true)
                            }
                        }
                        .padding()
                        .background(themeManager.currentTheme.buttonBackground)
                        .foregroundColor(themeManager.currentTheme.buttonTextColor)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    VStack(spacing: 0) {
                        // Fixed Header
                        VStack(spacing: 0) {
                            Text(weatherData?.name ?? location)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .frame(maxWidth: .infinity)
                                .padding(.top, getSafeAreaTop())
                                .padding(.bottom, 5)
                            
                            if isLoading && !isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.textColor))
                                    .scaleEffect(1.5)
                                    .padding()
                            } else if let weatherData = weatherData {
                                CurrentWeatherView(
                                    weatherData: weatherData,
                                    theme: themeManager.currentTheme
                                )
                            }
                        }
                        .background(themeManager.currentTheme.backgroundColor)
                        
                        // Scrollable Forecast Section
                        ScrollView {
                            VStack(spacing: 20) {
                                RefreshIndicator(
                                    isRefreshing: isRefreshing,
                                    lastUpdated: lastUpdated,
                                    theme: themeManager.currentTheme
                                )
                                
                                if let forecastData = forecastData {
                                    // 3-hour forecast
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("3-Hour Forecast")
                                            .font(.headline)
                                            .foregroundColor(themeManager.currentTheme.textColor)
                                            .padding(.leading)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(forecastData.list.prefix(8), id: \.dt) { forecast in
                                                    ForecastCard(forecast: forecast)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    
                                    // 5-day forecast
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("5-Day Forecast")
                                            .font(.headline)
                                            .foregroundColor(themeManager.currentTheme.textColor)
                                            .padding(.leading)
                                        
                                        VStack(spacing: 12) {
                                            ForEach(getDailyForecasts(from: forecastData.list), id: \.dt) { forecast in
                                                DailyForecastRow(forecast: forecast)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .refreshable {
                            // Cancel any existing refresh task
                            refreshTask?.cancel()
                            
                            // Create new refresh task
                            refreshTask = Task {
                                isRefreshing = true
                                do {
                                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second minimum refresh time
                                    await fetchWeather(forceFetch: true)
                                } catch {}
                                isRefreshing = false
                            }
                            
                            // Wait for the refresh task to complete
                            await refreshTask?.value
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                }
            }
            .onAppear {
                if previousLocation.isEmpty {
                    previousLocation = location
                }
                checkAndUpdateWeather()
            }
            .onChange(of: location) { _, newLocation in
                if previousLocation != newLocation {
                    previousLocation = newLocation
                    Task {
                        await fetchWeather(forceFetch: true)
                    }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                checkAndUpdateWeather()
            }
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    private func checkAndUpdateWeather() {
        guard weatherService.shouldRefresh(for: location) else { return }
        
        Task {
            await fetchWeather(forceFetch: false)
        }
    }
    
    private func fetchWeather(forceFetch: Bool) async {
        if isLoading && !isRefreshing { return }
        
        isLoading = true
        error = nil
        
        do {
            let (weather, forecast) = try await weatherService.fetchWeather(
                for: location,
                forceFetch: forceFetch
            )
            
            // Check if the task was cancelled
            try Task.checkCancellation()
            
            withAnimation {
                weatherData = weather
                forecastData = forecast
                lastUpdated = Date()
                
                if let icon = weather.weather.first?.icon {
                    themeManager.updateThemeBasedOnWeather(icon)
                }
            }
        } catch is CancellationError {
            // Ignore cancellation errors
            print("Weather fetch cancelled")
        } catch {
            self.error = error
            print("Error fetching weather: \(error)")
        }
        
        isLoading = false
    }
    
    private func getDailyForecasts(from forecasts: [Forecast]) -> [Forecast] {
        var dailyForecasts: [Forecast] = []
        var lastDate: String?
        
        for forecast in forecasts {
            let date = formatDate(from: forecast.dt, format: "yyyy-MM-dd")
            if date != lastDate {
                dailyForecasts.append(forecast)
                lastDate = date
            }
        }
        
        return dailyForecasts
    }
    
    private func formatDate(from timestamp: Int, format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

struct ForecastCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let forecast: Forecast
    
    var body: some View {
        VStack {
            Text(formatTime(from: forecast.dt))
                .font(.system(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor)
            
            if let icon = forecast.weather.first?.icon {
                Image(systemName: ContentView.iconName(for: icon))
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            
            Text("\(Int(forecast.main.temp))°C")
                .font(.system(size: 20))
                .foregroundColor(themeManager.currentTheme.textColor)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.2)))
    }
    
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

struct DailyForecastRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let forecast: Forecast
    
    var body: some View {
        HStack {
            Text(formatDate(from: forecast.dt))
                .font(.system(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor)
            
            Spacer()
            
            if let icon = forecast.weather.first?.icon {
                Image(systemName: ContentView.iconName(for: icon))
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            
            Text("\(Int(forecast.main.temp))°C")
                .font(.system(size: 20))
                .foregroundColor(themeManager.currentTheme.textColor)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.2)))
        .padding(.horizontal)
    }
    
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
