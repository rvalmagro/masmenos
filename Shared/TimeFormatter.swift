//
//  TimeFormatter.swift
//  masmenos
//
//  Created by Ricardo Vázquez on 8/6/25.
//
import Foundation

enum TimeFormatter {
    /// Devuelve las tres líneas (arriba, medio, abajo) según el locale especificado.
    static func horaEnLineas(date: Date, lang: String) -> (String, String, String, String, Int) {
        switch lang {
        case "es":
            return horaEnLineasEspanol(date: date)

        case "en":
            return horaEnLineasIngles(date: date)

        case "ca":
            return horaEnLineasCatalan(date: date)

        case "ja":
            return horaEnLineasJapones(date: date)

        default:
            return horaEnLineasIngles(date: date)
        }
    }
    
    
    /// JAPONÉS
    /// Convierte un entero 0–99 a su representación en kanji (hasta 59 funciona perfectamente).
    private static func numberToKanji(_ n: Int) -> String {
        let digits = ["零","一","二","三","四","五","六","七","八","九"]
        if n < 10 {
            return digits[n]
        }
        if n == 10 {
            return "十"
        }
        if n < 20 {
            // 11–19 = "十"+"一"…"十"+"九"
            return "十" + digits[n - 10]
        }
        let tens = n / 10
        let units = n % 10
        let tensPart = (tens == 1 ? "十" : digits[tens] + "十")
        if units == 0 {
            return tensPart
        } else {
            return tensPart + digits[units]
        }
    }
    
    /// Devuelve (línea1, línea2, línea3, índiceDeLíneaConHora) según lo especificado
    static func horaEnLineasJapones(date: Date) -> (String, String, String, String, Int) {
        let calendar = Calendar.current
        let h24 = calendar.component(.hour, from: date)
        let m   = calendar.component(.minute, from: date)
        
        // 1) unit y minuteRounded
        let unit = m % 5
        let rounded: Int
        if unit == 0 {
            rounded = m
        } else if unit <= 2 {
            rounded = m - unit
        } else {
            rounded = m + (5 - unit)
        }
        
        // 2) ajustar si rounded == 60
        let hourForDisplay: Int
        let minuteForDisplay: Int
        if rounded >= 60 {
            hourForDisplay = (h24 + 1) % 12
            minuteForDisplay = 0
        } else {
            hourForDisplay = h24 % 12
            minuteForDisplay = rounded
        }
        
        // 3) convertir a kanji: H時M分
        let hourKanji   = h24 != 12 ? numberToKanji(hourForDisplay) : "十二"
        let minuteKanji = numberToKanji(minuteForDisplay)
        
        // 4) seleccionar líneas e índice según unit
        let line1, line2, line3: String
        let lineIndex: Int
        
        switch unit {
        case 3, 4:
            // faltan 1–2 minutos
            line1 = "もうすぐ"
            line2 = "\(hourKanji)時"
            line3 = minuteForDisplay == 0 ? "です" : "\(minuteKanji)分です"
            lineIndex = 2
            
        case 0:
            // exacto múltiplo de 5
            if minuteForDisplay == 0 {
                line1 = "ちょうど"
                line2 = "\(hourKanji)時"
                line3 = "です"
                lineIndex = 2
            } else {
                line1 = "\(hourKanji)時"
                line2 = "\(minuteKanji)分"
                line3 = "です"
                lineIndex = 1
            }
            
        case 1, 2:
            // han pasado 1–2 minutos
            if minuteForDisplay == 0 {
                line1 = "\(hourKanji)時"
                line2 = "ちょっとすぎ"
                line3 = "です"
                lineIndex = 1
            } else {
                line1 = "\(hourKanji)時"
                line2 = "\(minuteKanji)分"
                line3 = "ごろです"
                lineIndex = 1
            }
        default:
            // caso improbable
            line1 = "\(hourKanji)時"
            line2 = minuteForDisplay == 0 ? "です" : "\(minuteKanji)分"
            line3 = minuteForDisplay == 0 ? "" : "です"
            lineIndex = 1
        }
        var todo = "\(line1)\(line2)\(line3)"
        if todo.hasSuffix("です") {
            todo = String(todo.dropLast(2))
        }
        return (line1, line2, line3, todo, lineIndex)
    }

    /// CATALÁN
    
