//
//  Logger.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation
import OSLog

extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let network = Logger(subsystem: subsystem, category: "[NETWORK]")
    static let model = Logger(subsystem: subsystem, category: "[MODEL]")
    
    public func log(message: String, tagging tag: String) {
        self.debug("\(message.tagging(tag))")
    }
}

extension String {
    
    func tagging(_ tag: String) -> String {
        return "[\(tag)]: \(self)"
    }
}
