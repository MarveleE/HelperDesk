//
//  UIButton+Combine.swift
//  Common
//
//  Created by Miguel Angel on 29/9/21.
//

import Combine
import UIKit

public extension UIButton {

    /// A publisher emits when a button is tapped.
    ///
    /// Responds to the .touchUpInside UIControl.Event
    var tapPublisher: AnyPublisher<Void, Never> {
        return publisher(for: .touchUpInside)
            .eraseToAnyPublisher()
    }
}
