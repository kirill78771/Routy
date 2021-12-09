#if canImport(UIKit)

import UIKit
import Routy

protocol ViewControllerContainer: UIViewController {
    var containedViewControllers: [UIViewController] { get }
    func `switch`(
        to viewController: UIViewController,
        animated: Bool,
        completion: RouteCompletion?
    )
}

extension UINavigationController: ViewControllerContainer {
    var containedViewControllers: [UIViewController] {
        viewControllers
    }

    func `switch`(
        to viewController: UIViewController,
        animated: Bool,
        completion: RouteCompletion?
    ) {
        guard topViewController != viewController else {
            completion?(true)
            return
        }
        guard viewControllers.contains(viewController) else {
            completion?(false)
            return
        }
        popToViewController(
            viewController,
            animated: animated
        )
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?(true)
            }
        } else {
            completion?(true)
        }
    }
}

extension UITabBarController: ViewControllerContainer {
    var containedViewControllers: [UIViewController] {
        viewControllers ?? []
    }

    func `switch`(
        to viewController: UIViewController,
        animated: Bool,
        completion: RouteCompletion?
    ) {
        guard selectedViewController != viewController else {
            completion?(true)
            return
        }
        guard containedViewControllers.contains(viewController) else {
            completion?(false)
            return
        }
        selectedViewController = viewController
        completion?(true)
    }
}

extension UIViewController {
    public func containedViewController(at index: Int) -> UIViewController? {
        guard
            let containedViewControllers = (self as? ViewControllerContainer)?.containedViewControllers,
            containedViewControllers.indices.contains(index)
        else {
            return nil
        }
        return containedViewControllers[index]
    }
}

extension Array where Element == UIViewController {
    public func containedViewController(at indexPath: [Int]) -> UIViewController? {
        guard let rootIndex = indexPath.first, indices.contains(rootIndex) else { return nil }
        var currentViewController = self[rootIndex]
        for index in indexPath.dropFirst() {
            if let viewController = currentViewController.containedViewController(at: index) {
                currentViewController = viewController
            } else {
                return nil
            }
        }
        return currentViewController
    }
}

#endif
