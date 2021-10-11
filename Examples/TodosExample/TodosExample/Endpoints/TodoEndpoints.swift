// MIT License
//
// Copyright (c) 2021 Ralf Ebert
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import EndpointModel
import Foundation
import os
import SweetURLRequest

struct Todo: Codable, Identifiable {
    var id: Int?
    var title: String
}

struct TodoEndpoints {
    static let shared = TodoEndpoints()

    private let url = URL(string: "https://jsonplaceholder.typicode.com/todos/")!
    private let urlSession: URLSession
    private let jsonDecoder = JSONDecoder()

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    var todos: Endpoint<[Todo]> {
        self.jsonEndpoint(request: URLRequest(method: .get, url: self.url))
    }

    func save(todo: Todo) -> Endpoint<Todo> {
        if let id = todo.id {
            return self.jsonEndpoint(request: try! URLRequest(method: .put, url: self.url(todoId: id), jsonBody: todo))
        } else {
            return self.jsonEndpoint(request: try! URLRequest(method: .post, url: self.url, jsonBody: todo))
        }
    }

    func url(todoId: Int) -> URL {
        URL(string: "\(todoId)", relativeTo: self.url)!
    }

    func delete(todoId: Int) -> Endpoint<Void> {
        let request = URLRequest(method: .delete, url: url(todoId: todoId))
        return self.endpoint(request: request)
            .map { _ in () } // throw away result data
            .eraseToAnyPublisher()
    }

    private func jsonEndpoint<T: Decodable>(request: URLRequest) -> Endpoint<T> {
        var request = request
        request.headers.accept = .json
        return self.endpoint(request: request)
            .tryMap { data -> T in
                try self.jsonDecoder.decode(T.self, from: data)
            }
            .eraseToAnyPublisher()
    }

    private func endpoint(request: URLRequest) -> Endpoint<Data> {
        self.urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                os_log("Got response: %i bytes for %s", type: .debug, data.count, String(describing: request.url))

                try self.validateResponse(data, response)

                return data
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private func validateResponse(_: Data?, _ response: URLResponse) throws {
        let httpResponse = response as! HTTPURLResponse

        let statusCode = HTTPStatusCode(httpResponse.statusCode)

        if statusCode.responseType == .success {
            return
        }

        throw statusCode
    }
}
