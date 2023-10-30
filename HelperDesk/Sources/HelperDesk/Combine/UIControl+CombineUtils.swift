//
//  UIControl+Combine.swift
//  Common
//
//  Created by Miguel Angel on 29/9/21.
//

import Combine
import UIKit

/// Custom UIControl Subscription/Publisher to make building reactive event streams less of a hassle
///
/// There is one main `publisher(_:)` function that allows a consumer to subscribe to any `UIControl.Event`
///
/// `UIControl.Event` is an `OptionSet` under the hood so if we needed to subscribe to more than one event that is also allowed
///
/// Example usage:
///
///     let button = UIButton()
///
///     button.publisher(for: .touchUpInside).sink(reciveValue: { _ in
///         print("Button Was Tapped!")
///     }
///
///     button.publisher(for: [.touchUpInsde, .touchDown, .touchUp]).sink(receiveValue: { _ in
///         print("Button Was Tapped Again!")
///     }
///
/// This implementation also allows for composition (thanks to Combine) so we are able to create convience properties/functions as we please
///
/// Example:
///
///     public extension UITextField {
///
///         var textPublisher: AnyPublisher<String?, Never> {
///             return publisher(for: .editingChanged)
///                 .map { self.text }
///                 .eraseToAnyPublisher()
///         }
///     }
///
/// Example usage:
///
///     let textField = UITextField()
///
///     textField.textPublisher().sink { text in
///         print("Textfield Was Typed In!")
///     }
///
extension UIControl {

    // MARK: - Event Subscription

    /// Custom Subscription used for UIControl
    /// Emits Void for any given UIControl.Event
    /// Never errors out
    private final class EventSubscription<S: Subscriber>: Subscription, Identifiable, Hashable where S.Input == Void {
        static func == (lhs: UIControl.EventSubscription<S>, rhs: UIControl.EventSubscription<S>) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        private var subscriber: S?

        init(subscriber: S, control: UIControl, event: Event) {
            self.subscriber = subscriber

            control.addTarget(self, action: #selector(eventHandler), for: event)
        }

        // This subscription doesn't respond to any demand because its purpose is to only emit values for the given UIControl.
        // We are still required to conform to this because its apart of the `Susbcription` protocol
        func request(_ demand: Subscribers.Demand) { }

        // The `Subscription` protocol inherits from the `Cancellable` protocol
        // so we must conform to this and release any memory when this subscription is cancelled.
        func cancel() {
            subscriber = nil
        }

        // Whenever the UIControl recieves a given event we just pass a Void object to our target so that it can handle the event.
        // We don't care if any errors happen here, just simply passing events downstream.
        @objc private func eventHandler() {
            _ = subscriber?.receive(())
        }
    }

    // MARK: - Event Publisher
    public struct EventPublisher: Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Void

        /// The kind of errors this publisher might publish.
        /// This publisher does not publish any errors.
        public typealias Failure = Never

        private let control: UIControl
        private let event: UIControl.Event

        public init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }

        /// Attaches the specified subscriber to this publisher.
        ///
        /// - Parameter subscriber: The subscriber to attach to this `Publisher`, after which it can receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
            let subscription = EventSubscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }
    }

    /// Returns a publisher that emits events for the underlying UIControl.
    ///
    /// - Parameters:
    ///   - event: The type of UIControl.Event that you want to subscribe to
    /// - Returns: A publisher that emits events for the underlying UIControl.
    public func publisher(for event: Event) -> EventPublisher {
        return .init(control: self, event: event)
    }
}
