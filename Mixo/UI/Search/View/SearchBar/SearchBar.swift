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
    
    @IBOutlet var searchBar: UISearchBar!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override func awakeFromNib() {
        searchBar.searchTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        searchBar.autocorrectionType = .no
        searchBar.backgroundColor = .clear
        searchBar.tintColor = .clear
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.leftView = nil
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textAlignment = .left
    }
    
    func becomeSearchFirstResponder() {
        DispatchQueue.main.async {
            self.searchBar.becomeFirstResponder()
        }
    }
}

// MARK: - Private methods
extension SearchBar {
    @objc
    private func textFieldEditingDidChange(_ sender: Any) {
        searchQueryHandler?(searchBar.text ?? "")
    }
}
