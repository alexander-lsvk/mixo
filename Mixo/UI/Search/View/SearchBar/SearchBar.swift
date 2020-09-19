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
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.leftView = nil
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textAlignment = .left
        searchBar.searchTextField.font = FontFamily.SFProRounded.regular.font(size: 15.0)
        searchBar.searchTextField.textColor = UIColor(red: 35/255, green: 37/255, blue: 99/255, alpha: 1)
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
