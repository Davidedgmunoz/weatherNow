//
//  WeatherDetails.HeaderView.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import UIKit
import Combine

public extension WeatherDetails {
    class HeaderView: NiblessView {
        var viewModel: HeaderViewModel? {
            didSet {
                cancellable = viewModel?.objectWillChange
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in self?.updateUI() }
                updateUI()
            }
        }

        init(viewModel: HeaderViewModel? = nil) {
            self.viewModel = viewModel
            super.init()
            
            [
                updateLabel, titleLabel, temperatureView,
                descriptionLabel
            ].forEach(stackView.addArrangedSubview(_:))
            addSubview(stackView)
            
            cancellable = viewModel?.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.updateUI() }
                
            updateUI()
            backgroundColor = .white.withAlphaComponent(0.2)
        }
        
        private var cancellable: AnyCancellable?
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 10
            return stackView
        }()
        
        private let temperatureView: TemperatureView = TemperatureView()
        private var updateLabel: CustomLabel = {
            let label = CustomLabel()
            label.font = .systemFont(ofSize: 14)
            label.textColor = .systemOrange
            return label
        }()
        
        private var titleLabel: CustomLabel = {
            let label = CustomLabel()
            label.font = .systemFont(ofSize: 30)
            label.textColor = .black
            label.numberOfLines = 2
            return label
        }()

        private var descriptionLabel: CustomLabel = {
            let label = CustomLabel(style: .subtitle)
            return label
        }()
        

        private func updateUI() {
            guard let viewModel else { return }
            updateLabel.text = viewModel.updateDate
            if viewModel.isUserLocation {
                let text = viewModel.title
                let attachment = NSTextAttachment()
                attachment.image = UIImage(systemName: "location.circle.fill")
                attachment.bounds = CGRect(x: 0, y: -2, width: 20, height: 20)
                let attributedString = NSMutableAttributedString(string: text)
                let iconString = NSAttributedString(attachment: attachment)
                attributedString.append(iconString)
                titleLabel.attributedText = attributedString
            } else {
                titleLabel.text = viewModel.title
            }
            temperatureView.label.text = viewModel.temperature
            descriptionLabel.text = viewModel.description
            guard let imageURL = viewModel.iconURL else { return }
            temperatureView.icon.loadImage(from: imageURL)

        }
        
        // MARK: - UpdateConstraints
        
        public override func updateConstraints() {
            super.updateConstraints()
            let padding = Sizes.smallPadding
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: 	padding),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
                stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        }
    }
    
    
    fileprivate class TemperatureView: NiblessView {
        override init() {
            super.init()
            [icon, label].forEach { addSubview($0) }
        }

        fileprivate var icon: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        fileprivate var label: CustomLabel = {
            let label = CustomLabel()
            label.font = .systemFont(ofSize: 35, weight: .light)
            label.textColor = .black
            return label
        }()
        
        override func updateConstraints() {
            let padding: CGFloat = Sizes.normalPadding
            super.updateConstraints()
            NSLayoutConstraint.activate([
                icon.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                icon.centerYAnchor.constraint(equalTo: centerYAnchor),
                icon.heightAnchor.constraint(equalToConstant: 50),
                icon.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
                
                label.topAnchor.constraint(equalTo: topAnchor, constant: padding),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: padding),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                label.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        }
    }
}
