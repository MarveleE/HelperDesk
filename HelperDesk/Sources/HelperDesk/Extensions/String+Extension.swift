//
//  String+Extension.swift
//  PMM-iOS
//
//  Created by grochgen on 2023/7/24.
//

import Foundation

extension String {
    func shortToTwoDigitFloat() -> Float {
        if let floatValue = Float(self) {
            return floatValue
        }
        return 0.0
    }
}
