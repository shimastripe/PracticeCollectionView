//
//  ViewController.swift
//
//
//  Created by shimastripe on 2023/09/27.
//

import UIKit

public final class CustomCellViewController: UIViewController {

    enum Section {
        case main
    }

    static let colorData: [UIColor] = [.systemBlue, .systemRed, .systemYellow, .systemBrown, .systemPurple, .systemMint, .systemCyan, .systemGray, .systemTeal]

    struct Item: Hashable, Identifiable {
        let id: UUID
        let bgColor: UIColor
    }


    // MARK: - State

    var list: [Item] = (1...5).map { _ in make() } {
        didSet {
            if list.isEmpty {
                var unavailableConfiguration = UIContentUnavailableConfiguration.empty()
                unavailableConfiguration.text = "リストが空です"
                unavailableConfiguration.image = .init(systemName: "figure.yoga")
                contentUnavailableConfiguration = unavailableConfiguration
            } else {
                contentUnavailableConfiguration = nil
            }
        }
    }

    static func make() -> Item {
        .init(id: .init(), bgColor: Self.colorData.randomElement()!)
    }

    // MARK: - UI

    @ViewLoading
    var collectionView: UICollectionView
    var dataSource: UICollectionViewDiffableDataSource<Section, UUID>! = nil
    @ViewLoading
    var minusButton: UIButton
    @ViewLoading
    var plusButton: UIButton

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        configureNavBarButton()
    }
}

extension CustomCellViewController {

    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemGroupedBackground
        self.collectionView = collectionView
    }

    func configureDataSource() {

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var contentConfiguration = CustomConfiguration()
            contentConfiguration.model = item
            cell.contentConfiguration = contentConfiguration

            cell.configurationUpdateHandler = .init { cell, state in
                if state.isFocused || state.isHighlighted {
                    var bgConfiguration = UIBackgroundConfiguration.listPlainCell()
                    bgConfiguration.backgroundColor = .systemIndigo
                    cell.backgroundConfiguration = bgConfiguration
                } else {
                    var bgConfiguration = UIBackgroundConfiguration.listPlainCell()
                    bgConfiguration.backgroundColor = item.bgColor
                    cell.backgroundConfiguration = bgConfiguration
                }
            }
        }

        let emptyRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Void> { (cell, indexPath, _) in
            // DiffableDataSource から Cell を Dequeue するタイミングで起きたエラー時に空の Cell を返してクラッシュを回避する
        }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: UUID) -> UICollectionViewCell? in

            guard let self, let item = list.first(where: { $0.id == identifier }) else {
                return collectionView.dequeueConfiguredReusableCell(using: emptyRegistration, for: indexPath, item: ())
            }

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        let snapshot = generateSnapshot()
        dataSource.apply(snapshot, to: .main)
    }

    func generateLayout() -> UICollectionViewLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }

    func generateSnapshot() -> NSDiffableDataSourceSectionSnapshot<UUID> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<UUID>()
        snapshot.append(list.map(\.id), to: nil)
        return snapshot
    }

    /// DiffableDataSource の場合追加済みの Snapshot の ID から reconfigure したい要素を明示的に指定する
    /// 差分検出を自前で行う必要がある
    func recongigureSnapshot(ids: [UUID]) -> NSDiffableDataSourceSnapshot<Section, UUID> {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(ids)
        return snapshot
    }

    func configureNavBarButton() {
        minusButton = .init(primaryAction: .init(title: "ID 変更(Reload)", handler: { [weak self] _ in
            guard let self else { return }
            var newItems = list
            newItems[1] = .init(id: .init(), bgColor: list[3].bgColor)
            newItems[3] = .init(id: .init(), bgColor: list[1].bgColor)
            list = newItems
            let snapshot = generateSnapshot()
            dataSource.apply(snapshot, to: .main)
        }))

        plusButton = .init(primaryAction: .init(title: "ID 維持(Update)", handler: { [weak self] _ in
            guard let self else { return }
            var newItems = list
            newItems[1] = Item(id: list[1].id, bgColor: list[3].bgColor)
            newItems[3] = Item(id: list[3].id, bgColor: list[1].bgColor)
            list = newItems
            let snapshot = recongigureSnapshot(ids: [newItems[1].id, newItems[3].id])
            // MEMO: animatingDifferences: false にすると、SwiftUIと同じ動き
            dataSource.apply(snapshot)
        }))

        navigationItem.rightBarButtonItems = [.init(customView: plusButton), .init(customView: minusButton)]
    }
}
