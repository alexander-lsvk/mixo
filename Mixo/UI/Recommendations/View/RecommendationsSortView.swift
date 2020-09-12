//
//  RecommendationsSortView.swift
//  Mixo
//
//  Created by Alexander on 13.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

enum SortOption: Int {
    case best
    case bpmAscending
    case bpmDescending
}

struct RecommendationsSortViewModel {
    var didChangeSegmentedControlValueHandler: (_ value: SortOption) -> Void
}

final class RecommendationsSortView: UIView, XibLoadable {
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBAction func didChangeSegmentedControlValue(_ sender: UISegmentedControl) {
        didChangeSegmentedControlValueHandler?(SortOption(rawValue: sender.selectedSegmentIndex) ?? SortOption.best)
    }

    private var didChangeSegmentedControlValueHandler: ((_ value: SortOption) -> Void)?

    func update(with viewModel: RecommendationsSortViewModel) {
        didChangeSegmentedControlValueHandler = viewModel.didChangeSegmentedControlValueHandler
    }
}
