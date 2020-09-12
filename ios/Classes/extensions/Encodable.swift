//
//  Encodable.swift
//  light_compressor
//
//  Created by AbedElaziz shehadeh on 05/09/2020.
//

import Foundation

extension Encodable {
    var toJson: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
