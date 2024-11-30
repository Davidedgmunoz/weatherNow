//
//  TestingAppDelegate.swift
//  WeatherNow
//
//  Created by David Muñoz on 30/11/2024.
//

import Foundation
import UIKit
@objc(TestingAppDelegate)
class TestingAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func applicationDidFinishLaunching(_ application: UIApplication) {
        // add configuration to avoid running on test
        Core()
        window = nil
    }
}
