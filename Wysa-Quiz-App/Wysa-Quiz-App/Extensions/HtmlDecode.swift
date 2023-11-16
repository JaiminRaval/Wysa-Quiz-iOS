//
//  HtmlDecode.swift
//  Wysa-Quiz-App
//
//  Created by Jaimin Raval on 16/11/23.
//

import Foundation

// formatting html elements coming in API Data
class HtmlDecode {
    static func decodingHTMLElements(htmlString: String) -> String? {
        guard let data = htmlString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        do {
            let correctedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return correctedString.string
        } catch {
            print("Error decoding HTML Elements: \(error)")
            return nil
        }
    }
}
