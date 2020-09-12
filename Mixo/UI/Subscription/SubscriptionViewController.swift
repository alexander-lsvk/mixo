//
//  SubscriptionViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 9/5/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import Onboard

final class SubscriptionViewController: BaseViewController<SubscriptionPresenter> {
    private let subscriptionView = SubscriptionView.loadViewFromXib()

    override func loadView() {
        view = subscriptionView
    }

    override func viewDidLoad() {
        presenter.subscriptionViewHandler = SubscriptionViewHandler(setViewModel: { [weak self] viewModel in

        })

        super.viewDidLoad()

        // First page
        let firstPage = OnboardingContentViewController(title: "Unmimited recommendations", body: "Based on our algorithms, we give you the best tracks for harmonious mixing", image: UIImage(named: "recommendations"), buttonText: "") {}
        firstPage.view.backgroundColor = .white

        firstPage.topPadding = 0
        firstPage.underIconPadding = 10
        firstPage.underTitlePadding = 5
        firstPage.bottomPadding = 30

        firstPage.iconImageView.contentMode = .scaleAspectFit
        firstPage.iconImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        firstPage.titleLabel.font = FontFamily.SFProRounded.semibold.font(size: 20.0)
        firstPage.titleLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        firstPage.bodyLabel.font = FontFamily.SFProRounded.light.font(size: 16.0)
        firstPage.bodyLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        // Second page
        let secondPage = OnboardingContentViewController(title: "Sort as you want", body: "Enable sorting by best matches and bpm to be more flexible when you prepare your mix", image: UIImage(named: "sorting"), buttonText: "") {}
        secondPage.view.backgroundColor = .white

        secondPage.topPadding = 0
        secondPage.underIconPadding = 10
        secondPage.underTitlePadding = 5

        secondPage.titleLabel.font = FontFamily.SFProRounded.semibold.font(size: 20.0)
        secondPage.titleLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        secondPage.bodyLabel.font = FontFamily.SFProRounded.light.font(size: 16.0)
        secondPage.bodyLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        // Third page
        let thirdPage = OnboardingContentViewController(title: "Unlimited previews of tracks", body: "Listen to recommendations right in the Mixo app. Compare and choose the best one", image: UIImage(named: "play"), buttonText: "") {}
        thirdPage.view.backgroundColor = .white

        thirdPage.topPadding = 0
        thirdPage.underIconPadding = 10
        thirdPage.underTitlePadding = 5

        thirdPage.titleLabel.font = FontFamily.SFProRounded.semibold.font(size: 20.0)
        thirdPage.titleLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        thirdPage.bodyLabel.font = FontFamily.SFProRounded.light.font(size: 16.0)
        thirdPage.bodyLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        // Fourth page
        let fourthPage = OnboardingContentViewController(title: "Unlimited mixes", body: "Save your mixes, best matches or just experimental drafts. Your mixes - your space", image: UIImage(named: "mixes"), buttonText: "") {}
        fourthPage.view.backgroundColor = .white

        fourthPage.topPadding = 0
        fourthPage.underIconPadding = 10
        fourthPage.underTitlePadding = 5

        fourthPage.titleLabel.font = FontFamily.SFProRounded.semibold.font(size: 20.0)
        fourthPage.titleLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        fourthPage.bodyLabel.font = FontFamily.SFProRounded.light.font(size: 16.0)
        fourthPage.bodyLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)

        let onboardingVC = OnboardingViewController(backgroundImage: nil, contents: [firstPage, secondPage, thirdPage, fourthPage])
        onboardingVC?.pageControl.currentPageIndicatorTintColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        onboardingVC?.pageControl.pageIndicatorTintColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 0.2)

        addChildController(onboardingVC!, in: subscriptionView.featuresView)
    }
}
