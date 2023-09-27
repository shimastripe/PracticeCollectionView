//
//  ContentView.swift
//
//
//  Created by shimastripe on 2023/09/27.
//

import SwiftUI
import UIKit

public struct ContentView: View {
    public var body: some View {
        Text("Hello World!")
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
