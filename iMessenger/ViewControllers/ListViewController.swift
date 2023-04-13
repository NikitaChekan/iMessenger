//
//  ListViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit

struct MChat: Hashable, Decodable {
    var userName: String
    var userImageString: String
    var lastMessage: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.id == rhs.id
    }
}

class ListViewController: UIViewController {
    
    let waitingChats = Bundle.main.decode([MChat].self, from: "waitingChats.json")
    let activeChats = Bundle.main.decode([MChat].self, from: "activeChats.json")

    
    enum Section: Int, CaseIterable {
        case waitingChats, activeChats
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, MChat>?
    
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(named: "mainWhiteColor")

        setupSearchBar()
        setupCollectionView()
        
        createDataSource()
        reloadData()
    }
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "mainWhiteColor")
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(named: "mainWhiteColor")
        view.addSubview(collectionView)
        
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
        snapshot.appendSections([.waitingChats, .activeChats])
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        snapshot.appendItems(activeChats, toSection: .activeChats)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - Data Source
extension ListViewController {
    
    private func configure<T: SelfConfiguringCell>(cellType: T.Type, with value: MChat, for indexPath: IndexPath) -> T {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)")}
        cell.configure(with: value)
        return cell
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .waitingChats:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
//                cell.backgroundColor = .systemBlue
//                return cell
                return self.configure(
                    cellType: WaitingChatCell.self,
                    with: chat,
                    for: indexPath
                )
            case .activeChats:
                return self.configure(
                    cellType: ActiveChatCell.self,
                    with: chat,
                    for: indexPath
                )
            }
        })
    }
}

// MARK: - Setup Layout
extension ListViewController {
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }
            switch section {
                
            case .waitingChats:
                return self.createWaitingChats()
            case .activeChats:
                return self.createActiveChats()
            }
        }
        return layout
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 20
        
        return section
    }
    
    private func createActiveChats() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 8
        
        return section
    }
}

// MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

// MARK: - SwiftUI

import SwiftUI

struct ListVCProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let tabBarVC = MainTabBarController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ListVCProvider.ConteinerView>) -> MainTabBarController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: ListVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ListVCProvider.ConteinerView>) {
            
        }
    }
}
