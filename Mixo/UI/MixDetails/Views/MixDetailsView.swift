//
//  MixDetailsView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/13/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import UIKit
import SwipeCellKit
import SwiftReorder

final class MixDetailsView: UIView, XibLoadable {
    @IBOutlet private var tableView: UITableView!

    private var viewModels = [MixDetailViewModel]()

    private var reorderListHandler: ((_ sourceIndex: Int, _ destinationIndex: Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }

    func update(with viewModels: [MixDetailViewModel]) {
        self.viewModels = viewModels
        tableView.reloadData()
    }

    func setReorderListHandler(_ handler: @escaping (_ sourceIndex: Int, _ destinationIndex: Int) -> Void) {
        reorderListHandler = handler
    }
}

// MARK: - Private methods
extension MixDetailsView {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reorder.delegate = self

        register(reusableCell: MixDetailTableViewCell.self)
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

//MARK: - TableViewDataSource & TableViewDelegate
extension MixDetailsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: MixDetailTableViewCell.reuseId) as! MixDetailTableViewCell
        let viewModel = viewModels[indexPath.row]
        cell.update(with: viewModel)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.row]
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { finished in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
                tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform.identity
            }) { _ in
                viewModel.didSelectHandler(viewModel)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

// MARK: - SwipeTableViewCellDelegate
extension MixDetailsView: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
            self.viewModels[indexPath.row].didRemoveItemHandler(self.viewModels.count)
            self.viewModels.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }

        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = .systemRed

        return [deleteAction]
    }
}

// MARK: - TableViewReorderDelegate
extension MixDetailsView: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let track = viewModels[sourceIndexPath.row]
        viewModels.remove(at: sourceIndexPath.row)
        viewModels.insert(track, at: destinationIndexPath.row)

        reorderListHandler?(sourceIndexPath.row, destinationIndexPath.row)
    }
}
