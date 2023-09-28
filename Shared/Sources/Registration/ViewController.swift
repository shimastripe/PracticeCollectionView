//
//  ViewController.swift
//
//
//  Created by shimastripe on 2023/09/27.
//

import UIKit

public final class CellRegistrationViewController: UIViewController {

    enum Section {
        case main
    }

    // MARK: - State

    var list: [UUID] = (1...5).map { _ in UUID() } {
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

extension CellRegistrationViewController {

    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemGroupedBackground
        self.collectionView = collectionView
    }

    func configureDataSource() {

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> { (cell, indexPath, item) in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.uuidString
            cell.contentConfiguration = contentConfiguration
        }

        let otherCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { (cell, indexPath, item) in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = "別種類のセル"
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: UUID) -> UICollectionViewCell? in

            // MEMO: item に渡すデータ型に応じた適切な CellRegistration を渡して Dequeue することで様々な Cell を切り替えられる
            if Bool.random() {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: otherCellRegistration, for: indexPath, item: 0)
            }
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
        snapshot.append(list, to: nil)
        return snapshot
    }

    func configureNavBarButton() {
        minusButton = .init(primaryAction: .init(title: "-1", handler: { [weak self] _ in
            guard let self, !list.isEmpty else { return }
            list.removeLast()
            let snapshot = generateSnapshot()
            dataSource.apply(snapshot, to: .main)
        }))

        plusButton = .init(primaryAction: .init(title: "+1", handler: { [weak self] _ in
            guard let self else { return }
            list.append(.init())
            let snapshot = generateSnapshot()
            dataSource.apply(snapshot, to: .main)
        }))

        navigationItem.rightBarButtonItems = [.init(customView: plusButton), .init(customView: minusButton)]
    }
}
