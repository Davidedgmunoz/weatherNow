//
//  LocationRegistration.ViewController
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Combine
import Foundation
import UIKit

public extension LocationRegistration {
    class ViewController: NiblessViewController, ActivityPresentable {
        
        private let viewModel: ViewModelProtocol
        init(viewModel: ViewModelProtocol) {
            self.viewModel = viewModel
            super.init()
        }

        private var cancellables: Set<AnyCancellable> = .init()
        public override func viewDidLoad() {
            super.viewDidLoad()
            title = "locationRegistration.title".localized
            
            guard let _view else { return }
            _view.searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
            _view.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
            _view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
            
            _view.latitudeTextField.textPublisher
                .merge(with: _view.longitudeTextField.textPublisher)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                self?.updateUI()
            }).store(in: &cancellables)
            
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.updateUI()
                }.store(in: &cancellables)
            
            viewModel.actionPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.handleAction($0) }
                .store(in: &cancellables)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
            _view.addGestureRecognizer(tapGestureRecognizer)
        }

        private var _view: View?
        public override func loadView() {
            let view = View()
            _view = view
            self.view = view
        }

        // MARK: - Function
        
        private func updateUI() {
            guard viewModel.state != .syncing else {
                presentActivity()
                return
            }
            dismissActivity()
            _view?.cityNameTextField.text = viewModel.cityName
            _view?.registerButton.isEnabled = viewModel.cityName != nil
            guard
                let _view,
                let latitudeText = _view.latitudeTextField.text,
                let longitudeText = _view.longitudeTextField.text
            else { return }
            _view.searchButton.isEnabled = !latitudeText.isEmpty && !longitudeText.isEmpty
        }
        
        @objc private func viewTapped() {
            view.endEditing(true)
        }
        
        @objc private func searchButtonTapped() {
            guard
                let lat = Double(_view?.latitudeTextField.text ?? ""),
                let lon = Double(_view?.longitudeTextField.text ?? "")
            else { return }
            viewModel.searchLocation(forLat: lat, andLon: lon)
        }
        
        @objc private func registerButtonTapped() {
            viewModel.save()
        }
        
        @objc private func cancelButtonTapped() {
            dismiss(animated: true)
        }

        private func handleAction(_ action: Action) {
            switch action {
            case .didFailToAddLocation:
                showAlert(title: "Error", message: "locationRegistration.addFailureMessage".localized)
            case .didAddLocation:
                showAlert(title: "Success", message: "locationRegistration.addSuccessMessage".localized)
            }
        }
        
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // MARK: - View
        fileprivate class View: NiblessView {
            override init() {
                super.init()
                translatesAutoresizingMaskIntoConstraints = true
                stackView.addArrangedSubview(cityNameTextField)
                stackView.addArrangedSubview(latitudeTextField)
                stackView.addArrangedSubview(longitudeTextField)
                stackView.addArrangedSubview(searchButton)
                stackView.setCustomSpacing(Sizes.extraSmallPadding, after: searchButton)
                stackView.addArrangedSubview(searchDescriptionLabel)

                
                // Add the stack view to the scroll view
                scrollView.addSubview(stackView)
                addSubview(scrollView)
                addSubview(buttonStackView)
                backgroundColor = Colors.backgroundColor
            }
            
            let cityNameTextField: TextField = {
                let textField = TextField()
                textField.placeholder = "locationRegistration.CityName".localized
                textField.isEnabled = false
                return textField
            }()
            
            // For these textfield we could add a toolbar to use the number pad,
            // and be able to assign the negative symbol
            let latitudeTextField: TextField = {
                let textField = TextField()
                textField.placeholder = "locationRegistration.EnterLatitude".localized
                textField.keyboardType = .numbersAndPunctuation
                return textField
            }()
            
            let longitudeTextField: TextField = {
                let textField = TextField()
                textField.placeholder = "locationRegistration.EnterLongitude".localized
                textField.keyboardType = .numbersAndPunctuation
                return textField
            }()
            
            let searchButton: CustomButton = {
                let button = CustomButton()
                button.setTitle("locationRegistration.UpdateLocation".localized, for: .normal)
                button.isEnabled = false
                return button
            }()
            
            let searchDescriptionLabel: UILabel = {
                let label = UILabel()
                label.textColor = .secondaryLabel
                label.numberOfLines = 0
                label.textAlignment = .center
                label.font = .preferredFont(forTextStyle: .caption1)
                label.text = "locationRegistration.updateLocationDesc".localized
                return label
            }()

            lazy var buttonStackView: UIStackView = {
                let stackView = UIStackView(arrangedSubviews: [cancelButton, searchButton])
                stackView.axis = .horizontal
                stackView.distribution = .fillEqually
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.spacing = 16
                return stackView
            }()
            
            let cancelButton: CustomButton = {
                let button = CustomButton()
                button.setTitle("locationRegistration.Cancel".localized, for: .normal)
                return button
            }()
            
            let registerButton: CustomButton = {
                let button = CustomButton()
                button.setTitle("locationRegistration.RegisterLocation".localized, for: .normal)
                button.isEnabled = false
                return button
            }()
            
            let scrollView: UIScrollView = {
                let scrollView = UIScrollView()
                scrollView.translatesAutoresizingMaskIntoConstraints = false
                return scrollView
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 16
                stackView.alignment = .fill
                stackView.distribution = .equalSpacing
                stackView.translatesAutoresizingMaskIntoConstraints = false
                return stackView
            }()

            override func updateConstraints() {
                super.updateConstraints()
                let spacing = Sizes.normalPadding
                let heights: CGFloat = 44
                
                NSLayoutConstraint.activate([
                    // Scroll view constraints
                    scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -spacing),

                    // Register button
                    buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    buttonStackView.heightAnchor.constraint(equalToConstant: heights),
                    buttonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: spacing),
                    buttonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
                    cityNameTextField.heightAnchor.constraint(equalToConstant: heights),
                    latitudeTextField.heightAnchor.constraint(equalToConstant: heights),
                    longitudeTextField.heightAnchor.constraint(equalToConstant: heights),
                    searchButton.heightAnchor.constraint(equalToConstant: heights),
                    
                    // Stack view constraints
                    stackView.widthAnchor.constraint(
                        equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -spacing * 2
                    ),
                    stackView.topAnchor.constraint(
                        equalTo: scrollView.contentLayoutGuide.topAnchor, constant: spacing
                    ),
                    stackView.bottomAnchor.constraint(
                        equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -spacing
                    ),
                    stackView.leadingAnchor.constraint(
                        equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: spacing
                    ),
                    stackView.trailingAnchor.constraint(
                        equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -spacing
                    ),
                    stackView.widthAnchor.constraint(
                        equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -spacing
                    )
                ])

            }
        }
    }
}
