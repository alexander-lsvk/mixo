//
//  RecommendationsView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import Kingfisher
import UIImageColors
import SkeletonView
import FontAwesome_swift

final class RecommendationsView: UIView, XibLoadable {
    @IBOutlet private var currentTrackImageView: UIImageView!
    @IBOutlet private var currentTrackNameLabel: UILabel!
    @IBOutlet private var currentTrackArtistsLabel: UILabel!
    @IBOutlet private var currentTrackBpmLabel: UILabel!
    @IBOutlet private var currentTrackKeyLabel: UILabel!
    
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var headerImageView: UIImageView!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var backToSearchView: UIView!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var blurView: UIVisualEffectView!

    @IBOutlet private var headerImageViewBottomAnchor: NSLayoutConstraint!

    @IBAction func didTapPlayButton() { play() }
    @IBAction func didTapAddToMixButton() { addToMixHandler?() }
    @IBAction func didTapBackToSearchButton() { backToSearchHandler?() }

    private var recommendationsSortView: RecommendationsSortView?

    private var headerImageBottomConstraint: NSLayoutConstraint?
    private var headerImageHeightConstraint: NSLayoutConstraint?

    private var viewModels: [RecommendationViewModel]?

    private var playHandler: (() -> Void)?
    private var addToMixHandler: (() -> Void)?
    private var backToSearchHandler: (() -> Void)?
    private var premiumContentHandler: (() -> Void)?

    private let skeletableViewsNumber = 10

    override func awakeFromNib() {
        configureTableView()

        recommendationsSortView = RecommendationsSortView.loadViewFromXib()

        playButton.setImage(.fontAwesomeIcon(name: .play,
                                             style: .solid,
                                             textColor: UIColor.white.withAlphaComponent(0.8),
                                             size: CGSize(width: 50.0, height: 50.0)),
                            for: .normal)
        playButton.setImage(.fontAwesomeIcon(name: .stop,
                                             style: .solid,
                                             textColor: UIColor.white.withAlphaComponent(0.8),
                                             size: CGSize(width: 50.0, height: 50.0)),
                            for: .selected)

        backToSearchView.layer.addShadow()
    }

    func setPremiumContentHandler(_ handler: @escaping () -> Void) {
        premiumContentHandler = handler
    }

    func showBackToSearchButton(_ show: Bool) {
        backToSearchView.isHidden = !show
    }
    
    func setCurrentTrackViewModel(with viewModel: RecommendationViewModel) {
        currentTrackArtistsLabel.text = viewModel.artist
        currentTrackNameLabel.text = viewModel.name
        currentTrackImageView.kf.setImage(with: viewModel.imageURL)
        headerImageView.kf.setImage(with: viewModel.imageURL)
        
        if let key = viewModel.key {
            currentTrackBpmLabel.text = "🥁 \(Int(viewModel.tempo))"
            currentTrackKeyLabel.text = "🎹 \(key.chord?.description ?? "")\(key.mode?.description ?? "")"
        }

        playButton.isSelected = viewModel.isPlaying
        
        let localPlayHandler = { viewModel.didSelectHandler(viewModel) }

        playHandler = localPlayHandler
        addToMixHandler = viewModel.addToMixHandler
        backToSearchHandler = viewModel.backToSearchHandler
    }

    func setRecommendationViewModels(_ viewModels: [RecommendationViewModel]?, animated: Bool) {
        if viewModels != nil {
            recommendationsSortView?.hideSkeleton()
        }
        self.viewModels = viewModels

        tableView.reloadData()

        if animated {
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }

    func setSortViewModel(_ viewModel: RecommendationsSortViewModel) {
        recommendationsSortView?.update(with: viewModel)
    }

    func setTableHeaderView() {
        tableView.tableHeaderView = recommendationsSortView
    }

    func viewDidLayoutSubviews() {
        if let headerView = tableView.tableHeaderView, viewModels == nil {
            headerView.showAnimatedGradientSkeleton(transition: .none)
            headerView.frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension RecommendationsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels?.count ?? skeletableViewsNumber
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.reuseId,
                                                 for: indexPath) as? TrackTableViewCell
        let viewModel = viewModels?[indexPath.row]
        cell?.update(with: viewModel)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels?[indexPath.row]
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { finished in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
                tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform.identity
            }) { _ in
                viewModel?.didSelectHandler(viewModel!)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            headerImageViewBottomAnchor.isActive = false

            headerImageHeightConstraint?.isActive = false

            headerImageBottomConstraint = headerImageView.bottomAnchor.constraint(equalTo: recommendationsSortView!.topAnchor, constant: 0.0)
            headerImageBottomConstraint?.isActive = true
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            headerImageBottomConstraint?.isActive = false

            headerImageHeightConstraint = headerImageView.heightAnchor.constraint(equalToConstant: safeAreaInsets.top)
            headerImageHeightConstraint?.isActive = true
        }
    }
}

// MARK: - SkeletonTableViewDataSource
extension RecommendationsView: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
       return TrackTableViewCell.reuseId
    }
}

// MARK: - Private methods
extension RecommendationsView {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 0, right: 0)
        
        register(reusableCell: TrackTableViewCell.self)
    }

    private func register<T: Reusable>(reusableCell: T.Type) {
        // Registers class or UINib, depending on if the cell conforms to XibLoadable or not.
        guard let xibLoadableCell = T.self as? XibLoadable.Type else {
            tableView.register(T.self, forCellReuseIdentifier: reusableCell.reuseId)
            return
        }
        tableView.register(xibLoadableCell.nib(bundle: Bundle(for: T.self)),
                           forCellReuseIdentifier: reusableCell.reuseId)
    }

    private func addPremiumContentBlur() {
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = blurView.bounds
        gradientMaskLayer.colors = [UIColor.clear.cgColor,
                                    UIColor.white.cgColor,
                                    UIColor.white.cgColor,
                                    UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0, 0.2, 0.9, 1]

        blurView.layer.mask = gradientMaskLayer
    }

    private func play() {
        playButton.isSelected = !playButton.isSelected
        playHandler?()
    }

    private func animateConstraintsChange() {
        UIView.animate(withDuration: 0.2) {
            self.headerImageView.layoutIfNeeded()
        }
    }
}
