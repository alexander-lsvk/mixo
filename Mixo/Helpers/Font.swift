//
//  Font.swift
//  Mixo
//
//  Created by Alexander on 08.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

import Foundation
import UIKit

typealias Font = UIFont

// MARK: - Font
enum FontFamily {
    enum SFProRounded {
        static let black = FontConvertible(name: "SFProRounded-Black", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Black.otf")
        static let bold = FontConvertible(name: "SFProRounded-Bold", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Bold.otf")
        static let heavy = FontConvertible(name: "SFProRounded-Heavy", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Heavy.otf")
        static let light = FontConvertible(name: "SFProRounded-Light", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Light.otf")
        static let medium = FontConvertible(name: "SFProRounded-Medium", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Medium.otf")
        static let regular = FontConvertible(name: "SFProRounded-Regular", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Regular.otf")
        static let semibold = FontConvertible(name: "SFProRounded-Semibold", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Semibold.otf")
        static let thin = FontConvertible(name: "SFProRounded-Thin", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Thin.otf")
        static let ultralight = FontConvertible(name: "SFProRounded-Ultralight", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Ultralight.otf")
        static let all: [FontConvertible] = [black, bold, heavy, light, medium, regular, semibold, thin, ultralight]
    }

    static let allCustomFonts: [FontConvertible] = [SFProRounded.all].flatMap { $0 }

    static func registerAllCustomFonts() {
        allCustomFonts.forEach { $0.register() }
    }
}

// MARK: - Implementation Details

struct FontConvertible {
    let name: String
    let family: String
    let path: String

    func font(size: CGFloat) -> Font! {
        return Font(font: self, size: size)
    }

    func register() {
        guard let url = url else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    fileprivate var url: URL? {
        let bundle = Bundle(for: BundleToken.self)
        return bundle.url(forResource: path, withExtension: nil)
    }
}

extension Font {
    convenience init!(font: FontConvertible, size: CGFloat) {
        if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
            font.register()
        }
        self.init(name: font.name, size: size)
    }
}

final class BundleToken {}
