//
//  WeatherDetails.ForecastItemView.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import UIKit

public extension WeatherDetails {
    class ForecastItemView: NiblessView {
        
        var viewModel: ForecastItemViewModel? {
            didSet { updateUI() }
        }
        
        public override init() {
            super.init()
            
            addSubview(contentStackView)
            addSubview(lineView)
            descriptionLabel.numberOfLines = 2
            dateLabel.numberOfLines = 2
            dateLabel.textAlignment = .center
            [dateLabel, weatherIcon, temperatureLabel, descriptionLabel].forEach {
                contentStackView.addArrangedSubview($0)
            }
            backgroundColor = .white
        }
        
        private let contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        private let dateLabel: CustomLabel = .init(style: .subtitle)
        private let temperatureLabel: CustomLabel = .init(style: .subtitle)
        private let descriptionLabel: CustomLabel = .init(style: .tertiary)
        private let weatherIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        private let lineView = SimpleLineView()

        private func updateUI() {
            guard let viewModel else { return }
            dateLabel.text = viewModel.date
            weatherIcon.loadImage(from: viewModel.iconURL)
            temperatureLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            temperatureLabel.text = viewModel.temperatures
            descriptionLabel.text = viewModel.weatherDescription
        }
        
        // MARK: - updateConstraints
        
        public override func updateConstraints() {
            super.updateConstraints()
            let padding: CGFloat = Sizes.extraSmallPadding
            NSLayoutConstraint.activate([
                contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                contentStackView.topAnchor.constraint(equalTo: topAnchor),
                contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                contentStackView.heightAnchor.constraint(equalToConstant: (80)),
                
                lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
                lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
                lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
    }
    
}