    /// Devuelve tres líneas (línea1, línea2, línea3) en catalán:
    /// - si es hora exacta: línea1=hora, línea2="en punt"
    /// - si son X minuts passats (<15): línea1="X minuts passats", línea2=hora
    /// - si són quarts: línea1=quarts (i minuts en palabra), línea2=hora següent
    static func horaEnLineasCatalan(date: Date) -> (String, String, String, String, Int) {
        // 1. Calendar configurado en catalán
        var cal = Calendar.current
        cal.locale   = Locale(identifier: "ca")
        cal.timeZone = TimeZone.current

        let hour24 = cal.component(.hour,  from: date)
        let minute = cal.component(.minute, from: date)

        // 2. Convertir a 12h
        let hour12     = (hour24 % 12 == 0) ? 12 : hour24 % 12
        let nextHour12 = (hour12 % 12) + 1

        // 3. Nombres 1…59 en texto (reutilizable)
        func nombre(_ n: Int) -> String {
            switch n {
            case  0: return "zero"
            case  1: return "un"
            case  2: return "dos"
            case  3: return "tres"
            case  4: return "quatre"
            case  5: return "cinc"
            case  6: return "sis"
            case  7: return "set"
            case  8: return "vuit"
            case  9: return "nou"
            case 10: return "deu"
            case 11: return "onze"
            case 12: return "dotze"
            case 13: return "tretze"
            case 14: return "catorze"
            case 15: return "quinze"
            case 16: return "setze"
            case 17: return "disset"
            case 18: return "divuit"
            case 19: return "dinou"
            case 20: return "vint"
            case 21: return "vint-i-u"
            case 22: return "vint-i-dos"
            case 23: return "vint-i-tres"
            case 24: return "vint-i-quatre"
            case 25: return "vint-i-cinc"
            case 26: return "vint-i-sis"
            case 27: return "vint-i-set"
            case 28: return "vint-i-vuit"
            case 29: return "vint-i-nou"
            case 30: return "trenta"
            case 31: return "trenta-i-u"
            case 32: return "trenta-i-dos"
            case 33: return "trenta-i-tres"
            case 34: return "trenta-i-quatre"
            case 35: return "trenta-i-cinc"
            case 36: return "trenta-i-sis"
            case 37: return "trenta-i-set"
            case 38: return "trenta-i-vuit"
            case 39: return "trenta-i-nou"
            case 40: return "quaranta"
            case 41: return "quaranta-i-u"
            case 42: return "quaranta-i-dos"
            case 43: return "quaranta-i-tres"
            case 44: return "quaranta-i-quatre"
            case 45: return "quaranta-i-cinc"
            case 46: return "quaranta-i-sis"
            case 47: return "quaranta-i-set"
            case 48: return "quaranta-i-vuit"
            case 49: return "quaranta-i-nou"
            case 50: return "cinquanta"
            case 51: return "cinquanta-i-u"
            case 52: return "cinquanta-i-dos"
            case 53: return "cinquanta-i-tres"
            case 54: return "cinquanta-i-quatre"
            case 55: return "cinquanta-i-cinc"
            case 56: return "cinquanta-i-sis"
            case 57: return "cinquanta-i-set"
            case 58: return "cinquanta-i-vuit"
            case 59: return "cinquanta-i-nou"
            default: return "\(n)"
            }
        }
        
        func nombreFemenino(_ n: Int) -> String {
            switch n {
            case  1: return "una"
            case  2: return "dues"
            case  3: return "tres"
            case  4: return "quatre"
            case  5: return "cinc"
            case  6: return "sis"
            case  7: return "set"
            case  8: return "vuit"
            case  9: return "nou"
            case 10: return "deu"
            case 11: return "onze"
            case 12: return "dotze"
            default:
                // Fuera de rango, devolvemos el número tal cual
                return "\(n)"
            }
        }
        
        // 4. Elisión "d’..." ante vocal
        func elideDe(_ palabra: String) -> String {
            let vocals = Set("aeiou")
            if let first = palabra.lowercased().first, vocals.contains(first) {
                return "d’" + palabra
            } else {
                return "de " + palabra
            }
        }

        // 5. Hora exacta
        if minute == 0 {
            if hour12 == 1 {
                return ( "la una",
                         "en punt",
                         "",
                         "la una en punt",
                         1 )
            } else {
                return ( "les " + nombreFemenino(hour12),
                         "en punt",
                         "",
                         "les " + nombreFemenino(hour12) + " en punt",
                         1 )
            }
        }

        // 6. Menys de 15 minuts
        let quarters  = minute / 15      // 0…3
        let remainder = minute % 15      // 1…14

        if quarters == 0 {
            let minutos = (minute == 1)
                ? "un minut"
                : "\(nombre(minute)) minuts"
            let frase = (minute == 1)
                ? "passat"
                : "passats"
            let todo = (hour12 == 1 ? "la " : "les ") + nombreFemenino(hour12) + " i " + nombre(minute)
            return ( minutos,
                     frase,
                     elideDe(nombreFemenino(hour12)),
                     todo,
                     3 )
        }

        // 7. Quarts (1, 2 o 3)
        if (1...3).contains(quarters) {
            let base = (quarters == 1)
                ? "un quart"
                : "\(nombre(quarters)) quarts"

            let primera: String
            let segunda: String
            let tercera: String
            let todo: String
            let idxHora: Int
            switch remainder {
            case 7, 8:
                primera = base
                segunda = "i mig"
                tercera = elideDe(nombreFemenino(nextHour12))
                todo = "\(primera) \(segunda) \(tercera)"
                idxHora = 3;
            case 0:
                primera = base
                segunda = elideDe(nombreFemenino(nextHour12))
                tercera = ""
                todo = "\(primera) \(segunda)"
                idxHora = 2;
            case 1:
                //primera = "\(base) i un"
                primera = base
                segunda = "i un"
                tercera = elideDe(nombreFemenino(nextHour12))
                todo = "\(primera) \(segunda) \(tercera)"
                idxHora = 3;
            default:
                //primera = "\(base) i \(nombre(remainder))"
                primera = base
                segunda = "i \(nombre(remainder))"
                tercera = elideDe(nombreFemenino(nextHour12))
                todo = "\(primera) \(segunda) \(tercera)"
                idxHora = 3;
            }

            return ( primera,
                     segunda,
                     tercera,
                     todo,
                     idxHora)
        }

        // 8. >45’ (no habitual; cae en minuts passats)
        return ( "\(nombre(minute)) minuts passats",
                 nombreFemenino(hour12),
                 "",
                 (hour12 == 1 ? "la " : "les ") + nombreFemenino(hour12) + " i " + nombre(minute),
                 2 )
    }
  
