//
//  String+Localizable.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation

public extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
