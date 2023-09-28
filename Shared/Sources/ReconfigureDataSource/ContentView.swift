//
//  ContentView.swift
//
//
//  Created by shimastripe on 2023/09/28.
//

import SwiftUI
import UIKit

public struct ContentView: View {

    static let colorData: [Color] = [.blue, .red, .yellow, .brown, .purple, .mint, .cyan, .gray, .teal]

    struct Item: Hashable, Identifiable {
        let id: UUID
        let bgColor: Color
    }

    @State private var list: [Item] = (1...5).map { _ in make() }

    public var body: some View {
        List {
            ForEach(list, id: \.self) { item in
                Text(item.id.uuidString)
                    .listRowBackground(item.bgColor)
                    .id(item.id)
            }
        }
        .animation(.default, value: list)
        .toolbar {
            Button("ID 変更(Reload)") {
                var newItems = list
                newItems[1] = .init(id: .init(), bgColor: list[3].bgColor)
                newItems[3] = .init(id: .init(), bgColor: list[1].bgColor)
                list = newItems
            }
            Button("ID 維持(Update)") {
                var newItems = list
                newItems[1] = Item(id: list[1].id, bgColor: list[3].bgColor)
                newItems[3] = Item(id: list[3].id, bgColor: list[1].bgColor)
                list = newItems
            }
        }
    }

    static func make() -> Item {
        .init(id: .init(), bgColor: Self.colorData.randomElement()!)
    }
}

public class ReconfigureHostingViewController: UIHostingController<ContentView> {
    public init() {
        super.init(rootView: .init())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
