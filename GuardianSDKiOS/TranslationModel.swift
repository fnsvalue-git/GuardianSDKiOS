//
//  TranslationModel.swift
//  GuardianFramework
//
//  Created by Jayhy on 09/07/2020.
//  Copyright © 2020 fns_mac_pro. All rights reserved.
//

import Foundation

struct Translation : Codable {
    var error: [String: Any]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.error = try Translation.decodeMetadata(from: container.superDecoder(forKey: .error))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StaticCodingKeys.self)
        try encodeMetadata(to: container.superEncoder(forKey: .error))
    }
    
    func encodeMetadata(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: DynamicCodingKeys.self)
           for (key, value) in error {
               switch value {
               case let double as Double:
                   try container.encode(double, forKey: DynamicCodingKeys(stringValue: key)!)
               case let string as String:
                   try container.encode(string, forKey: DynamicCodingKeys(stringValue: key)!)
               default:
                   fatalError("unexpected type")
               }
           }
       }

       private enum StaticCodingKeys: String, CodingKey {
           case error
       }
    
    static func decodeMetadata(from decoder: Decoder) throws -> [String: Any] {
       let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
       var result: [String: Any] = [:]
       for key in container.allKeys {
           if let double = try? container.decode(Double.self, forKey: key) {
               result[key.stringValue] = double
           } else if let string = try? container.decode(String.self, forKey: key) {
               result[key.stringValue] = string
           }
       }
       return result
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.init(stringValue: "")
            self.intValue = intValue
        }
    }
}


