//
//  CALayer+Shadow.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

extension CALayer {
    func addShadow(color: UIColor = .darkGray, radius: CGFloat = 3.0, opacity: Float = 0.4) {
        self.shadowOffset = .zero
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        self.shadowColor = color.cgColor
        self.masksToBounds = false

        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }

    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }

    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter { $0.frame.equalTo(self.bounds) }
                      .forEach { $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first,
                sublayer.name == "ShadowContent" {

                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = "ShadowContent"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}
