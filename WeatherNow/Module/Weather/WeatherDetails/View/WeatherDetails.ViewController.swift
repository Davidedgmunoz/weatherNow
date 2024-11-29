//
//  WeatherDetails.ViewController.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Combine
import Foundation
import UIKit

public extension WeatherDetails {
    class ViewController: NiblessViewController, UITableViewDelegate, UITableViewDataSource {
        private let viewModel: ViewModel
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        private var _view: _View? { return view as? _View }
        public override func loadView() {
            view = _View()
        }

        private var cancellables: Set<AnyCancellable> = []
        override public func viewDidLoad() {
            super.viewDidLoad()
            setupNavigationBarButton()
            
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.updateUI() }
                .store(in: &cancellables)
            viewModel.actionPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.handleAction($0) }
                .store(in: &cancellables)
            _view?.tableView.dataSource = self
            _view?.tableView.delegate = self
            
            _view?.emptyView.takeMeThere = { [weak self] in self?.viewModel.openList() }
        }

        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            title = "Weather details"
            viewModel.doSync()
        }

        private func handleAction(_ action: Action) {
            switch action {
            case .openList(let viewModel):
                let vc = LocationList.ViewController(viewModel: viewModel)
                navigationController?.pushViewController(vc, animated: true)
            case .presentNoLocationAddedView:
                _view?.emptyView.isHidden = false
            }
        }
        private func updateUI() {
            guard viewModel.state != .syncing else { return }
            _view?.emptyView.isHidden = true
            _view?.headerView.viewModel = viewModel.headerViewModel
            _view?.tableView.reloadData()
        }

        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            viewModel.forecastItems.count
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let viewModel = viewModel.forecastItems[indexPath.row]
            
            let cell = tableView.dequeueReusableCell("weather") {
                DefaultViewWrappingCell(
                    withView: ForecastItemView(),
                    reuseIdentifier: $0,
                    vInset: Sizes.normalPadding, hInset: 0
                )
            }
            cell.wrappedView.viewModel = viewModel
            cell.backgroundColor = .clear
            return cell
        }

        private func setupNavigationBarButton() {
            let listButton = UIBarButtonItem(
                image: UIImage(systemName: "list.bullet"),
                style: .plain,
                target: self,
                action: #selector(didTapListButton)
            )
            navigationItem.rightBarButtonItem = listButton
        }
        
        @objc private func didTapListButton() {
            viewModel.openList()
        }
        
        // MARK: - View

        fileprivate class _View: NiblessView {
            override init() {
                super.init()
                
                translatesAutoresizingMaskIntoConstraints = true
                backgroundColor = Colors.backgroundColor
                emptyView.isHidden = true
                titleLabel.text = "weatherDetails.title".localized

                addSubview(headerView)
                addSubview(titleLabel)
                addSubview(tableView)
                addSubview(emptyView)

            }
            
            fileprivate var emptyView: EmptyView = .init()
            private let titleLabel: CustomLabel = .init(style: .title)
            fileprivate let headerView: HeaderView = .init()
            let tableView: UITableView = {
                let tableView = UITableView(frame: .zero, style: .plain)
                tableView.contentInset = .init(
                    top: Sizes.normalPadding,
                    left: 0,
                    bottom: Sizes.smallPadding,
                    right: 0
                )
                tableView.separatorStyle = .none
                tableView.translatesAutoresizingMaskIntoConstraints = false
                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 80
                return tableView
            }()

            
            override func updateConstraints() {
                super.updateConstraints()
                
                NSLayoutConstraint.activate([
                    emptyView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    emptyView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    emptyView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    emptyView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    
                    headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    headerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    
                    titleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Sizes.smallPadding),
                    titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    
                    tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                    tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                ])
            }
        }
    }
}
