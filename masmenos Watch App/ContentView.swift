//
//  ContentView.swift
//  masmenos Watch App
//
//  Created by Ricardo Vázquez on 3/6/25.
//

import SwiftUI
import WidgetKit

private let sharedDefaults = UserDefaults(suiteName: "group.es.rikgarage.masmenos")!

fileprivate func optimalFontSize(
    for text: String,
    maxWidth: CGFloat,
    maxFontSize: CGFloat,
    minFontSize: CGFloat = 1,
    weight: UIFont.Weight
) -> CGFloat {
    var fontSize = maxFontSize

    while fontSize >= minFontSize {
        // 1. Creamos la fuente con el peso recibido
        let font = UIFont.systemFont(ofSize: fontSize, weight: weight)

        // 2. Medimos el texto usando esa fuente
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)

        // 3. Si cabe, devolvemos el tamaño actual
        if textSize.width <= maxWidth {
            return fontSize
        }

        // 4. Si no cabe, reducimos un punto y lo volvemos a intentar
        fontSize -= 1
    }

    // Si ninguno cabe, devolvemos el tamaño mínimo
    return minFontSize
}

struct ThreeLineSizedText: View {
    let arriba: String
    let medio: String
    let abajo: String
    /// 1, 2 o 3: la línea "highlight"
    let ihora: Int
    let maxFontSize: CGFloat

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            // 1) Pesos
            let w1 = (ihora == 1 ? UIFont.Weight.bold : .light)
            let w2 = (ihora == 2 ? UIFont.Weight.bold : .light)
            let w3 = (ihora == 3 ? UIFont.Weight.bold : .light)

            // 2) Tamaños óptimos individuales
            let s1 = optimalFontSize(for: arriba, maxWidth: width, maxFontSize: maxFontSize, weight: w1)
            let s2 = optimalFontSize(for: medio,  maxWidth: width, maxFontSize: maxFontSize, weight: w2)
            let s3 = optimalFontSize(for: abajo,  maxWidth: width, maxFontSize: maxFontSize, weight: w3)

            // 3) Tamaño compartido para las líneas no-ihora
            let nonHighlightSizes = [
                (1, s1),
                (2, s2),
                (3, s3)
            ]
            .filter { $0.0 != ihora }
            .map { $0.1 }
            let sharedSize = nonHighlightSizes.min() ?? min(s1, s2, s3)

            // 4) Construimos el VStack con los tamaños adecuados
            VStack(alignment: .center, spacing: 0) {
                Text(arriba)
                    .font(.system(size: ihora == 1 ? s1 : sharedSize,
                                  weight: ihora == 1 ? .bold : .light,
                                  design: .default))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(width: width, alignment: .center)

                Text(medio)
                    .font(.system(size: ihora == 2 ? s2 : sharedSize,
                                  weight: ihora == 2 ? .bold : .light,
                                  design: .default))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(width: width, alignment: .center)

                Text(abajo)
                    .font(.system(size: ihora == 3 ? s3 : sharedSize,
                                  weight: ihora == 3 ? .bold : .light,
                                  design: .default))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(width: width, alignment: .center)
            }
            .frame(width: width, height: geo.size.height)
        }
        // Limitamos la altura razonablemente; cambia el multiplicador si hace falta
        .frame(height: maxFontSize * 1.2 * 3)
    }
}

struct ContentView: View {
    @AppStorage("languageCode", store: sharedDefaults)
    private var languageCode: String = "es"
    private let languages = ["es", "en", "ca", "ja"]
    
    // Helper para elegir tamaño y peso (aunque en tu caso no lo usas aquí)
    func fontStyle(for line: Int, index: Int) -> Font {
        if index == line {
            return .system(size: 36, weight: .bold, design: .default)
        } else {
            return .system(size: 30, weight: .light, design: .default)
        }
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let (arriba, medio, abajo, todo, ihora) = TimeFormatter.horaEnLineas(
                date: context.date,
                lang: languageCode
            )

            VStack(alignment: .center) {
                ThreeLineSizedText(
                    arriba:  arriba,
                    medio:   medio,
                    abajo:   abajo,
                    ihora:   ihora,     // 1, 2 o 3
                    maxFontSize: 48
                )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    // rotamos al siguiente idioma
                    if let idx = languages.firstIndex(of: languageCode) {
                        languageCode = languages[(idx + 1) % languages.count]
                    } else {
                        languageCode = languages[0]
                    }
                    // forzamos recarga de la complicación
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } // ← cierra VStack
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        } // ← cierra TimelineView
        .id(languageCode)
    } // ← cierra body
} // ← cierra struct ContentView

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
