//
//  EmptyStatusView.swift
//  Mixo
//
//  Created by Alexander on 01.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import UIKit

final class EmptyStatusView: UIView, XibLoadable {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    class func create(with title: String, _ description: String?) -> EmptyStatusView {
        let emptyStatusView = EmptyStatusView.loadViewFromXib()
        emptyStatusView.titleLabel.text = title
        emptyStatusView.descriptionLabel.text = description
        return emptyStatusView
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
