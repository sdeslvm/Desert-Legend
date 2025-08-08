import Foundation
import SwiftUI

struct DesertEntryScreen: View {
    @StateObject private var loader: DesertWebLoader

    init(loader: DesertWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            DesertWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                DesertProgressIndicator(value: percent)
            case .failure(let err):
                DesertErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                DesertOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct DesertProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            DesertLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct DesertErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct DesertOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
