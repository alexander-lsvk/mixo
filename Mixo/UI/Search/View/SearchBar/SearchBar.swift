//
//  SearchBar.swift
//  Mixo
//
//  Created by Alexander Lisovik on 6/1/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit

final class SearchBar: UIView, XibOwnerLoadable {
    var searchQueryHandler: ((_ query: String) -> Void)?

    @IBOutlet var searchTextField: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override func awakeFromNib() {
        searchTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        searchTextField.autocorrectionType = .no
    }

    func becomeSearchFirstResponder() {
        DispatchQueue.main.async {
            self.searchTextField.becomeFirstResponder()
        }
    }
}

// MARK: - Private methods
extension SearchBar {
    @objc
    private func textFieldEditingDidChange(_ sender: Any) {
        searchQueryHandler?(searchTextField.text ?? "")
    }
}
