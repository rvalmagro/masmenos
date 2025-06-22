//
//  AppIntent.swift
//  masomenos
//
//  Created by Ricardo Vázquez on 3/6/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String

    // Este stub satisface el requisito de AppIntent en watchOS 9.6+
    @available(watchOSApplicationExtension 9.6, *)
    func perform() async throws -> some IntentResult {
        // No necesitas devolver nada especial para un widget configurator
        return .result()
    }

    // (Opcional, pero muy recomendable) Describe el parámetro en un resumen
    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$favoriteEmoji)")
    }
}
