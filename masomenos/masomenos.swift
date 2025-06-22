//
//  masomenos.swift
//  masomenos
//
//  Created by Ricardo Vázquez on 3/6/25.
//

import WidgetKit
import SwiftUI

// MARK: — EL ENTRY YA NO LLEVA CONFIGURATION, SOLO DATE + LANGUAGE

struct SimpleEntry: TimelineEntry {
    let date: Date
    let languageCode: String
}

// MARK: — PROVIDER

struct Provider: AppIntentTimelineProvider {
    private let sharedDefaults = UserDefaults(suiteName: "group.es.rikgarage.masmenos")!

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            languageCode: sharedDefaults.string(forKey: "languageCode") ?? "es"
        )
    }

    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            languageCode: sharedDefaults.string(forKey: "languageCode") ?? "es"
        )
    }

    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<SimpleEntry> {
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

        return Timeline(entries: entries, policy: .atEnd)
    }

    @available(watchOSApplicationExtension 10.0, *)
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [.init(intent: ConfigurationAppIntent(), description: "Time Words")]
    }
}

// MARK: — UTILITIES (optimalFontSize, DynamicSizedText)
fileprivate func optimalFontSize(
    for text: String,
    maxWidth: CGFloat,
    maxFontSize: CGFloat,
    minFontSize: CGFloat = 1
) -> CGFloat {
    var fontSize = maxFontSize
    while fontSize >= minFontSize {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        // Declaramos el diccionario aquí, como constante local:
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)
        if textSize.width <= maxWidth {
            return fontSize
        }
        fontSize -= 1
    }
    return minFontSize
}

struct DynamicSizedText: View {
    let text: String
    let maxFontSize: CGFloat
    let bold: Bool

    var body: some View {
        GeometryReader { geometry in
            // 1. Calculamos el ancho disponible:
            let containerWidth = geometry.size.width

            // 2. Llamamos a nuestra función de “medida” para obtener el mejor fontSize
            let chosenFontSize = optimalFontSize(
                for: text,
                maxWidth: containerWidth,
                maxFontSize: maxFontSize
            )

            // 3. Mostramos el Text con ese tamaño
            Text(text)
                .font(.system(size: chosenFontSize, weight: bold ? .bold : .light, design: .default))
                // Hacemos que el Text se ajuste en vertical si necesitara
                .fixedSize(horizontal: false, vertical: true)
                // Para que no recorte, y “viva” en varias líneas si no cabe en una sola:
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        // Importante: limitar el alto del GeometryReader a lo razonable para no “romper” el layout
        // Por defecto, un GeometryReader expande todo el espacio vertical posible. Aquí enviamos
        // una altura provisional alta para que calcule el text, pero no queremos un fix height.
        // En un VStack con .fixedSize(vertical: true), bastará para medir el ancho.
        .frame(height: maxFontSize * 1.2) // altura aproximada: fontSize + un poco de “tracking”
    }
}
// MARK: — VISTA DE LA COMPLICACIÓN

struct masomenosEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        let (arriba, medio, abajo, todo, ihora) = TimeFormatter.horaEnLineas(
            date: entry.date,
            lang: entry.languageCode
        )
        
        switch family {
        case .accessoryInline:
            // Solo una línea en esa curva pequeña
            Text(todo)
                //.font(.system(size: 12, weight: .regular, design: .default))
                //.lineLimit(1)
                //.minimumScaleFactor(0.5)
                //.multilineTextAlignment(.center)
                // Ya heredará la cápsula gracias a containerBackground(for: .widget)
                // y no hará falta más modificadores de fondo aquí.

        default:
            VStack(alignment: .leading, spacing: -10) {
                DynamicSizedText(text: arriba, maxFontSize: 30, bold: ihora == 1)
                DynamicSizedText(text: medio,  maxFontSize: 30, bold: ihora == 2)
                DynamicSizedText(text: abajo,  maxFontSize: 30, bold: ihora == 3)
            }
            .padding()
        }
    }
}

// MARK: — WIDGET DECLARATION

@main
struct masomenos: Widget {
    let kind: String = "masomenos"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            masomenosEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

// MARK: — PREVIEW

#Preview(as: .accessoryRectangular) {
    masomenos()
} timeline: {
    SimpleEntry(date: .now, languageCode: "en")
    SimpleEntry(date: .now, languageCode: "ca")
}



