//
//  CustomButton.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation
import UIKit

// Because there is a time limit im going with a regular button,
// but usually i'd like to go for an UIControl and customize by myself

class CustomButton: Button {
    
    override init() {
        _backgroundColor = Colors.buttonBackgroundColor
        super.init()
        layer.cornerRadius = Sizes.regularCornerRadius
        layer.borderColor = UIColor.orange.cgColor
        backgroundColor = _backgroundColor
        setTitleColor(Colors.buttonTextColor, for: .normal)
        layer.borderWidth = 1
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? _backgroundColor.withAlphaComponent(0.3) : _backgroundColor
        }
    }
    private var _backgroundColor: UIColor
    private let _disabledBackgroundColor: UIColor = .gray.withAlphaComponent(0.6)
    override var isEnabled: Bool {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if isEnabled {
            if isHighlighted {
                backgroundColor = _backgroundColor.withAlphaComponent(0.3)
            } else {
                backgroundColor = _backgroundColor
            }
        } else {
            backgroundColor = _disabledBackgroundColor
        }
    }
}
