//
//  SubscriptionPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 9/5/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct SubscriptionViewModel {
    let yearlySubscriptionViewModel: SubscriptionButtonViewModel
    let weeklySubscriptionViewModel: SubscriptionButtonViewModel
    let onSelectedPlanChangedHandler: (_ plan: SubscriptionPlan) -> Void
    let onContinueButtonHandler: () -> Void
    let onCloseButtonHandler: () -> Void
}

struct SubscriptionViewHandler {
    let setViewModel: (_ viewModel: SubscriptionViewModel) -> Void
    let dismiss: () -> Void
}

enum SubscriptionPlan {
    case yearly
    case weekly
}

final class SubscriptionPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var subscriptionViewHandler: SubscriptionViewHandler?

    private var selectedPlan = SubscriptionPlan.yearly

    func didBindController() {
        prepareViewModel()
    }
}

extension SubscriptionPresenter {
    private func prepareViewModel() {
        let yearlySubscriptionViewModel = SubscriptionButtonViewModel(
            selected: (selectedPlan == .yearly),
            period: "12 month",
            price: "24.99 US$",
            trialPeriod: "3-day free trial",
            trialPrice: "2.49 US$/mo."
        )

        let weeklySubscriptionViewModel = SubscriptionButtonViewModel(
            selected: (selectedPlan == .weekly),
            period: "1 week",
            price: "2.49 US$",
            trialPeriod: nil,
            trialPrice: nil
        )

        let viewModel = SubscriptionViewModel(
            yearlySubscriptionViewModel: yearlySubscriptionViewModel,
            weeklySubscriptionViewModel: weeklySubscriptionViewModel,
            onSelectedPlanChangedHandler: { [weak self] plan in
                self?.selectedPlan = plan
                self?.prepareViewModel()
            },
            onContinueButtonHandler: {

            },
            onCloseButtonHandler: { [weak self] in
                self?.subscriptionViewHandler?.dismiss()
            }
        )

        subscriptionViewHandler?.setViewModel(viewModel)
    }
}
