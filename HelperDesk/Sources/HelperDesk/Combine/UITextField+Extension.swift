import UIKit
import Combine

public extension UITextField {

    /// A publisher emitting any text changes to a this text field.
    var textPublisher: AnyPublisher<String?, Never> {
        Publishers.ControlProperty(control: self, events: .defaultValueEvents, keyPath: \.text)
            .eraseToAnyPublisher()
    }

    /// Convience function for when a text is entered into a textField
    ///
    /// Responds to the .editingChanged UIControl.Event
    var editingChangedPublisher: AnyPublisher<String?, Never> {
        return publisher(for: .editingChanged)
            .map { self.text }
            .eraseToAnyPublisher()
    }
}


