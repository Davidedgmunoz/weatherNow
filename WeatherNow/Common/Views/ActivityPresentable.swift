//
//  ActivityPresentable.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import UIKit

/// Common protocol for views that has loading screens
public protocol ActivityPresentable {
    func presentActivity()
    func dismissActivity()
}

/// Default implementation to present and hide an orange `ActivityIndicator`,
/// the `ActivityIndicator` is placed in the center of a `ViewController`
public extension ActivityPresentable where Self: UIViewController {
    func presentActivity() {
        if let activityIndicator = findActivity() {
            activityIndicator.startAnimating()
        } else {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            
            activityIndicator.color = Colors.matteYellow
            
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
    
    func dismissActivity() {
        findActivity()?.stopAnimating()
    }
    
    private func findActivity() -> UIActivityIndicatorView? {
        return view.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }
}
