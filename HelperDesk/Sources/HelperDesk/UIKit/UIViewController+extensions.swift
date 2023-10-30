//
//  UIViewController+extensions.swift
//  PMM-iOS
//
//  Created by keyu on 2023/7/1.
//

import UIKit

public extension UIViewController {
    static var rootViewController: UIViewController? {
        // FIXME: deprecated，可能不能用这个方法找root vc
        UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController
    }
}

extension UIViewController {
    private class var sharedApplication: UIApplication? {
        let selector = NSSelectorFromString("sharedApplication")
        return UIApplication.perform(selector)?.takeUnretainedValue() as? UIApplication
    }

    class var topMost: UIViewController? {
        guard let currentWindows = self.sharedApplication?.windows else { return nil }
        var rootViewController: UIViewController?
        for window in currentWindows {
            if let windowRootViewController = window.rootViewController, window.isKeyWindow {
                rootViewController = windowRootViewController
                break
            }
        }
        return self.topMost(of: rootViewController)
    }

    class func topMost(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMost(of: presentedViewController)
        }

        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }

        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }

        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
           pageViewController.viewControllers?.count == 1 {
            return self.topMost(of: pageViewController.viewControllers?.first)
        }

        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }
        return viewController
    }
}

extension UIViewController {

    static func replaceRootViewController(vc: UIViewController, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        if animated {
            window.rootViewController?.dismiss(animated: true, completion: nil)
            let oldView = window.rootViewController?.view
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = vc
                UIView.setAnimationsEnabled(oldState)
            }) { (finished) in
                oldView?.removeFromSuperview()
                if let completion {
                    completion(finished)
                }
            }
        } else {
            window.rootViewController = vc
            if let completion {
                completion(true)
            }
        }
    }
}
