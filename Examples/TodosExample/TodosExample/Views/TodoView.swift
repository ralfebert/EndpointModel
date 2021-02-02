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

import SwiftUI

struct TodoView: View {
    @ObservedObject var model: TodoModel
    var onCommit: (Result<Todo, InputError>) -> Void = { _ in }

    var body: some View {
        HStack {
            Image(systemName: "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    // TODO: toggle completion
                }
            TextField(
                "Todo",
                text: $model.todo.title,
                onCommit: {
                    if !self.model.todo.title.isEmpty {
                        self.onCommit(.success(self.model.todo))
                    } else {
                        self.onCommit(.failure(.empty))
                    }
                }
            )
        }
    }
}

enum InputError: Error {
    case empty
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TodoView(model: TodoModel(todo: Todo(id: 5, title: "Buy soy milk"), autosave: false))
            TodoView(model: TodoModel())
        }.previewLayout(.sizeThatFits)
    }
}
