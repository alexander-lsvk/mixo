//
//  StatusViewContainer.swift
//  Mixo
//
//  Created by Alexander on 16.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

public protocol StatusViewContainer: class {
    var statusContainerView: UIView? { get set }
}

extension UIView: StatusViewContainer {
    static let StatusViewTag = 116114097099107 // It's track in ASCII 🤓

    public var statusContainerView: UIView? {
        get {
            return viewWithTag(UIView.StatusViewTag)
        }
        set {
            viewWithTag(UIView.StatusViewTag)?.removeFromSuperview()

            guard let view = newValue else {
                return
            }

            view.tag = UIView.StatusViewTag
            addSubview(view, with: equalToSuperview())
        }
    }
}
