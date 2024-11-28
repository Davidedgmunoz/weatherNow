//
//  LocationList.ViewController
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Combine
import Foundation
import UIKit

public extension LocationList {
    class ViewController: NiblessViewController, ActivityPresentable, UITableViewDelegate, UITableViewDataSource {
        let viewModel: ViewModel
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        
        private var cancellables: Set<AnyCancellable> = []
        
        // MARK: - Lifecycle
        
        private var _view: View { view as! View }
        public override func loadView() {
            view = View()
        }

        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            viewModel.syncIfNeeded()
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            title = "locationList.Title".localized
            _view.tableView.delegate = self
            _view.tableView.dataSource = self
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.updateUI()
                }.store(in: &cancellables)
            
            viewModel.actionsPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                self?.handleAction($0)
            }.store(in: &cancellables)
            
            let listButton = UIBarButtonItem(
                image: UIImage(systemName: "plus.circle"),
                style: .plain,
                target: self,
                action: #selector(didTapListButton)
            )
            
            // Add the button to the navigation bar's right side
            navigationItem.rightBarButtonItem = listButton
            
            updateUI()
        }

        // MARK: - Function
        
        private func updateUI() {
            guard viewModel.state != .syncing else { return }
            _view.tableView.reloadData()
        }

        @objc private func didTapListButton() {
            viewModel.openRegistration()
        }
        
        private func handleAction(_ action: Actions) {
            switch action {
            case .openRegistration(let viewModel):
                let vc = LocationRegistration.ViewController(viewModel: viewModel)
                navigationController?.present(vc, animated: true)
            }
        }
        // MARK: - TableViewDelegate & DataSource
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.items.count
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let viewModel = self.viewModel.items[indexPath.row]
            let cell = tableView.dequeueReusableCell("location") {
                DefaultViewWrappingCell(
                    withView: ItemView(viewModel: viewModel),
                    reuseIdentifier: $0,
                    vInset: Sizes.normalPadding, hInset: Sizes.normalPadding
                )
            }
            cell.wrappedView.viewModel = viewModel
            cell.backgroundColor = .clear
            return cell
        }
        
        public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let viewModel = self.viewModel.items[indexPath.row]
            viewModel.doSync()
        }
        
        func updateCellSize(for cell: UITableViewCell) {
            guard _view.tableView.indexPath(for: cell) != nil else { return }
            _view.tableView.beginUpdates()
            _view.tableView.endUpdates()
        }

        public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            viewModel.items[indexPath.row].select()
        }
        // MARK: - View

        fileprivate class View: NiblessView {
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
                tableView.estimatedRowHeight = 100
                return tableView
            }()
            
            // MARK: - Initialization
            override init() {
                super.init()
                setupView()
                translatesAutoresizingMaskIntoConstraints = true
                backgroundColor = Colors.backgroundColor
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // MARK: - Setup Methods
            private func setupView() {
                backgroundColor = .systemBackground
                addSubview(tableView)
            }
            
            override func updateConstraints() {
                super.updateConstraints()
                NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                ])
            }
        }
    }
}
