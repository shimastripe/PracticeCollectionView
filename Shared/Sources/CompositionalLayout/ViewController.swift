//
//  ViewController.swift
//
//
//  Created by shimastripe on 2023/09/27.
//

import UIKit

public final class CompositionalLayoutViewController: UIViewController {

    enum Section {
        case promotion
        case main
        case secondary
    }

    static let colorData: [UIColor] = [.systemBlue, .systemRed, .systemYellow, .systemBrown, .systemPurple, .systemMint, .systemCyan, .systemGray, .systemTeal]

    // MARK: - State

    var promotion: [UUID] = (1...5).map { _ in UUID() }
    var list: [UUID] = (1...5).map { _ in UUID() }
    var secondaryList: [UUID] = (1...8).map { _ in UUID() }

    // MARK: - UI

    @ViewLoading
    var collectionView: UICollectionView
    @ViewLoading
    var dataSource: UICollectionViewDiffableDataSource<Section, UUID>
    @ViewLoading
    var moveSecond: UIButton
    @ViewLoading
    var moveFirst: UIButton

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        configureNavBarButton()
    }
}

extension CompositionalLayoutViewController {

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

        let promotionCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, UUID> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = item.uuidString
            cell.contentConfiguration = contentConfiguration

            var bgConfiguration = UIBackgroundConfiguration.listPlainCell()
            bgConfiguration.backgroundColor = Self.colorData.randomElement()!
            bgConfiguration.cornerRadius = 16
            cell.backgroundConfiguration = bgConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: UUID) -> UICollectionViewCell? in

            switch indexPath.section {
            case 0, 2:
                // promotion / secondary
                return collectionView.dequeueConfiguredReusableCell(using: promotionCellRegistration, for: indexPath, item: item)
            case 1:
                // main
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            default:
                fatalError()
            }

        }

        let snapshot = generateSnapshot()
        dataSource.apply(snapshot)
    }

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.88),
                    heightDimension: .fractionalWidth(0.88/1.6)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
                layoutSection.interGroupSpacing = 8
                return layoutSection
            case 1:
                return .list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
            case 2:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48), heightDimension: .fractionalWidth(0.48))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(44)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 2
                )
                group.interItemSpacing = .flexible(16)
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.interGroupSpacing = 32
                layoutSection.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return layoutSection
            default:
                return .list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
            }
        }
    }

    func generateSnapshot() -> NSDiffableDataSourceSnapshot<Section, UUID> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.promotion, .main, .secondary])
        snapshot.appendItems(promotion, toSection: .promotion)
        snapshot.appendItems(list, toSection: .main)
        snapshot.appendItems(secondaryList, toSection: .secondary)
        return snapshot
    }

    func configureNavBarButton() {
        moveSecond = .init(primaryAction: .init(title: "1st->2nd", handler: { [weak self] _ in
            guard let self else { return }
            let first = promotion.removeFirst()
            list.insert(first, at: 0)
            promotion.append(.init())
            let snapshot = generateSnapshot()
            dataSource.apply(snapshot)
        }))

        moveFirst = .init(primaryAction: .init(title: "2nd->3rd", handler: { [weak self] _ in
            guard let self else { return }
            let first = list.removeLast()
            secondaryList.insert(first, at: 0)
            list.insert(.init(), at: 0)
            let snapshot = generateSnapshot()
            dataSource.apply(snapshot)
        }))

        navigationItem.rightBarButtonItems = [.init(customView: moveFirst), .init(customView: moveSecond)]
    }
}
