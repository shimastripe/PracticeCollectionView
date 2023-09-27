//
//  ContentView.swift
//
//
//  Created by shimastripe on 2023/09/27.
//

import SwiftUI
import UIKit

public struct ContentView: View {

    @State private var list: [UUID] = (1...5).map { _ in UUID() }

    public var body: some View {
        List {
            ForEach(list, id: \.self) {
                Text("\($0)")
            }
        }
        .animation(.default, value: list)
        .toolbar {
            Button("-1") {
                guard !list.isEmpty else { return }
                list.removeLast()
            }
            Button("+1") {
                list.append(.init())
            }
        }
        .overlay {
            if list.isEmpty {
                ContentUnavailableView("リストが空です", systemImage: "figure.yoga")
            }
        }
    }
}

public class CellAnimationViewController: UIHostingController<ContentView> {
    public init() {
        super.init(rootView: .init())
    }

    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(rootView: .init())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