    /// ESPAÑOL

    
    private static func splitSpanishTimePhrase(
        _ phrase: String
    ) -> (line1: String, line2: String, line3: String, hourLine: Int) {
        
        // 1) Tokenizamos
        let tokens = phrase.split(separator: " ").map(String.init)
        let n = tokens.count
        guard n >= 3 else {
            return (phrase, "", "", 1)
        }
        
        // 2) Detectar el índice del primer token de “hora”
        let hourWords: Set<String> = [
            "una","dos","tres","cuatro","cinco","seis",
            "siete","ocho","nueve","diez","once","doce"
        ]
        let hourIdx = tokens.firstIndex {
            hourWords.contains($0.lowercased())
        } ?? 0
        
        // 3) Longitudes útiles de cada token
        let lengths = tokens.map { $0.filter { $0.isLetter }.count }
        
        // 4) Helpers
        func imbalance(_ a: Int, _ b: Int, _ c: Int) -> Int {
            max(a,b,c) - min(a,b,c)
        }
        func segmentContaining(_ idx: Int, i: Int, j: Int) -> Int {
            idx < i ? 1 : (idx < j ? 2 : 3)
        }
        
        // 5) Buscar la mejor partición
        var bestI = 1, bestJ = 2
        var bestScore = Int.max
        let total = lengths.reduce(0, +)
        
        for i in 1..<n-1 {
            for j in (i+1)..<n {
                let sum1 = lengths[0..<i].reduce(0, +)
                let sum2 = lengths[i..<j].reduce(0, +)
                let sum3 = total - sum1 - sum2
                let seg = segmentContaining(hourIdx, i: i, j: j)
                let segmentLength = (seg == 1 ? sum1 : seg == 2 ? sum2 : sum3)
                let minLen = min(sum1, sum2, sum3)
                
                // Requerimos que la línea con la hora sea la más corta:
                guard segmentLength == minLen else { continue }
                
                let score = imbalance(sum1, sum2, sum3)
                if score < bestScore {
                    bestScore = score
                    bestI = i
                    bestJ = j
                }
            }
        }
        
        // 6) Si no encontró ninguna partición que ponga la hora en la línea más corta,
        //    caemos al algoritmo original (sin esa restricción).
        if bestScore == Int.max {
            bestScore = Int.max
            for i in 1..<n-1 {
                for j in (i+1)..<n {
                    let sum1 = lengths[0..<i].reduce(0, +)
                    let sum2 = lengths[i..<j].reduce(0, +)
                    let sum3 = total - sum1 - sum2
                    let score = imbalance(sum1, sum2, sum3)
                    if score < bestScore {
                        bestScore = score
                        bestI = i
                        bestJ = j
                    }
                }
            }
        }
        
        // 7) Construir las líneas
        let line1 = tokens[0..<bestI].joined(separator: " ")
        let line2 = tokens[bestI..<bestJ].joined(separator: " ")
        let line3 = tokens[bestJ..<n].joined(separator: " ")
        
        // 8) Determinar número de línea de la hora
        let hourLine = segmentContaining(hourIdx, i: bestI, j: bestJ)
        
        return (line1, line2, line3, hourLine)
    }


    
    /// Convierte 1…12 a “la una” / “las dos” … “las doce”
    private static func numberToSpanishHora(_ h: Int) -> String {
        let horas = [
            "una","dos","tres","cuatro","cinco","seis",
            "siete","ocho","nueve","diez","once","doce"
        ]
        guard (1...12).contains(h) else { return "" }
        let palabra = horas[h - 1]
        return (h == 1) ? "la \(palabra)" : "las \(palabra)"
    }

