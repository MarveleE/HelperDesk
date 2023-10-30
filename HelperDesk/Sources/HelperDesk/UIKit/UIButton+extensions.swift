//
//  UIButton+extensions.swift
//  PMM-iOS
//
//  Created by keyu on 2023/7/8.
//

import UIKit

extension UIButton {
    func setTitle(_ title: String, textColor: UIColor) {
        setTitle(title, for: .normal)
        setTitleColor(textColor, for: .normal)
    }
}
