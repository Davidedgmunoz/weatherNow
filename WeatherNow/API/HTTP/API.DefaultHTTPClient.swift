//
//  API.DefaultHTTPClient.swift
//  Project
//
//  Created by David Muñoz on 05/06/2021.
//

import Foundation
import Combine
import OSLog

enum APIError: Error {
    case invalidBody
    case invalidEndpoint
    case invalidURL
    case emptyData
    case invalidJSON
    case invalidResponse
    case statusCode(Int)
}

extension API {
    /// A regular implementation of a `HTTPClient` wrapping an actual `URLSession`, used outside of unit tests.
    public final class DefaultHTTPClient: API.HTTPClient {

        private let session: URLSession
        
        public init() {
            self.session = URLSession(configuration: .default)
        }
        
        /// As always, it's safe to use a single encoder (it's just a factory).
        private lazy var jsonEncoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.dataEncodingStrategy = .base64
            return encoder
        }()
        
        // Note this is OK to reuse the same decoder it's just a factory creating new internal decoder instances
        // for every call of decode().
        private lazy var jsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        

        // MARK: - NewFetch
        private var cancellables = Set<AnyCancellable>()

        private func newFetchData<Response: Decodable>(
            method: String,
            url: URL,
            queryParams: [String: String],
            responseType: Response.Type,
            headers: [String: String],
            body: @autoclosure () throws -> (contentType: String, data: Data)?
        ) async throws -> AnyPublisher<Response, Error> {

            let subject = PassthroughSubject<Response, Error>()
            guard let urlWithQuery = urlWithParamsInQuery(url: url, params: queryParams) else {
                // Original URLs we deal with here are static and cannot be malformed, crashing early otherwise.
                preconditionFailure()
            }

            var request = URLRequest(url: urlWithQuery)

            request.httpMethod = method

            if ((headers.first?.value.isEmpty) == nil){
                headers.forEach {
                    let (field, value) = $0
                    request.addValue(value, forHTTPHeaderField: field)
                }
            }
            request.addValue("openweathermap.org", forHTTPHeaderField: "Host")
            do {
                if let body = try body() {
                    request.httpBody = body.data
                    request.addValue(body.contentType, forHTTPHeaderField: "Content-Type")
                } else {
                    // Not every request has a body.
                }
            } catch {
                subject.send(completion: .failure(NSError()))
            }

            Logger.network.debug("\(request.curlString)")
            session.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    try self.validate(data, response)
                }.decode(type: Response.self, decoder: jsonDecoder)
                .mapError {
                    dump($0 as NSError)
                    return $0 as? APIError ?? .invalidBody
                }
                .sink { completion in
                    subject.send(completion: completion)
                } receiveValue: { decodable in
                    subject.send(decodable)
                }.store(in: &cancellables)

            return subject.eraseToAnyPublisher()
        }

        func validate(_ data: Data, _ response: URLResponse) throws -> Data {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw APIError.statusCode(httpResponse.statusCode)
            }
            return data
        }

        // MARK: - Fetch
        
        private func fetchData<T: Decodable> (
            method: String,
            url: URL,
            queryParams: [String: String],
            headers: [String: String],
            body: @autoclosure () throws -> (contentType: String, data: Data)?,
            completion: @escaping ResultCallback<T>) {
            
            // MARK: -
            guard let urlWithQuery = urlWithParamsInQuery(url: url, params: queryParams) else {
                // Original URLs we deal with here are static and cannot be malformed, crashing early otherwise.
                preconditionFailure()
            }

            var request = URLRequest(url: urlWithQuery)
            request.httpMethod = method

            headers.forEach {
                let (field, value) = $0
                request.addValue(value, forHTTPHeaderField: field)
            }

            do {
                if let body = try body() {
                    request.httpBody = body.data
                    request.addValue(body.contentType, forHTTPHeaderField: "Content-Type")
                } else {
                    // Not every request has a body.
                }
            } catch {
                completion(.failure(NSError()))
            }

            // MARK: -

                let task = session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    completion(.failure(error! as NSError))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(NSError()))
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let error = NSError(domain: "Unsuccessful", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601

                    guard let data = data, !data.isEmpty else {
                        completion(.success(nil))
                        return
                    }
                    var resultObject: T
                    resultObject = try decoder.decode(T.self, from: data)

                    completion(.success(resultObject))

                } catch let error {
                    completion(.failure(error))
                    return
                }
            }
            task.resume()
        }

        private func urlWithParamsInQuery(url: URL, params: [String: String]) -> URL? {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
            // The query part might be present and we must retain it, [https://tools.ietf.org/html/rfc6749#section-3.1].
            components.queryItems = (components.queryItems ?? []) + params.map { URLQueryItem(name: $0.0, value: $0.1) }
            return components.url
        }
        
        // MARK: -

        public func get<Response>(
            url: URL,
            queryParams: [String : String],
            headers: [String : String],
            responseType: Response.Type,
            completion: @escaping (Result<Response>) -> Void
        ) where Response : Decodable {
            fetchData(
                method: "GET",
                url: url,
                queryParams: queryParams,
                headers: headers,
                body: nil,
                completion: completion
            )
        }

        public func get<Response: Decodable>(
            url: URL,
            queryParams: [String : String],
            headers: [String : String],
            responseType: Response.Type
        ) async throws -> AnyPublisher<Response, Error> {
            try await newFetchData(
                method: "GET",
                url: url,
                queryParams: queryParams,
                responseType: Response.self,
                headers: headers,
                body: nil
            )
        }

        
        public func post<Response>(
            url: URL,
            urlEncodedBody: [String : String],
            headers: [String : String],
            completion: (Result<Response>) -> Void
        ) where Response: Decodable {
            
        }

        public func post<Request: Encodable, Response: Decodable>(
            url: URL,
            request: Request,
            headers: [String : String],
            responseType: Response.Type
        ) async throws -> AnyPublisher<Response, Error> {
            try await newFetchData(
                method: "POST",
                url: url,
                queryParams: [:],
                responseType: Response.self,
                headers: headers,
                body: ("application/json", try jsonEncoder.encode(request))
            )
        }

        public func post<Request, Response>(
            url: URL,
            request: Request,
            headers: [String : String],
            responseType: Response.Type,
            completion: @escaping (Result<Response>) -> Void
        ) where Request : Encodable, Response : Decodable {
            fetchData(
                method: "POST",
                url: url,
                queryParams: [:],
                headers: headers,
                body: ("application/json", try jsonEncoder.encode(request)),
                completion: completion
            )
        }
        
        public func put<Request, Response>(
            url: URL,
            request: Request,
            headers: [String : String],
            responseType: Response.Type,
            completion: (Result<Response>
            ) -> Void
        ) where Request : Encodable, Response : Decodable {
            
        }
        
        public func delete<Response>(
            url: URL,
            queryParams: [String : String],
            headers: [String : String],
            responseType: Response.Type,
            completion: (Result<Response>) -> Void
        ) where Response : Decodable {
            
        }
    }
}


extension URLRequest {
    var curlString: String {
        var components = ["curl -k"]
        
        if let httpMethod = self.httpMethod {
            components.append("-X \(httpMethod)")
        }
        
        for (header, value) in self.allHTTPHeaderFields ?? [:] {
            components.append("-H \"\(header): \(value)\"")
        }
        
        if let httpBody = self.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }
        
        if let url = self.url {
            components.append("\"\(url.absoluteString)\"")
        }
        
        return components.joined(separator: " \\\n")
    }
}
