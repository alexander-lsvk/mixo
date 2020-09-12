//
//  MessageController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/23/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation
import SwiftMessages

protocol MessageController {
    func show(message: Message, body: String)
}

extension MessageController {
    func show(message: Message, body: String) {
        let view = MessageView.viewFromNib(layout: .cardView)

        let theme: Theme
        let iconText: String

        switch message {
        case .error:
            theme = .error
            iconText = "⚠️"
        case .success:
            theme = .success
            iconText = "✅"
        }

        view.configureTheme(theme)
        view.configureDropShadow()

        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: .normal)
        SwiftMessages.defaultConfig = config
        
        view.button?.isHidden = true

        view.configureContent(title: message.title, body: body, iconText: iconText)
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)

        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 8

        SwiftMessages.show(view: view)
        print(body)
    }
}
