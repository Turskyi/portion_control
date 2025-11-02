

import WidgetKit
import SwiftUI

// MARK: - Data Keys
struct WidgetDataKeys {
    static let portionControl = "text_portion_control"
    static let imagePath = "image"
    static let weight = "text_weight"
    static let consumed = "text_consumed"
    static let recommendation = "text_recommendation"
    static let lastUpdated = "text_last_updated"
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {

    let userDefaults = UserDefaults(suiteName: "group.dmytrowidget")
    
    func placeholder(in context: Context) -> PortionControlEntry {
        PortionControlEntry(
            date: Date(),
            weight: "70.5",
            consumed: "350",
            portionControl: "500",
            recommendation: "Looking good!",
            lastUpdated: "Just now",
            chartImage: nil,
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PortionControlEntry) -> ()) {
        let entry = readData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = readData()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func readData() -> PortionControlEntry {
        let weight = userDefaults?.string(forKey: WidgetDataKeys.weight)
        let consumed = userDefaults?.string(forKey: WidgetDataKeys.consumed)
        let portionControl = userDefaults?.string(forKey: WidgetDataKeys.portionControl)
        let recommendation = userDefaults?.string(forKey: WidgetDataKeys.recommendation)
        let lastUpdated = userDefaults?.string(forKey: WidgetDataKeys.lastUpdated)
        let imagePath = userDefaults?.string(forKey: WidgetDataKeys.imagePath)
        
        var chartImage: UIImage?
        if let path = imagePath {
            // Important: The image path must be accessible by the widget extension.
            // Ensure you are saving it to the shared group container.
            if let image = UIImage(contentsOfFile: path) {
                chartImage = image
            }
        }
        
        return PortionControlEntry(
            date: Date(),
            weight: weight,
            consumed: consumed,
            portionControl: portionControl,
            recommendation: recommendation,
            lastUpdated: lastUpdated,
            chartImage: chartImage
        )
    }
}

// MARK: - Timeline Entry
struct PortionControlEntry: TimelineEntry {
    let date: Date
    let weight: String?
    let consumed: String?
    let portionControl: String?
    let recommendation: String?
    let lastUpdated: String?
    let chartImage: UIImage?
}

// MARK: - Widget View
struct PortionControlWidgetsEntryView: View {
    var entry: Provider.Entry
    
    private let defaultMessages = [
        "🍽️ Oops! No meal data available.",
        "🤷 Looks like we couldn’t log your portion this time.",
        "🥗 No recommendation? Trust your instincts today!",
        "📊 Data’s taking a break — try again soon!"
    ]
    
    var body: some View {
        let weightValue = Double(entry.weight ?? "0.0") ?? 0.0
        let consumedValue = Double(entry.consumed ?? "0.0") ?? 0.0
        
        var hintMessage: String? {
            if weightValue == 0.0 {
                return "👉 Enter weight before your first meal."
            }
            if weightValue != 0.0 && consumedValue == 0.0 {
                return "👉 Enter food weight."
            }
            return nil
        }
        
        let recommendationText: String = {
            if let hint = hintMessage {
                return hint
            } else if let rec = entry.recommendation, !rec.isEmpty {
                return rec
            } else {
                return defaultMessages.randomElement()!
            }
        }()
        
        ZStack {
            // Background gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.94, blue: 0.96), // #FFF0F5
                    Color(red: 0.83, green: 0.48, blue: 0.61)  // #D47A9B
                ]),
                center: .center,
                startRadius: 5,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // --- Background chart image or fallback ---
            if let uiImage = entry.chartImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .padding([.leading], 8)
            } else {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.94, blue: 0.96), // #FFF0F5
                        Color(red: 0.83, green: 0.48, blue: 0.61)  // #D47A9B
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 500
                )
                .ignoresSafeArea()
            }
            
            // --- Overlay text blocks ---
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {

                        if weightValue != 0.0, let weight = entry.weight {
                            Text("Weight: \(weight) kg")
                                .font(.system(size: 18, weight: .bold))
                        }
                        
                        if consumedValue != 0.0, let consumed = entry.consumed {
                            Text("Consumed: \(consumed) g")
                                .font(.system(size: 16))
                        }
                        
                        if let portionControl = entry.portionControl, !portionControl.isEmpty {
                            Text("Limit: \(portionControl) g")
                                .font(.system(size: 15))
                        }
                    }
                    .padding(8)
                    .background(.thinMaterial.opacity(0.7))
                    .cornerRadius(10)
                    .frame(width: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    .padding([.top, .leading], 4)
                }
                
                Spacer()
                
                // Bottom-left info (recommendation + last updated)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recommendationText)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.leading)
                        
                        if let lastUpdated = entry.lastUpdated, !lastUpdated.isEmpty {
                            Text(lastUpdated)
                                .font(.system(size: 12))
            
                        }
                    }
                    .padding(8)
                    .background(.thinMaterial.opacity(0.7))
                    .cornerRadius(10)
                    .frame(width: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    .padding([.bottom, .leading], 4)
                }
            }
        }
    }
}

// MARK: - Widget Configuration
struct PortionControlWidgets: Widget {
    let kind: String = "PortionControlWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortionControlWidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PortionControl")
        .description("Keep track of your portions from your home screen.")
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    PortionControlWidgets()
} timeline: {
    PortionControlEntry(
        date: .now,
        weight: "70.5",
        consumed: "350",
        portionControl: "500",
        recommendation: "Looking good!",
        lastUpdated: "Just now",
        chartImage: nil,
    )
    PortionControlEntry(
        date: .now,
        weight: "70.5",
        consumed: "0",
        portionControl: "500",
        recommendation: nil,
        lastUpdated: "Just now",
        chartImage: nil,
    )
}
