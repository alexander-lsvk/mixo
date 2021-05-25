//
//  SubscriptionView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 9/5/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import SnapKit
import SwiftyGif

final class SubscriptionView: UIView {
    private let closeButton = UIButton()

    private let headerImageView = UIImageView()

    private let labelsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let subscriptionButtonsStackView = UIStackView()
    private let continueButton = UIButton()

    private let yearlySubscriptionButton = SubscriptionButton()
    private let weeklySubscriptionButton = SubscriptionButton()
    private let cancelDescriptionLabel = UILabel()

    private let termsOfUseButton = UIButton()
    private let restoreButton = UIButton()
    private let privacyPolicyButton = UIButton()

    var viewModel: SubscriptionViewModel?

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()

    init() {
        super.init(frame: .zero)
        configureUi()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerImageView.bounds
    }

    func update(with viewModel: SubscriptionViewModel) {
        self.viewModel = viewModel

        yearlySubscriptionButton.update(with: viewModel.yearlySubscriptionViewModel)
        weeklySubscriptionButton.update(with: viewModel.weeklySubscriptionViewModel)
    }
}

extension SubscriptionView {
    @objc
    private func onTapYearlySubscriptionButton() {
        UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseOut], animations: {
            self.yearlySubscriptionButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { finished in
            UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseIn], animations: {
                self.yearlySubscriptionButton.transform = CGAffineTransform.identity
            }) { _ in
                self.viewModel?.onSelectedPlanChangedHandler(.yearly)
            }
        }
    }

    @objc
    private func onTapWeeklySubscriptionButton() {
        UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseOut], animations: {
            self.weeklySubscriptionButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { finished in
            UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseIn], animations: {
                self.weeklySubscriptionButton.transform = CGAffineTransform.identity
            }) { _ in
                self.viewModel?.onSelectedPlanChangedHandler(.weekly)
            }
        }
    }

    @objc
    private func onTapContinueButton() {
        UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseOut], animations: {
            self.continueButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { finished in
            UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseIn], animations: {
                self.continueButton.transform = CGAffineTransform.identity
            }) { _ in
                self.viewModel?.onContinueButtonHandler()
            }
        }
    }

    @objc
    private func onTapCloseButton() {
        viewModel?.onCloseButtonHandler()
    }

    private func configureUi() {
        backgroundColor = .black

        // Close button
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.layer.cornerRadius = 16
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(onTapCloseButton), for: .touchUpInside)

        // Header image
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.layer.addSublayer(gradientLayer)
        do {
            let gif = try UIImage(gifName: "giphy.gif")
            headerImageView.setGifImage(gif, loopCount: -1)
        } catch {
            print(error)
        }

        // Title & Subtitle stackview
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)

        // Title label
        titleLabel.text = "Get unlimited recommendations with Mixo PRO"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = FontFamily.SFProRounded.bold.font(size: 28)
        titleLabel.textColor = .white

        // Subtitle label
        subtitleLabel.text = "Unlimited recommendations, mixes, tracks previews, and sorting options"
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = FontFamily.SFProRounded.regular.font(size: 17)
        subtitleLabel.textColor = .white

        // Continue button
        continueButton.backgroundColor = UIColor(red: 94.0/255.0, green: 92.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        continueButton.layer.cornerRadius = 16
        continueButton.clipsToBounds = true
        continueButton.titleLabel?.font = FontFamily.SFProRounded.medium.font(size: 17)
        continueButton.setTitle("Continue", for: .normal)

        yearlySubscriptionButton.addTarget(self, action: #selector(onTapYearlySubscriptionButton), for: .touchUpInside)
        weeklySubscriptionButton.addTarget(self, action: #selector(onTapWeeklySubscriptionButton), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(onTapContinueButton), for: .touchUpInside)

        subscriptionButtonsStackView.axis = .vertical
        subscriptionButtonsStackView.spacing = 8
        subscriptionButtonsStackView.addArrangedSubview(yearlySubscriptionButton)
        subscriptionButtonsStackView.addArrangedSubview(weeklySubscriptionButton)
        subscriptionButtonsStackView.addArrangedSubview(continueButton)
    }

    private func configureLayout() {
        addSubview(headerImageView)

        // Close button
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(12)
            make.width.height.equalTo(32)
        }

        // Title & Subtitle stackview
        addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }

        // Header image view
        headerImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(labelsStackView.snp.bottom)
        }

        continueButton.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        addSubview(subscriptionButtonsStackView)
        subscriptionButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(labelsStackView.snp.bottom).offset(16)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
    }
}
