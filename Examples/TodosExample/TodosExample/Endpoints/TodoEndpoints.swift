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

import Endpoint
import Foundation
import Resolver

struct Todo: Codable, Identifiable {
    var id: Int?
    var title: String
}

struct TodoEndpoints {

    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/")!
    @Injected var urlSession: URLSession
    @Injected var jsonDecoder: JSONDecoder

    var todos: Endpoint<[Todo]> {
        Endpoint(jsonRequest: URLRequest(url: self.url), urlSession: self.urlSession, jsonDecoder: self.jsonDecoder)
    }

    func save(todo: Todo) -> Endpoint<Todo> {
        if let id = todo.id {
            return Endpoint(jsonRequest: URLRequest(method: .put, url: URL(string: String(id), relativeTo: self.url)!, jsonBody: todo), urlSession: self.urlSession, jsonDecoder: self.jsonDecoder)
        } else {
            return Endpoint(jsonRequest: URLRequest(method: .post, url: self.url, jsonBody: todo), urlSession: self.urlSession, jsonDecoder: self.jsonDecoder)
        }
    }

    func delete(todoId: Int) -> Endpoint<Void> {
        Endpoint(request: URLRequest(method: .delete, url: URL(string: "\(todoId)", relativeTo: self.url)!), urlSession: self.urlSession)
    }

}
