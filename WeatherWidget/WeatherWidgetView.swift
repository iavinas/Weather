import SwiftUI
import WidgetKit

struct WeatherWidgetEntryView: View {
    var entry: WeatherWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, Color("lightBlue")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.data.location)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(alignment: .center) {
                    Image(systemName: WeatherWidgetUtilities.iconName(for: entry.data.icon))
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    
                    Text("\(Int(entry.data.temperature))°")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if family != .systemSmall {
                    Text(entry.data.condition.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
    }
} 