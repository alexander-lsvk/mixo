//
//  SearchView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 28.05.19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import SkeletonView

final class SearchView: UIView, XibLoadable {
    @IBOutlet private var searchBar: SearchBar!
    @IBOutlet private var tableView: UITableView!

    private var viewModels: [SearchResultViewModel]?

    private let skeletableViewsNumber = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }

    func setSearchBarHandler(_ searchQueryHandler: ((_ query: String) -> Void)?) {
        searchBar.searchQueryHandler = searchQueryHandler
    }

    func update(with viewModels: [SearchResultViewModel]?) {
        self.viewModels = viewModels
        self.tableView.reloadData()
    }

    func becomeSearchFirstResponder() {
        searchBar.becomeSearchFirstResponder()
    }
}

// MARK: - TableView DataSource & Delegate
extension SearchView: UITableViewDataSource, UITableViewDelegate {
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
        viewModel?.didSelectHandler(viewModel!)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

// MARK: - SkeletonTableViewDataSource
extension SearchView: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
       return TrackTableViewCell.reuseId
    }
}

// MARK: - Private methods
extension SearchView {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

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
}
