// MIT License
//
// Copyright (c) 2020 Ralf Ebert
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

import Combine
import Foundation
import os
import Resolver

class TodoModel: ObservableObject {

    @Published var todo: Todo

    @Injected private var endpoints: TodoEndpoints
    private var cancellables = Set<AnyCancellable>()

    /// Create a view model for an existing todo
    init(todo: Todo, autosave: Bool) {
        self.todo = todo

        if autosave {
            $todo
                .dropFirst()
                .debounce(for: 1.0, scheduler: RunLoop.main)
                .sink { _ in
                    self.save()
                }
                .store(in: &self.cancellables)
        }
    }

    /// Create a view model for a new todo
    convenience init() {
        self.init(todo: Todo(title: ""), autosave: false)
    }

    func save() {
        self.endpoints.save(todo: self.todo).load { result in
            switch result {
                case let .success(todo):
                    os_log("Saved: %@", type: .info, String(describing: todo))
                case let .failure(error):
                    os_log("Error saving: %@", type: .error, String(describing: error))
            }
        }
    }

}
