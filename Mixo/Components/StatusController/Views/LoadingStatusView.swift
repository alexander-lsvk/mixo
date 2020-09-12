//
//  LoadingStatusView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/22/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation
import MBProgressHUD

final class LoadingStatusView: UIView, XibLoadable {
    @IBOutlet private var contentView: UIView!

    @IBOutlet private var blurViewBottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        MBProgressHUD.showAdded(to: contentView, animated: true)
    }

    func adjustLoadingViewHeight(height: CGFloat) {
        blurViewBottomConstraint.constant = height
    }
}
