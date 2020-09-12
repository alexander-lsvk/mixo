//
//  StatusController.swift
//  Mixo
//
//  Created by Alexander on 16.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

protocol StatusController {
    var onView: StatusViewContainer { get }

    func show(status: Status, animated: Bool)
    func hideStatus(animated: Bool)
}

extension StatusController {
    var animationDuration: Double {
        return 0.3
    }

    func hideStatus(animated: Bool = false) {
        DispatchQueue.main.async {
            if animated == true {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.onView.statusContainerView?.alpha = 0.0
                }, completion: { _ in
                    self.onView.statusContainerView = nil
                })
            } else {
                self.onView.statusContainerView = nil
            }
        }
    }

    func show(status: Status, animated: Bool = false) {
        DispatchQueue.main.async {
            let view = self.statusView(for: status)

            if animated == true {
                view.alpha = 0.0
                self.onView.statusContainerView = view
                UIView.animate(withDuration: self.animationDuration) {
                    view.alpha = 1.0
                }
            } else {
                self.onView.statusContainerView = view
            }
        }
    }

    func statusView(for status: Status) -> UIView {
        switch status {
        case .loading:                          return LoadingStatusView.loadViewFromXib()
        case let .empty(title, description):    return EmptyStatusView.create(with: title, description)
        }
    }
}
