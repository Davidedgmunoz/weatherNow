//
//  LocationList.ItemView
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Combine
import Foundation
import UIKit

public extension LocationList {

    class ItemView: NiblessView {
        
        public var cancellable: AnyCancellable?
        public var viewModel: ViewModelItem? {
            didSet {
                cancellable?.cancel()
                cancellable = viewModel?.objectWillChange.receive(on: DispatchQueue.main)
                    .sink { [weak self] in self?.updateUI() }
                updateUI()
            }
        }
        init(viewModel: ViewModelItem) {
            self.viewModel = viewModel
            super.init()
            
            addSubview(stackView)
            addSubview(activityView)
            stackView.addArrangedSubview(topContentStackView)
            stackView.addArrangedSubview(contentStackView)
            
            topContentStackView.addArrangedSubview(weatherImage)
            topContentStackView.addArrangedSubview(nameLabel)
            
            contentStackView.addArrangedSubview(temperatureLabel)
            contentStackView.addArrangedSubview(realFeelLabel)
            [nameLabel, temperatureLabel, realFeelLabel].forEach {
                $0.numberOfLines = 2
                $0.lineBreakMode = .byWordWrapping
                $0.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
            }
            layer.cornerRadius = 8
            updateUI()
        }
        
        private lazy var activityView: ActivityView = {
            let activityView = ActivityView()
            activityView.backgroundColor = .white
            activityView.isHidden = true
            return activityView
        }()
        
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        private let topContentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .leading
            stackView.distribution = .fillProportionally
            return stackView
        }()
        
        private let contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .fill
            stackView.distribution = .fill
            return stackView
        }()
        
        private let nameLabel: CustomLabel = {
            let label = CustomLabel(style: .title)
            label.numberOfLines = 1
            label.textAlignment = .left
            label.setContentHuggingPriority(.defaultLow, for: .vertical)
            return label
        }()
        
        private let temperatureLabel: CustomLabel = {
            let label = CustomLabel(style: .subtitle)
            return label
        }()
        private let realFeelLabel: CustomLabel = {
            let label = CustomLabel(style: .subtitle)
            return label
        }()

        private let weatherImage: UIImageView = {
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        
        private func updateUI() {
            guard let viewModel else { return }
            activityView.isHidden = viewModel.state != .syncing
            nameLabel.text = viewModel.name
            temperatureLabel.text = viewModel.temperature
            realFeelLabel.text = viewModel.realFeel
            backgroundColor = viewModel.isSelected ? .orange.withAlphaComponent(0.2) : .white
            
            guard
                let image = viewModel.weatherImage, !image.isEmpty,
                let imageURL = URL(string: image)
            else { return }
            weatherImage.loadImage(from: imageURL)
        }
        
        public override func updateConstraints() {
            super.updateConstraints()
            let padding = Sizes.smallPadding
            NSLayoutConstraint.activate([
                weatherImage.heightAnchor.constraint(equalToConstant: 60),
                weatherImage.widthAnchor.constraint(equalToConstant: 60),
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
                
                activityView.topAnchor.constraint(equalTo: stackView.topAnchor),
                activityView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                activityView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                activityView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            ])

        }
    }
}

public class ActivityView: NiblessView {
    public override init() {
        super.init()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
    }
    let activityIndicator = UIActivityIndicatorView(style: .large)
    public override var isHidden: Bool {
        didSet {
            isHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        }
    }
    public override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
