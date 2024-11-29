//
//  WeatherDetails.EmptyView.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Foundation
import UIKit

public extension WeatherDetails {
    class EmptyView: NiblessView {
        
        var takeMeThere: (() -> Void)?
        public override init() {
            super.init()
            backgroundColor = .white
            
            label.text = "weatherDetails.emptyViewTitle".localized
            label.numberOfLines = 0
            label.textAlignment = .center
            takeMeThereButton.setTitle("weatherDetails.emptyViewButton".localized, for: .normal)
            takeMeThereButton.addTarget(self, action: #selector(takeMeThereTapped), for: .touchUpInside)
            addSubview(label)
            addSubview(takeMeThereButton)
        }
        
        private let label: CustomLabel = .init(style: .title)
        private let takeMeThereButton = CustomButton()
        @objc private func takeMeThereTapped() {
            takeMeThere?()
        }
        
        // MARK: - UpdateConstraints
        public override func updateConstraints() {
            super.updateConstraints()
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Sizes.largePadding),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Sizes.largePadding),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Sizes.largePadding),
                takeMeThereButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: .init(16)),
                takeMeThereButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                takeMeThereButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: .init(0.6))
            ])
        }
    }
}
