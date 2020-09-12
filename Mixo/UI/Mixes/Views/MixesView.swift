//
//  MixesView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import UIKit
import SwipeCellKit
import SkeletonView

final class MixesView: UIView, XibLoadable {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addToNewMixButton: UIButton!

    @IBAction private func didTapAddToNewMixButton() { addToNewMixHandler?() }

    private var editMixNameHandler: ((_ mixId: String, _ oldName: String) -> Void)?
    private var addToNewMixHandler: (() -> Void)?

    private var viewModels: [MixViewModel]?

    private let skeletableViewsNumber = 10

    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()

        addToNewMixButton.showAnimatedGradientSkeleton()
    }
        
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0)

        register(reusableCell: MixTableViewCell.self)
    }

    func update(with viewModel: MixesViewModel?) {
        viewModels = viewModel?.mixViewModels
        editMixNameHandler = viewModel?.editMixNameHandler

        if let addToNewMixHandler = viewModel?.addToNewMixHandler {
            self.addToNewMixHandler = addToNewMixHandler
            addToNewMixButton.hideSkeleton()
        }

        tableView.reloadData()
    }

    func updateViewModels(with viewModels: [MixViewModel]) {
        self.viewModels = viewModels
        tableView.reloadData()
    }

    func showAddToNewMixButton() {
        addToNewMixButton.isHidden = false
        tableView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 78.0, right: 0.0)
    }
}

//MARK: - Private methods
extension MixesView {
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

//MARK: - TableViewDataSource & TableViewDelegate
extension MixesView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels?.count ?? skeletableViewsNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MixTableViewCell.reuseId) as? MixTableViewCell
        let viewModel = viewModels?[indexPath.row]
        cell?.update(with: viewModel)
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels?[indexPath.row]
        viewModel?.didSelectHandler?()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

// MARK: - SkeletonTableViewDataSource
extension MixesView: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
       return MixTableViewCell.reuseId
    }
}

// MARK: - MixesView
extension MixesView: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let viewModel = viewModels?[indexPath.row], orientation == .right else { return nil }

        // Delete
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
            viewModel.didRemoveItemHandler(self.viewModels?.count ?? 0)
            self.viewModels?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = .systemRed
        deleteAction.hidesWhenSelected = true
        deleteAction.font = FontFamily.SFProRounded.regular.font(size: 14.0)

        // Edit
        let editAction = SwipeAction(style: .default, title: "Edit") { _, indexPath in
            viewModel.didUpdateMixName = { [weak self] name in
                viewModel.name = name
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            self.editMixNameHandler?(viewModel.id, viewModel.name)
        }
        editAction.image = UIImage(named: "edit")
        editAction.backgroundColor = .systemOrange
        editAction.hidesWhenSelected = true
        editAction.font = FontFamily.SFProRounded.regular.font(size: 14.0)

        return [deleteAction, editAction]
    }
}
