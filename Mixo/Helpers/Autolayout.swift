//
//  Autolayout.swift
//  Mixo
//
//  Created by Alexander Lisovik on 28.05.19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit

public typealias Constraint = (_ layoutView: UIView) -> NSLayoutConstraint

//
// Solution based on http://chris.eidhof.nl/post/micro-autolayout-dsl/
// Taken from: https://www.netguru.co/codestories/painless-nslayoutanchors
//
public extension UIView {
    /// Adds subview to a `self` and adds constraints using NSLayoutAnchors, based on description provided in params.
    /// Please refer to helper equal functions for info how to generate constraints easily.
    ///
    /// - SeeAlso: `addConstraints(_ constraintDescriptions: [Constraint])`
    /// - Parameters:
    ///   - view: view to be added as a subview
    ///   - constraintsDescription: constrains array
    /// - Returns: created constraints
    @discardableResult
    func addSubview(_ view: UIView, with constraintsDescription: [Constraint]) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        return view.addConstraints(constraintsDescription)
    }

    /// Adds constraints using NSLayoutAnchors, based on description provided in params.
    /// Please refer to helper equal functions for info how to generate constraints easily.
    ///
    /// - Parameter constraintDescriptions: constrains array
    /// - Returns: created constraints
    @discardableResult
    func addConstraints(_ constraintDescriptions: [Constraint]) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = constraintDescriptions.map { $0(self) }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

/// Describes constraint that is equal to constraint from different view.
/// Example: `equal(superView, \.centerXAnchor) will align view centerXAnchor to superview centerXAnchor`
///
/// - Parameters:
///   - view: that constrain should relate to
///   - to: constraints key path
/// - Returns: created constraint
public func equal<Anchor, Axis>(_ view: UIView, to: KeyPath<UIView, Anchor>, constant: CGFloat = 0.0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { layoutView in
        layoutView[keyPath: to].constraint(equalTo: view[keyPath: to], constant: constant)
    }
}

/// Describes constraint that will be equal to constant
/// Example: `equal(\.heightAnchor, to: 36) will create height constraint with value 36`
///
/// - Parameters:
///   - keyPath: constraint key path
///   - constant: value
/// - Returns: created constraint
public func equal<LayoutDimension>(_ keyPath: KeyPath<UIView, LayoutDimension>,
                                   to constant: CGFloat,
                                   priority: UILayoutPriority = .required) -> Constraint where LayoutDimension: NSLayoutDimension {
    return { layoutView in
        let constraint = layoutView[keyPath: keyPath].constraint(equalToConstant: constant)
        constraint.priority = priority
        return constraint
    }
}

/// Describes relation between constraints of two views
/// Example: `equal(logoImageView, \.topAnchor, \.bottomAnchor, constant: 80)`
/// will create constraint where topAnchor of current view is linked to bottomAnchor of passed view with offset 80
///
/// - Parameters:
///   - view: view that constraint is related from
///   - from: constraint key path of current view
///   - to: constraint key path of related view
///   - constant: value
/// - Returns: created constraint
public func equal<Anchor, Axis>(_ view: UIView, _ from: KeyPath<UIView, Anchor>, _ to: KeyPath<UIView, Anchor>, constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { layoutView in
        layoutView[keyPath: from].constraint(equalTo: view[keyPath: to], constant: constant)
    }
}

/// Describes constraints from different views where anchors should match with passed offset
/// Example: `equal(self, \.bottomAnchor, constant: -37)` will align bottomAnchors of current and passed view with offset -37
///
/// - Parameters:
///   - view: view that constraint is related from
///   - keyPath: constraint key path
///   - constant: value
/// - Returns: created constraint
public func equal<Axis, Anchor>(_ view: UIView, _ keyPath: KeyPath<UIView, Anchor>, constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return equal(view, keyPath, keyPath, constant: constant)
}

/// Describes array of constraints that will pin view to its superview.
/// Example `view.addConstraints(equalToSuperview())`
///
/// - Parameter insets: Optional insets parameter. By default it's set to .zero.
/// - Returns: Array of `Constraint`.
/// - Warning: This method uses force-unwrap on view's superview!
public func equalToSuperview(with insets: UIEdgeInsets = .zero) -> [Constraint] {
    let top: Constraint = { layoutView in
        layoutView.topAnchor.constraint(equalTo: layoutView.superview!.topAnchor, constant: insets.top)
    }

    let bottom: Constraint = { layoutView in
        layoutView.bottomAnchor.constraint(equalTo: layoutView.superview!.bottomAnchor, constant: insets.bottom)
    }

    let leading: Constraint = { layoutView in
        layoutView.leadingAnchor.constraint(equalTo: layoutView.superview!.leadingAnchor, constant: insets.left)
    }

    let trailing: Constraint = { layoutView in
        layoutView.trailingAnchor.constraint(equalTo: layoutView.superview!.trailingAnchor, constant: insets.right)
    }

    return [leading, top, trailing, bottom]
}

/// Describes array of constraints that will pin view to its superview.
/// If invoked on iOS 11, this method will pin top and bottom view edges to `safeAreaLayoutGuide`!
/// Example `view.addConstraints(equalToSuperview())`
///
/// - Parameter insets: Optional insets parameter. By default it's set to .zero.
/// - Returns: Array of `Constraint`.
/// - Warning: This method uses force-unwrap on view's superview!
/// - Warning: Pins top and bottom edges to `safeAreaLayoutGuide`!
public func equalToSafeAreaLayoutGuide(with insets: UIEdgeInsets = .zero) -> [Constraint] {
    let top: Constraint = { layoutView in
        layoutView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: layoutView.superview!.safeAreaLayoutGuide.topAnchor, constant: insets.top)
    }

    let bottom: Constraint = { layoutView in
        layoutView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: layoutView.superview!.safeAreaLayoutGuide.bottomAnchor, constant: insets.bottom)
    }

    let leading: Constraint = { layoutView in
        layoutView.leadingAnchor.constraint(equalTo: layoutView.superview!.leadingAnchor, constant: insets.left)
    }

    let trailing: Constraint = { layoutView in
        layoutView.trailingAnchor.constraint(equalTo: layoutView.superview!.trailingAnchor, constant: insets.right)
    }

    return [leading, top, trailing, bottom]
}

public func equalToTop(of view: UIView, with insets: UIEdgeInsets = .zero) -> [Constraint] {
    return [equal(view, \.topAnchor, constant: insets.top),
            equal(view, \.leadingAnchor, constant: insets.left),
            equal(view, \.trailingAnchor, constant: insets.right)]
}

public func equalToCenter(of view: UIView, with offset: CGPoint = .zero) -> [Constraint] {
    return [equal(view, \.centerXAnchor, constant: offset.x),
            equal(view, \.centerYAnchor, constant: offset.y)]
}

