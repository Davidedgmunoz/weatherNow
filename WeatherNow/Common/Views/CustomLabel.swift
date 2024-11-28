//
//  CustomLabel.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import UIKit

public enum LabelStyle {
    case title
    case subtitle
    case tertiary
}

public class CustomLabel: Label {
    private var labelStyle: LabelStyle = .title
    convenience public init(style: LabelStyle) {
        self.init()
        self.labelStyle = style
        switch labelStyle {
        case .title:
            textAlignment = .center
            font = UIFont.systemFont(ofSize: 16, weight: .heavy)
            textColor = .label
        case .subtitle:
            textAlignment = .left
            font = UIFont.systemFont(ofSize: 14, weight: .thin)
            textColor = .label
        case .tertiary:
            textAlignment = .left
            font = UIFont.systemFont(ofSize: 10, weight: .light)
            textColor = .tertiaryLabel
        }
    }
    
    public override init() {
        super.init()
    }
}
