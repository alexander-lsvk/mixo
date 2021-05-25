//
//  SubscriptionButton.swift
//  Mixo
//
//  Created by Alexander Lisovik on 31.01.2021.
//  Copyright © 2021 Alexander Lisovik. All rights reserved.
//

import Foundation

struct SubscriptionButtonViewModel {
    let selected: Bool
    let period: String
    let price: String
    let trialPeriod: String?
    let trialPrice: String?
}

final class SubscriptionButton: UIButton {
    private let backgroundView = UIView()

    private let subscriptionStackView = UIStackView()

    private let termsLabelsStackView = UIStackView()
    private let termLabel = UILabel()
    private let trialLabel = UILabel()

    private let pricesLabelsStackView = UIStackView()
    private let priceLabel = UILabel()
    private let trialPriceLabel = UILabel()

    private var viewModel: SubscriptionButtonViewModel?

    init() {
        super.init(frame: .zero)

        configureUi()
        configureLayout()

        layer.cornerRadius = 8
        clipsToBounds = true
    }

    func update(with viewModel: SubscriptionButtonViewModel) {
        self.viewModel = viewModel

        viewModel.selected ? (backgroundColor = UIColor(red: 94.0/255.0, green: 92.0/255.0, blue: 230.0/255.0, alpha: 1.0)) :
                             (backgroundColor = UIColor(red: 15.0/255.0, green: 15.0/255.0, blue: 17.0/255.0, alpha: 1.0))

        if viewModel.trialPeriod != nil {
            termsLabelsStackView.addArrangedSubview(trialLabel)
        }
        termLabel.text = viewModel.period
        trialLabel.text = viewModel.trialPeriod
        if viewModel.trialPrice != nil {
            pricesLabelsStackView.addArrangedSubview(trialPriceLabel)
        }
        priceLabel.text = viewModel.price
        trialPriceLabel.text = viewModel.trialPrice
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SubscriptionButton {
    private func configureUi() {
        // Background view
        backgroundView.backgroundColor = .black
        backgroundView.layer.cornerRadius = 7
        backgroundView.clipsToBounds = true
        backgroundView.isUserInteractionEnabled = false

        // Subscription stackview
        subscriptionStackView.axis = .horizontal
        subscriptionStackView.addArrangedSubview(termsLabelsStackView)
        subscriptionStackView.addArrangedSubview(pricesLabelsStackView)
        subscriptionStackView.isUserInteractionEnabled = false

        // Terms labels stackview
        termsLabelsStackView.axis = .vertical
        termsLabelsStackView.spacing = 4
        termsLabelsStackView.addArrangedSubview(termLabel)
        termsLabelsStackView.isUserInteractionEnabled = false

        termLabel.font = FontFamily.SFProRounded.medium.font(size: 17)
        termLabel.textColor = .white

        trialLabel.font = FontFamily.SFProRounded.regular.font(size: 13)
        trialLabel.textColor = UIColor(red: 94.0/255.0, green: 92.0/255.0, blue: 230.0/255.0, alpha: 1.0)

        // Prices labels stackview
        pricesLabelsStackView.axis = .vertical
        pricesLabelsStackView.spacing = 4
        pricesLabelsStackView.addArrangedSubview(priceLabel)

        priceLabel.textAlignment = .right
        priceLabel.font = FontFamily.SFProRounded.medium.font(size: 17)
        priceLabel.textColor = .white

        trialPriceLabel.textAlignment = .right
        trialPriceLabel.font = FontFamily.SFProRounded.regular.font(size: 13)
        trialPriceLabel.textColor = UIColor(red: 124.0/255.0, green: 129.0/255.0, blue: 145.0/255.0, alpha: 1.0)
    }

    private func configureLayout() {
        // Background view
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.top.leading.equalTo(2)
            make.trailing.bottom.equalTo(-2)
            make.height.equalTo(64)
        }

        // Close button
        backgroundView.addSubview(subscriptionStackView)
        subscriptionStackView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.leading.equalTo(18)
            make.trailing.equalTo(-18)
            make.bottom.equalTo(-12)
        }
    }
}
