//
//  LineView.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Foundation
import UIKit

/// Simple class to display line views the easier way possible
///  Can select the orientation and thickness
///  To display it horizontally or vertically
public final class SimpleLineView: NiblessView {
    
    public enum Orientation {
        case vertical
        case horizontal
    }
    
    private let orientation: Orientation
    private let thickness: CGFloat
    private let color: UIColor
    
    public init(
        orientation: Orientation = .horizontal,
        thickness: CGFloat = 1,
        color: UIColor = .gray
    ) {
        self.orientation = orientation
        self.thickness = thickness
        self.color = color
        super.init()
        
        backgroundColor = color
        setContentHuggingPriority(.required, for: .vertical)
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        applyStyles()
    }
    
    private func applyStyles() {
        
        switch orientation {
        case .vertical:
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: thickness)
            ])
        case .horizontal:
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: thickness)
            ])
        }
    }
}
