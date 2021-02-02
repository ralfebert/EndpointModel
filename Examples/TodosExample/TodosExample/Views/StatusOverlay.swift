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

import ActivityIndicatorView
import EndpointModel
import SwiftUI

struct StatusOverlay<V: Decodable>: View {

    @ObservedObject var model: EndpointModel<V>

    var body: some View {
        switch model.state {
            case .ready:
                return AnyView(EmptyView())
            case .loading:
                return AnyView(ActivityIndicatorView(isAnimating: .constant(true), style: .large))
            case .loaded:
                return AnyView(EmptyView())
            case let .error(error):
                return AnyView(
                    VStack(spacing: 10) {
                        Text(error.localizedDescription)
                            .frame(maxWidth: 300)
                        Button("Retry") {
                            self.model.load()
                        }
                    }
                    .padding()
                    .background(Color.yellow)
                )
        }
    }

}
