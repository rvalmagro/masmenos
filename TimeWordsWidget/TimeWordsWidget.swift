//
//  TimeWordsWidget.swift
//  TimeWordsWidget
//
//  Created by Ricardo Vázquez on 16/6/25.
//

import WidgetKit
import SwiftUI


struct SimpleEntry: TimelineEntry {
    let date: Date
    let languageCode: String
}

struct Provider: TimelineProvider {
    private let sharedDefaults = UserDefaults(suiteName: "group.es.rikgarage.timewords")!

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            languageCode: sharedDefaults.string(forKey: "languageCode") ?? "es"
        )
    }
    
    func getSnapshot(in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
      let entry = SimpleEntry(
        date: Date(),
        languageCode: sharedDefaults.string(forKey: "languageCode") ?? "es"
      )
      completion(entry)
    }

    func getTimeline(in context: Context,
                      completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let ahora = Date()
        let calendar = Calendar.current
        let lang = sharedDefaults.string(forKey: "languageCode") ?? "es"

        // 1. Calculamos el baseline (próximo 00s)
        let baseline: Date
        if calendar.component(.second, from: ahora) == 0 {
            baseline = ahora
        } else {
            var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: ahora)
            comps.minute! += 1
            comps.second = 0
            baseline = calendar.date(from: comps)!
        }

        var entries: [SimpleEntry] = []

        // 2. Entrada inmediata
        entries.append(SimpleEntry(date: ahora, languageCode: lang))

        // 3. Entradas cada minuto exacto
        for minuteOffset in 0..<60 {
            if let entryDate = calendar.date(
                byAdding: .minute,
                value: minuteOffset,
                to: baseline
            ), entryDate > ahora {
                entries.append(SimpleEntry(date: entryDate, languageCode: lang))
            }
        }

        completion(.init(entries: entries, policy: .atEnd))
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [.init(intent: ConfigurationAppIntent(), description: "masomenos")]
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

fileprivate func optimalFontSize(
    for text: String,
    maxWidth: CGFloat,
    maxFontSize: CGFloat,
    minFontSize: CGFloat = 1,
    weight: UIFont.Weight
) -> CGFloat {
    var fontSize = maxFontSize
    while fontSize >= minFontSize {
        let font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = (text as NSString).size(withAttributes: attributes)
        if textSize.width <= maxWidth {
            return fontSize
        }
        fontSize -= 1
    }
    return minFontSize
}

struct ThreeLineSizedText: View {
    let arriba: String
    let medio:  String
    let abajo:  String
    let ihora:  Int      // 1, 2 o 3 la línea destacada
    let maxFontSize: CGFloat

    var body: some View {
        GeometryReader { geo in
            let width  = geo.size.width
            let height = geo.size.height

            // 1) Máximo font size que cabe verticalmente en cada una de las 3 líneas
            let lineHeightAtOne = UIFont.systemFont(ofSize: 1, weight: .light).lineHeight
            let maxFontByHeight = (height / 3) / lineHeightAtOne

            // 2) Pesos por línea
            let w1: UIFont.Weight = (ihora == 1 ? .bold : .light)
            let w2: UIFont.Weight = (ihora == 2 ? .bold : .light)
            let w3: UIFont.Weight = (ihora == 3 ? .bold : .light)

            // 3) Tamaño que cabe horizontalmente, limitado también por el vertical
            let s1 = min(
                optimalFontSize(for: arriba,
                                maxWidth:  width,
                                maxFontSize: maxFontSize,
                                weight: w1),
                maxFontByHeight
            )
            let s2 = min(
                optimalFontSize(for: medio,
                                maxWidth:  width,
                                maxFontSize: maxFontSize,
                                weight: w2),
                maxFontByHeight
            )
            let s3 = min(
                optimalFontSize(for: abajo,
                                maxWidth:  width,
                                maxFontSize: maxFontSize,
                                weight: w3),
                maxFontByHeight
            )

            // 4) Font size compartido para las dos líneas no destacadas
            let sharedSize = [
                (1, s1),
                (2, s2),
                (3, s3)
            ]
            .filter { $0.0 != ihora }
            .map    { $0.1 }
            .min() ?? min(s1, s2, s3)

            // 5) Y finalmente el VStack
            VStack(alignment: .center, spacing: 0) {
                Text(arriba)
                    .font(.system(
                        size: ihora == 1 ? s1 : sharedSize,
                        weight: ihora == 1 ? .bold : .light,
                        design: .default
                    ))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(width: width, alignment: .center)

                Text(medio)
                    .font(.system(
                        size: ihora == 2 ? s2 : sharedSize,
                        weight: ihora == 2 ? .bold : .light,
                        design: .default
                    ))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(width: width, alignment: .center)

                Text(abajo)
                    .font(.system(
                        size: ihora == 3 ? s3 : sharedSize,
                        weight: ihora == 3 ? .bold : .light,
                        design: .default
                    ))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(width: width, alignment: .center)
            }
            .frame(width: width, height: height)
        }
    }
}

