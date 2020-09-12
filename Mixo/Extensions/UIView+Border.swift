//
//  UIView+Border.swift
//  Mixo
//
//  Created by Alexander Lisovik on 6/1/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadiusValue: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
