//
//  UIViewController+ChildViewController.swift
//  Mixo
//
//  Created by Alexander on 17.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

extension UIViewController {
    /// Adds child view controller in specific container (if specified).
    /// Additionally this method creates a set of Constraints to the container view and activates them.
    /// It also calls `didMove(toParent:)`
    ///
    /// - Parameters:
    ///   - child: View Controller which is about ot be added as a child view controller.
    ///   - container: Container in which child's view should be embedded.
    func addChildController(_ child: UIViewController, in container: UIView? = nil) {
        addChild(child)

        if let containerView = container {
            containerView.addSubview(child.view, with: equalToSuperview())
        }

        child.didMove(toParent: self)
        setNeedsStatusBarAppearanceUpdate()
    }

    /// Removes View Controller from it's parent if it's a child view controller.
    /// Calls `willMove(toParent: nil)`.
    /// Deactivates view controller's view's constraints from parent and removes it from the superview.
    func remove(animated: Bool = false) {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)

        let removeBlock: () -> Void = {
            NSLayoutConstraint.deactivate(self.view.constraints.filter({ $0.firstItem === self.parent || $0.secondItem === self.parent }))
            self.parent?.setNeedsStatusBarAppearanceUpdate()
            self.removeFromParent()
            self.view.removeFromSuperview()
        }

        guard animated else {
            removeBlock()
            return
        }

        view.superview?.bringSubviewToFront(view)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            removeBlock()
        })
    }
}
