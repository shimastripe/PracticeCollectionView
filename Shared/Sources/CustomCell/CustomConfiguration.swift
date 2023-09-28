//
//  CustomConfiguration.swift
//
//
//  Created by shimastripe on 2023/09/28.
//

import UIKit

/// データ構成、ただの Struct
struct CustomConfiguration: UIContentConfiguration, Hashable {

    var model: CustomCellViewController.Item?

    func makeContentView() -> UIView & UIContentView {
        CustomContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> CustomConfiguration {
        self
    }
}

/// Struct を元に UI を構築する仕組みの View
final class CustomContentView: UIView, UIContentView {

    typealias Configuration = CustomConfiguration
    private var currentConfiguration: Configuration!
    var configuration: UIContentConfiguration {
        get {
            return currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? Configuration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }

    init(configuration: Configuration) {
        super.init(frame: .zero)
        defer {
            apply(configuration: configuration)
        }

        // MARK: - UI のセットアップ

        var buttonConfiguration = UIButton.Configuration.borderedProminent()
        buttonConfiguration.baseBackgroundColor = .systemPink
        buttonConfiguration.image = .init(systemName: "star")
        changeColorButton.configuration = buttonConfiguration

        let hStack = UIStackView(arrangedSubviews: [title, changeColorButton])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            hStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            hStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply(configuration: Configuration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        // MARK: - データを UI に反映する

        title.text = configuration.model?.id.uuidString

        changeColorButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            var buttonConfiguration = UIButton.Configuration.borderedProminent()
            buttonConfiguration.baseBackgroundColor = .systemPink
            buttonConfiguration.image = .init(systemName: icons.randomElement()!)
            changeColorButton.configuration = buttonConfiguration
        }), for: .touchUpInside)
    }

    let title = UILabel()
    let icons = ["star", "star.fill", "star.slash"]
    let changeColorButton = UIButton()
}
