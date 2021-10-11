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

import Combine
import os
import SwiftUI

public typealias Endpoint<Payload> = AnyPublisher<Payload, Error>

open class EndpointModel<T: Decodable>: ObservableObject {
    @Published public var state = State.ready {
        didSet {
            switch self.state {
            case .ready:
                os_log("%s ready", type: .info, String(describing: self))
            case .loading:
                os_log("%s loading", type: .info, String(describing: self))
            case .loaded:
                os_log("%s loaded", type: .info, String(describing: self))
            case let .error(error):
                os_log("%s error: %s", type: .error, String(describing: self), String(describing: error))
            }
            switch self.state {
            case let .loaded(value):
                self.value = value
            default:
                // do nothing, intentionally keep a previously loaded value in other states
                break
            }
        }
    }

    @Published public var value: T?

    public enum State {
        case ready
        case loading(Cancellable)
        case loaded(T)
        case error(Error)
    }

    public let endpoint: Endpoint<T>

    public init(endpoint: Endpoint<T>) {
        self.endpoint = endpoint
    }

    public func load() {
        assert(Thread.isMainThread)
        if case .loading = self.state {
            os_log("Already loading: %s", type: .debug, String(describing: self.endpoint))
            return
        }
        self.state = .loading(
            self.endpoint
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case let .failure(error):
                            self.state = .error(error)
                            self.onError(error)
                        }
                    },
                    receiveValue: { value in
                        self.state = .loaded(value)
                        self.onLoaded(value)
                    }
                ))
    }

    open func loadIfNeeded() {
        assert(Thread.isMainThread)
        guard case .ready = self.state else { return }
        self.load()
    }

    // MARK: Hooks for subclasses

    open func onLoaded(_: T) {}
    open func onError(_: Error) {}
}