    /// Convierte 0–59 a palabras en español, para minutos
    private static func numberToSpanish(_ n: Int) -> String {
        let words0To20 = [
            "cero","uno","dos","tres","cuatro",
            "cinco","seis","siete","ocho","nueve",
            "diez","once","doce","trece","catorce",
            "quince","dieciséis","diecisiete","dieciocho","diecinueve",
            "veinte"
        ]
        let tensWords: [Int:String] = [
            2:"veinte",3:"treinta",4:"cuarenta",5:"cincuenta"
        ]
        if n <= 20 {
            return words0To20[n]
        } else if n < 30 {
            let u = n - 20
            return u == 0
                ? "veinte"
                : "veinti" + words0To20[u]
        } else {
            let t = n / 10, u = n % 10
            if let tW = tensWords[t] {
                return u == 0
                    ? tW
                    : "\(tW) y \(words0To20[u])"
            }
        }
        return ""
    }

    /// Devuelve tres cadenas (prefijo, hora, minutos) según reglas de redondeo en español
    static func horaEnLineasEspanol(date: Date) -> (String, String, String, String, Int) {
        let cal = Calendar.current
        let h24 = cal.component(.hour, from: date)
        let m   = cal.component(.minute, from: date)
        var todo = ""

        // 1) Redondeo a múltiplo de 5
        let unit = m % 5
        let rounded: Int
        if unit == 0 {
            rounded = m
        } else if unit <= 2 {
            rounded = m - unit
        } else {
            rounded = m + (5 - unit)
        }

        // 2) Determinar hora 12h
        let rawHour = (rounded > 30 ? (h24 + 1) : h24) % 24
        var h12 = rawHour % 12
        if h12 == 0 { h12 = 12 }
        let horaText = numberToSpanishHora(h12)
        let parts = horaText.split(separator: " ", maxSplits: 1)
        let leanHour = parts.count > 1
            ? String(parts[1])
            : horaText
        
        // 3) Minuto en texto
        let minutoText: String
        if rounded == 0 {
            minutoText = "en punto"
        } else if rounded <= 30 {
            switch rounded {
            case 5:  minutoText = "y cinco"
            case 10: minutoText = "y diez"
            case 15: minutoText = "y cuarto"
            case 20: minutoText = "y veinte"
            case 25: minutoText = "y veinticinco"
            case 30: minutoText = "y media"
            default: minutoText = "y \(numberToSpanish(rounded))"
            }
        } else {
            let diff = 60 - rounded
            switch diff {
            case 0:  minutoText = "en punto"
            case 5:  minutoText = "menos cinco"
            case 10: minutoText = "menos diez"
            case 15: minutoText = "menos cuarto"
            case 20: minutoText = "menos veinte"
            case 25: minutoText = "menos veinticinco"
            default: minutoText = "menos \(numberToSpanish(diff))"
            }
        }

        // 4) Prefijo (“son”/“son pasadas”/“son casi” o “es”/“es pasadas”/“es casi”)
        let singular = (h12 == 1)
        let base = singular ? "es" : "son"
        var pref = base
        if unit != 0 {
            if unit <= 2 {
                let pasada = singular ? "pasada" : "pasadas"
                pref = "\(base) \(pasada)"
                todo = "\(leanHour) \(minutoText) \(pasada)"
            } else {
                pref = "\(base) casi"
                todo = "casi \(leanHour) \(minutoText)"
            }
        } else {
            todo = "\(leanHour) \(minutoText)"
        }
        
        let arriba: String
        let medio:  String
        let abajo:  String
        let idx: Int
        
        if unit == 0 {
            arriba = pref
            medio = horaText
            abajo = minutoText
            idx = 2
        } else if unit <= 2 {
            arriba = horaText
            medio = minutoText
            abajo = "pasadas"
            idx = 1
        } else {
            arriba = pref
            medio = horaText
            abajo = minutoText
            idx = 2
        }
        
        let (top, mid, bot, i) = splitSpanishTimePhrase("\(arriba) \(medio) \(abajo)")

        return (top, mid, bot, todo, i)
    }

    
    /// INGLÉS
    
