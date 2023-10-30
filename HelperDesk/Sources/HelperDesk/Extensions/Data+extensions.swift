//
//  Data+extensions.swift
//  PMM-iOS
//
//  Created by keyu on 2023/6/24.
//

import Foundation

extension Encodable {
    public func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Any]()

        for (key, value) in mirror.children {
            if let key = key {
                dictionary[key] = value
            }
        }

        return dictionary
    }
}

extension Data {
    func toPrettyPrintedJSONString() -> String? {
        if let json = try? JSONSerialization.jsonObject(with: self),
           let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .withoutEscapingSlashes]) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
