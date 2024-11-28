//
//  API.HTTPClient.swift
//  Project
//
//  Created by David Muñoz on 05/06/2021.
//

import Foundation
import Combine

public enum Result<Value> {
    case success(Value?)
    case failure(Error)
}

public typealias ResultCallback<Value> = (Result<Value>) -> Void

extension API {

    /// A simple wrapper of `URLSession` that would allow us to mock the network layer when needed.
    ///
    /// This is not supposed to be a generic HTTP client but the opposite — a narrow set of actually used methods
    /// should be exposed. For example, if the result is always JSON-encoded, then there should be no way of getting
    /// raw `Data`. This would allow for easier mocking, e.g. avoid decoding/encoding binary data.
    public typealias HTTPClient = API_HTTPClient

    /// Used to indicate that no response body is expected. For special APIs.
    public struct EmptyResponse: Decodable {}
}

public protocol API_HTTPClient: AnyObject {

    typealias EmptyResponse = API.EmptyResponse

    /// - Note: The caller must keep the returned value or the request is going to be cancelled automatically.
    ///
    /// - Parameter queryParams: Parameters to be added to the query part of the `url`.
    ///   Note that a mock should look only at these ignoring other parameters possibly already encoded in the `url`.
    func get<Response: Decodable>(
        url: URL,
        queryParams: [String: String],
        headers: [String: String],
        responseType: Response.Type,
        completion: @escaping ResultCallback<Response>
    )

    func get<Response: Decodable>(
        url: URL,
        queryParams: [String : String],
        headers: [String : String],
        responseType: Response.Type
    ) async throws -> AnyPublisher<Response, Error>

    /// - Note: The caller must keep the returned value or the request is going to be cancelled automatically.
    ///
    /// - Parameter urlEncodedBody: Parameters to be urlencoded into the body of the request.
    func post<Response: Decodable>(
        url: URL,
        urlEncodedBody: [String: String],
        headers: [String: String],
        completion: ResultCallback<Response>
    )

    func post<Request: Encodable, Response: Decodable>(
        url: URL,
        request: Request,
        headers: [String: String],
        responseType: Response.Type,
        completion: @escaping ResultCallback<Response>
    )

    func post<Request: Encodable, Response: Decodable>(
        url: URL,
        request: Request,
        headers: [String: String],
        responseType: Response.Type
    ) async throws -> AnyPublisher<Response, Error>

    func put<Request: Encodable, Response: Decodable>(
        url: URL,
        request: Request,
        headers: [String: String],
        responseType: Response.Type,
        completion: ResultCallback<Response>
    )

    func delete<Response: Decodable>(
        url: URL,
        queryParams: [String: String],
        headers: [String: String],
        responseType: Response.Type,
        completion: ResultCallback<Response>
    )
}
