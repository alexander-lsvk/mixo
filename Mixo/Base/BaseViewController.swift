//
//  BaseViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

class BaseViewController<P: Presenter>: UIViewController, StatusController, MessageController {
    public var presenter: P
    
    public init(presenter: P) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.baseViewHandler = BaseViewHandler(setTitle: { [weak self] title in
            self?.title = title

        }, showStatus: { [weak self] status, animated in
            self?.show(status: status, animated: animated)

        }, hideStatus: { [weak self] animated in
            self?.hideStatus(animated: animated)

        }, showMessage: { [weak self] message, body in
            self?.show(message: message, body: body)
        })

        presenter.didBindController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }

    // MARK: - StatusViewContainer
    var onView: StatusViewContainer { view }
}

