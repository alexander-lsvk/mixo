//
//  SubscriptionPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 9/5/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct SubscriptionViewHandler {
    let setViewModel: (_ viewModel: String) -> Void
}

final class SubscriptionPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var subscriptionViewHandler: SubscriptionViewHandler?

    func didBindController() {}
}
