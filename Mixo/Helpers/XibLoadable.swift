//
//  XibLoadable.swift
//  Mixo
//
//  Created by Alexander Lisovik on 28.05.19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit

// MARK: - XibLoadable
public protocol XibLoadable {
    static var xibName: String { get }
}

public extension XibLoadable {
    static func nib(bundle: Bundle? = nil) -> UINib {
        return UINib(nibName: xibName, bundle: bundle)
    }
}

public extension XibLoadable where Self: UIView {
    static var xibName: String {
        return String(describing: self)
    }

    static func loadViewFromXib() -> Self {
        let nib = self.nib(bundle: Bundle(for: Self.self))
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

// MARK: - XibOwnerLoadable
public protocol XibOwnerLoadable {
    static var xibName: String { get }
}

public extension XibOwnerLoadable {
    static var nib: UINib {
        return UINib(nibName: xibName, bundle: nil)
    }
}

public extension XibOwnerLoadable where Self: UIView {
    static var xibName: String {
        return String(describing: self)
    }

    func loadXib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Cannot create a view from nib \(Self.nib)")
        }
        addSubview(view, with: equalToSuperview())
        backgroundColor = view.backgroundColor
    }
}

