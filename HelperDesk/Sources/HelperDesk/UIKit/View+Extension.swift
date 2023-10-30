import Foundation
import UIKit
import ZLPhotoBrowser
import SwiftUI

extension View {
    func overlayBorder(_ insets: EdgeInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16), cornerRadius: CGFloat = 4, _ hidden: Bool = false) -> some View {
        return self
            .padding(insets)
            .overlay(
                Group {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.seperateLineColor, lineWidth: 1)
                        .opacity(hidden ? 0 : 1)
                }
            )
            .padding(1)
    }
}

public extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

public struct DismissKeyboardOnTap: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.contentShape(Rectangle()).gesture(tapGesture)
        #endif
    }

    private var tapGesture: some Gesture {
        TapGesture().onEnded(endEditing)
    }

    private func endEditing() {
        UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .map {$0 as? UIWindowScene}
            .compactMap({$0})
            .first?.windows
            .filter {$0.isKeyWindow}
            .first?.endEditing(true)
    }
}
extension UIApplication {
    func dissmissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

