//
//  ListViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {
    
    enum Layout {
        case filled
        case empty
    }
    
    enum Section: Int, CaseIterable {
        case waitingChats, activeChats
        
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting chats"
            case .activeChats:
                return "Active chats"
                
            }
        }
    }
    
    var waitingChats = [MChat]()
    var activeChats = [MChat]()
    
    private var waitingLayout: Layout = .filled
    private var isEmptyWaitingChats: Bool = false {
        willSet {
            switch newValue {
            case true:
                waitingLayout = .empty
            case false:
                waitingLayout = .filled
            }
        }
    }
    private var activeLayout: Layout = .filled
    private var isEmptyActiveChats: Bool = false {
        willSet {
            switch newValue {
            case true:
                activeLayout = .empty
            case false:
                activeLayout = .filled
            }
        }
    }
    
    private var waitingChatsListener: ListenerRegistration?
    private var activeChatsListener: ListenerRegistration?
    
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, MChat>?
    
    var collectionView: UICollectionView!
    
    private let currentUser: MUser
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.userName
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        waitingChatsListener?.remove()
        activeChatsListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        
        setupCollectionView()
        createDataSource()
        
        addListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundAppColor")
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Enter a friend name..."
        searchController.searchBar.barTintColor = UIColor(named: "tabBarColor")
        searchController.searchBar.tintColor = UIColor(named: "tabBarColor")
        
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(named: "backgroundAppColor")
        view.addSubview(collectionView)
        
        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseId
        )
        
        collectionView.register(WaitingPlugCell.self, forCellWithReuseIdentifier: WaitingPlugCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
        collectionView.register(ActivePlugCell.self, forCellWithReuseIdentifier: ActivePlugCell.reuseId)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        
        collectionView.delegate = self
    }
    
    private func addListeners() {
        
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats, completion: { result in
            switch result {
            case .success(let chats):
                if self.waitingChats != [], self.waitingChats.count <= chats.count {
                    let chatRequestVC = ChatRequestViewController(chat: chats.last!)
                    chatRequestVC.delegate = self
                    self.present(chatRequestVC, animated: true)
                }
                self.waitingChats = chats
                self.isEmptyWaitingChats = self.waitingChats.isEmpty
                
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        })
        
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats, completion: { result in
            switch result {
            case .success(let chats):
                self.activeChats = chats
                self.isEmptyActiveChats = self.activeChats.isEmpty
                
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
        
        snapshot.appendSections([.waitingChats, .activeChats])
        
        switch waitingLayout {
        case .filled:
            snapshot.appendItems(waitingChats, toSection: .waitingChats)
        case .empty:
            snapshot.appendItems([MChat.waitingPlugModel], toSection: .waitingChats)
        }
        
        switch activeLayout {
        case .filled:
            snapshot.appendItems(activeChats, toSection: .activeChats)
        case .empty:
            snapshot.appendItems([MChat.activePlugModel], toSection: .activeChats)
        }
        
        snapshot.reloadItems(waitingChats)
        snapshot.reloadItems(activeChats)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadData(with searchText: String) {
        
        let waitingFiltered = waitingChats.filter { $0.contains(filter: searchText) }
        let activeFiltered = activeChats.filter { $0.contains(filter: searchText) }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
        
        snapshot.appendSections([.waitingChats, .activeChats])
        
        switch waitingLayout {
        case .filled:
            snapshot.appendItems(waitingFiltered, toSection: .waitingChats)
        case .empty:
            snapshot.appendItems([MChat.waitingPlugModel], toSection: .waitingChats)
        }
        
        switch activeLayout {
        case .filled:
            snapshot.appendItems(activeFiltered, toSection: .activeChats)
        case .empty:
            snapshot.appendItems([MChat.activePlugModel], toSection: .activeChats)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - Data Source
extension ListViewController {
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .waitingChats:
        
                switch self.waitingLayout {
                case .filled:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: WaitingChatCell.self,
                        with: chat,
                        for: indexPath
                    )
                case .empty:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: WaitingPlugCell.self,
                        with: "No requests...",
                        for: indexPath
                    )
                }

            case .activeChats:
                
                switch self.activeLayout {
                case .filled:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: ActiveChatCell.self,
                        with: chat,
                        for: indexPath
                    )
                case .empty:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: ActivePlugCell.self,
                        with: "No chats...",
                        for: indexPath
                    )
                }
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseId,
                for: indexPath
            ) as? SectionHeader else { fatalError("Can not create new section header") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind")}
            
            sectionHeader.configure(
                text: section.description(),
                font: .laoSangamMN20(),
                textColor: UIColor(named: "sectionHeaderColor") ?? .gray
            )
            return sectionHeader
        }
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
                
                switch self.waitingLayout {
                case .filled:
                    return self.createWaitingChats()
                case .empty:
                    return self.createPlugForWaitingChats()
                }
                
            case .activeChats:
                
                switch self.activeLayout {
                case .filled:
                    return self.createActiveChats()
                case .empty:
                    return self.createPlugForActiveChats()
                }
                
            }
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration
        
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
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]

        
        return section
    }
    
    private func createPlugForWaitingChats() -> NSCollectionLayoutSection {
        // Setup size for item and ground
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88))
        
        // Create item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Create header
        let sectionHeader = createSectionHeader()
        
        // Create section and configure
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
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
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createPlugForActiveChats() -> NSCollectionLayoutSection {
           // Setup size for item and ground
           let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
           let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.43))
           
           // Create item
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
           
           // Create group
           let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
           
           // Create header
           let sectionHeader = createSectionHeader()
           
           // Create section and configure
           let section = NSCollectionLayoutSection(group: group)
           section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
           section.boundarySupplementaryItems = [sectionHeader]
           
           return section
       }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        return sectionHeader
    }
}

// MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .waitingChats:
            guard !isEmptyWaitingChats else { return }
            
            let chatRequestVC = ChatRequestViewController(chat: chat)
            chatRequestVC.delegate = self
            
            self.present(chatRequestVC, animated: true)
        case .activeChats:
            guard !isEmptyActiveChats else { return }

            let chatsVC = ChatsViewController(user: currentUser, chat: chat)
            chatsVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatsVC, animated: true)
        }

    }
}

// MARK: - WaitingChatNavigation
extension ListViewController: WaitingChatNavigation {
    
    func removeWaitingChat(chat: MChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { result in
            switch result {
            case .success:
                self.showAlert(with: "Успешно!", and: "Чат с \(chat.friendUserName) был удален.")
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    func chatToActive(chat: MChat) {
        FirestoreService.shared.changeToActive(chat: chat) { result in
            switch result {
            case .success:
                self.showAlert(with: "Успешно!", and: "Приятного общения с \(chat.friendUserName).")
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
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
