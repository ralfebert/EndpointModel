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
import os
import SwiftUI

open class EndpointModel<T: Decodable>: ObservableObject {

    @Published public var state = State.ready {
        didSet {
            os_log("%s: %s", log: EndpointLogging.log, type: .debug, String(describing: self), String(describing: self.state))
        }
    }

    public enum State {
        case ready
        case loading(Cancellable)
        case loaded(T)
        case error(Error)
    }

    public let publisher: EndpointPublisher<T>

    public init(publisher: EndpointPublisher<T>) {
        self.publisher = publisher
    }

    public var value: T? {
        switch self.state {
            case let .loaded(value):
                return value
            default:
                return .none
        }
    }

    public func load() {
        assert(Thread.isMainThread)
        self.state = .loading(
            self.publisher
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                            case .finished:
                                break
                            case let .failure(error):
                                self.state = .error(error)
                        }
                    },
                    receiveValue: { value in
                        self.state = .loaded(value)
                    }
                ))
    }

    public func loadIfNeeded() {
        assert(Thread.isMainThread)
        guard case .ready = self.state else { return }
        self.load()
    }

}