    /// Devuelve "one"…"twelve"
    private static func hourWordEnglish(_ h12: Int) -> String {
        let words = [
            1: "one",   2: "two",    3: "three", 4: "four",
            5: "five",  6: "six",    7: "seven", 8: "eight",
            9: "nine", 10: "ten",   11: "eleven",12: "twelve"
        ]
        return words[h12] ?? ""
    }

    /// Devuelve "o’clock", "five past", "ten past", …, "quarter to", …
    private static func minutePhraseEnglish(_ rounded: Int) -> String {
        switch rounded {
        case 0:  return "o’clock"
        case 5:  return "five past"
        case 10: return "ten past"
        case 15: return "a quarter past"
        case 20: return "twenty past"
        case 25: return "twenty-five past"
        case 30: return "half past"
        case 35: return "twenty-five to"
        case 40: return "twenty to"
        case 45: return "a quarter to"
        case 50: return "ten to"
        case 55: return "five to"
        default: return ""
        }
    }

    /// Variante para inglés que devuelve (línea1, línea2, línea3, índiceHora)
    /// - Línea1: "It's" / "It's just after" / "It's nearly"
    /// - Línea2: minutePhrase ("five past", "o’clock", "quarter to", …)
    /// - Línea3: hourWord ("two", "three", …)
    static func horaEnLineasIngles(date: Date) -> (String, String, String, String, Int) {
        let cal = Calendar.current
        let h24 = cal.component(.hour, from: date)      // 0–23
        let m   = cal.component(.minute, from: date)    // 0–59

        // 1) Redondeo a múltiplo de 5
        let unit = m % 5
        let rounded: Int
        if unit == 0 {
            rounded = m
        } else if unit <= 2 {
            rounded = m - unit  // past toward lower
        } else {
            rounded = m + (5 - unit) // toward upper
        }

        // 2) Determinar hora de display
        let rawHour = (rounded > 30 ? (h24 + 1) : h24) % 24
        var h12 = rawHour % 12
        if h12 == 0 { h12 = 12 }

        // 3) Construir componentes de texto
        let prefix: String
        if unit == 1 || unit == 2 {
            prefix = "it’s just after"
        } else if unit == 3 || unit == 4 {
            prefix = "it’s nearly"
        } else {
            prefix = "it’s"
        }
        let minuteText = minutePhraseEnglish(rounded)
        let hourText   = hourWordEnglish(h12)
        
        let idx :Int
        let primera, segunda, tercera :String
        if rounded == 0 {
            primera = prefix
            segunda = hourText
            tercera = minuteText
            idx = 2
        } else {
            primera = prefix
            segunda = minuteText
            tercera = hourText
            idx = 3
        }
        
        var todo = "\(primera) \(segunda) \(tercera)"
        if todo.lowercased().hasPrefix("it’s ") {
            todo = String(todo.dropFirst("it’s ".count))
        }
        if todo.lowercased().hasSuffix(" o'clock") {
            todo = String(todo.dropLast(" o'clock".count))
        }
        todo = todo.trimmingCharacters(in: .whitespaces)

        // 4) La hora final siempre en la línea 3
        return (primera, segunda, tercera, todo, idx)
    }
}
