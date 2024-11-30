//
//  main.swift
//  WeatherNow
//
//  Created by David Muñoz on 30/11/2024.
//

import Foundation
import UIKit
let appDelegateClass: AnyClass =
NSClassFromString("TestingAppDelegate") ?? AppDelegate.self
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(appDelegateClass)
)
