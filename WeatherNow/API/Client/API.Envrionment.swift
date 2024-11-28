//
//  API.Envrionment.swift
//  Project
//
//  Created by David Muñoz on 05/06/2021.
//

import Foundation

// TODO: This needs to be updated depending on the project
extension API {
    
    public struct Environment {

        /// Name of this environment just for diagnostics.
        public let name: String

        public let clientsAPI: ClientsAPI

        public struct ClientsAPI {
            public let baseURL: URL
            public let apiKey: String
        }
    }
}


// MARK: -

extension API.Environment {

    public private(set) static var qa: API.Environment = .init(
        name: "PROD",
        clientsAPI: .init(
            baseURL: URL(string:"https://api.openweathermap.org/")!,
            apiKey: "dfdba738d0905e0d5d5b7f9d5eb6e17d"
        )
    )
    
    public private(set) static var prod: API.Environment = .init(
        name: "PROD",
        clientsAPI: .init(
            baseURL: URL(string:"https://api.openweathermap.org/")!,
            apiKey: "dfdba738d0905e0d5d5b7f9d5eb6e17d"
        )
    )
}

