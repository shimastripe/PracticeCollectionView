//
//  TableOfContentsViewController.swift
//  PracticeCollectionView
//
//  Created by shimastripe on 2023/09/27.
//

import DiffableDataSource
import ReconfigureDataSource
import UIKit

final class TableOfContentsViewController: UIViewController {

    enum Section {
        case main
    }

    class OutlineItem: Hashable {
        let title: String
        let subitems: [OutlineItem]
        let outlineViewBuilder: (() -> UIViewController?)?

        init(title: String,
             outlineViewBuilder: (() -> UIViewController?)? = nil,
             subitems: [OutlineItem] = []) {
            self.title = title
            self.subitems = subitems
            self.outlineViewBuilder = outlineViewBuilder
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        private let identifier = UUID()
    }

    @ViewLoading
    var outlineCollectionView: UICollectionView
    var dataSource: UICollectionViewDiffableDataSource<Section, OutlineItem>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }

    private lazy var menuItems: [OutlineItem] = {
        return [
            OutlineItem(title: "1.セルのアニメーションの動きを知る", subitems: [
                OutlineItem(title: "DiffableDataSource", outlineViewBuilder: { CellAnimationViewController() }),
                OutlineItem(title: "SwiftUI", outlineViewBuilder: { CellAnimationHostingViewController() }),
            ]),
            OutlineItem(title: "2.セルの更新を知る", subitems: [
                OutlineItem(title: "SwiftUI", outlineViewBuilder: { ReconfigureHostingViewController() }),
            ]),
            OutlineItem(title: "3.カスタムセルを登録する", subitems: []),
            OutlineItem(title: "4.セルの中を実装する", subitems: []),
            OutlineItem(title: "5.List以外のレイアウト方式を知る", subitems: []),
        ]
    }()
}

extension TableOfContentsViewController {

    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemGroupedBackground
        outlineCollectionView = collectionView
        collectionView.delegate = self
    }

    func configureDataSource() {

        let containerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, OutlineItem> { (cell, indexPath, menuItem) in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = menuItem.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = contentConfiguration

            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, OutlineItem> { cell, indexPath, menuItem in
            // Populate the cell with our item description.
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = menuItem.title
            cell.contentConfiguration = contentConfiguration
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }

        dataSource = UICollectionViewDiffableDataSource<Section, OutlineItem>(collectionView: outlineCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: OutlineItem) -> UICollectionViewCell? in
            // Return the cell.
            if item.subitems.isEmpty {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: containerCellRegistration, for: indexPath, item: item)
            }
        }

        let snapshot = initialSnapshot()
        dataSource.apply(snapshot, to: .main, animatingDifferences: false)
    }

    func generateLayout() -> UICollectionViewLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }

    func initialSnapshot() -> NSDiffableDataSourceSectionSnapshot<OutlineItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<OutlineItem>()

        func addItems(_ menuItems: [OutlineItem], to parent: OutlineItem?) {
            snapshot.append(menuItems, to: parent)
            for menuItem in menuItems where !menuItem.subitems.isEmpty {
                addItems(menuItem.subitems, to: menuItem)
            }
        }

        addItems(menuItems, to: nil)
        return snapshot
    }
}

extension TableOfContentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let menuItem = dataSource.itemIdentifier(for: indexPath) else { return }

        collectionView.deselectItem(at: indexPath, animated: true)

        if let viewController = menuItem.outlineViewBuilder?() {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