fileprivate func uiFontWeight(from fw: Font.Weight) -> UIFont.Weight {
    switch fw {
    case .ultraLight: return .ultraLight
    case .light:      return .light
    case .regular:    return .regular
    case .medium:     return .medium
    case .semibold:   return .semibold
    case .bold:       return .bold
    case .heavy:      return .heavy
    case .black:      return .black
    default:          return .regular
    }
}

struct SingleLineSizedText: View {
    let text: String
    let maxFontSize: CGFloat
    let weight: Font.Weight   // ahora SwiftUI Font.Weight

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height

            // 1) Calculamos la línea base en UIKit usando el peso convertido
            let lineHeightAtOne = UIFont
                .systemFont(ofSize: 1,
                            weight: uiFontWeight(from: weight))
                .lineHeight

            // 2) Máximo tamaño por altura
            let maxByHeight = H / lineHeightAtOne

            // 3) Máximo tamaño por anchura
            let bestByWidth = optimalFontSize(
                for: text,
                maxWidth: W,
                maxFontSize: maxFontSize,
                weight: uiFontWeight(from: weight)
            )

            // 4) Elegimos el menor de ambos
            let finalSize = min(bestByWidth, maxByHeight)

            Text(text)
                .font(.system(size: finalSize,
                              weight: weight,
                              design: .default))
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(1)
                .frame(width: W, height: H, alignment: .center)
        }
    }
}


struct TimeWordsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        let (arriba, medio, abajo, todo, ihora) = TimeFormatter.horaEnLineas(
            date: entry.date,
            lang: entry.languageCode
        )
        
        Group {
            switch family {
            case .accessoryRectangular:
                SingleLineSizedText(
                    text: todo,
                    maxFontSize: 200,     // sube este máximo si quieres
                    weight: .light      // ahora Font.Weight
                )
                .padding(8)
            case .accessoryInline:
                SingleLineSizedText(
                    text: todo,
                    maxFontSize: 200,     // sube este máximo si quieres
                    weight: .light      // ahora Font.Weight
                )
                .padding(8)
            case .systemMedium:
                SingleLineSizedText(
                    text: todo,
                    maxFontSize: 200,     // sube este máximo si quieres
                    weight: .light      // ahora Font.Weight
                )
                .padding(8)
                
            default:
                VStack {
                    ThreeLineSizedText(
                        arriba: arriba,
                        medio:  medio,
                        abajo:  abajo,
                        ihora:  ihora,
                        maxFontSize: family == .systemLarge ? 80 : 48
                    )
                }
                .padding(8)
            }
        }
        // ← Aquí aplicas el fondo “nativo”
        .containerBackground(.regularMaterial, for: .widget)
    }
}
        
        /*
        switch family {
        case .accessoryRectangular:
            SingleLineSizedText(
                text: todo,
                maxFontSize: 200,     // sube este máximo si quieres
                weight: .light      // ahora Font.Weight
            )
            .padding(8)
        case .accessoryInline:
            SingleLineSizedText(
                text: todo,
                maxFontSize: 200,     // sube este máximo si quieres
                weight: .light      // ahora Font.Weight
            )
            .padding(8)
        case .systemMedium:
            SingleLineSizedText(
                text: todo,
                maxFontSize: 200,     // sube este máximo si quieres
                weight: .light      // ahora Font.Weight
            )
            .padding(8)
          
        default:
            VStack(alignment: .center) {
                ThreeLineSizedText(
                    arriba:  arriba,
                    medio:   medio,
                    abajo:   abajo,
                    ihora:   ihora,     // 1, 2 o 3
                    maxFontSize: 120
                )
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
*/
struct TimeWordsWidget: Widget {
    let kind: String = "TimeWordsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            TimeWordsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Time Words")
        .description("Writen time on your Home Screen.")
        .supportedFamilies([.accessoryRectangular,.accessoryInline,.systemSmall, .systemMedium, .systemLarge])
    }
}

/*
struct TimeWordsWidget: Widget {
    let kind: String = "TimeWordsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TimeWordsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}
*/
#Preview(as: .systemSmall) {
    TimeWordsWidget()
} timeline: {
    SimpleEntry(date: .now, languageCode: "en")
    SimpleEntry(date: .now, languageCode: "ca")
}
