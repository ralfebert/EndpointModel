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
import SwiftUI

struct TodosListView: View {

    @ObservedObject var model = TodosModel()

    var body: some View {
        List(model.value ?? []) { todo in
            Text(todo.title)
        }
        .overlay(StatusOverlay(model: model))
        .onAppear { self.model.loadIfNeeded() }
    }

}

struct TodosListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TodosListView(model: self.exampleLoadingModel)
            TodosListView(model: self.exampleLoadedModel)
            TodosListView(model: self.exampleErrorModel)
        }
    }

    static var exampleLoadedModel: TodosModel {
        let todosModel = TodosModel()
        todosModel.state = .loaded([Todo(id: 1, title: "Drink water"), Todo(id: 2, title: "Enjoy the sun")])
        return todosModel
    }

    static var exampleLoadingModel: TodosModel {
        let todosModel = TodosModel()
        todosModel.state = .loading(ExampleCancellable())
        return todosModel
    }

    static var exampleErrorModel: TodosModel {
        let todosModel = TodosModel()
        todosModel.state = .error(ExampleError.exampleError)
        return todosModel
    }

    enum ExampleError: Error {
        case exampleError
    }

    struct ExampleCancellable: Cancellable {
        func cancel() {}
    }

}
