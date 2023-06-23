//
//  PeopleViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SPAlert

final class PeopleViewController: UIViewController {
    
    // MARK: - Enumeration
    enum Section: Int, CaseIterable {
        case users
        
        func description(usersCount: Int) -> String {
            switch self {
            case .users:
                return "\(usersCount) people nearby"
            }
        }
    }
    
    // MARK: - Properties
    var users = [MUser]()
    private var usersListener: ListenerRegistration?
    
    private var isSearch: Bool = false
    private var countPerson: Int = 0
    
    private var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MUser>!

    private let currentUser: MUser
    
    // MARK: - Init
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.userName
    }
    
    deinit {
        usersListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        
        addListeners()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "tabBarColor")
        
    }

    // MARK: - Actions
    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                self.appDelegate.activeChatsListener?.remove()
                self.appDelegate.activeChatsListener = nil
                
                self.appDelegate.waitingChatsListener?.remove()
                self.appDelegate.waitingChatsListener = nil
                
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                
                keyWindow?.rootViewController = AuthViewController()
                
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        
        
        present(alertController, animated: true)
    }
        
    // MARK: - Override methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            for cell in collectionView.visibleCells {
                cell.layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
            }
        case .dark:
            for cell in collectionView.visibleCells {
                cell.layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Methods
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundAppColor")
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
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
        
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        
        collectionView.delegate = self
    }
    
    private func addListeners() {
        usersListener = ListenerService.shared.usersObserve(users: users, completion: { result in
            switch result {
            case .success(let users):
                self.users = users
                self.reloadData(with: nil)
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        })
    }
    
    private func reloadData(with searchText: String?) {
        let filtered = users.filter { user in
            user.contains(filter: searchText)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        
        if searchText == nil || searchText == "" {
            isSearch = false
            countPerson = users.count
        } else {
            isSearch = true
            countPerson = filtered.count
        }
        
        snapshot.appendSections([.users])
        snapshot.appendItems(filtered, toSection: .users)
        
        snapshot.reloadSections([.users])
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - Data Source
extension PeopleViewController {
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .users:
                return self.configure(
                    collectionView: collectionView,
                    cellType: UserCell.self,
                    with: user,
                    for: indexPath
                )
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
            
            if self.isSearch {
                sectionHeader.configure(
                    text: "\(self.countPerson) person",
                    font: .systemFont(ofSize: 36, weight: .light),
                    textColor: .label
                )
            } else {
                sectionHeader.configure(
                    text: section.description(usersCount: self.countPerson),
                    font: .systemFont(ofSize: 36, weight: .light),
                    textColor: .label
                )
            }
            
            return sectionHeader
        }
    }
}

// MARK: - Setup Layout
extension PeopleViewController {
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .users:
                return self.createUsersSection()
            }
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration
        
        return layout
    }
    
    private func createUsersSection() -> NSCollectionLayoutSection {
        
        let spacing = CGFloat(15)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 15, bottom: 0, trailing: 15)
        
        let sectionHeader = createSectionHeader()
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

// MARK: - UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}

// MARK: - UICollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        var isContinue = true
        
        FirestoreService.shared.checkExistenceWaitingChat(for: user) { result in
            switch result {
            case .success(_):
                let profileViewController = ProfileViewController(user: user, state: .withMessage)
                isContinue = false
                self.present(profileViewController, animated: true)
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        }
        
        FirestoreService.shared.checkExistenceActiveChat(for: user) { result in
            switch result {
            case .success(_):
                let profileViewController = ProfileViewController(user: user, state: .withButton)
                isContinue = false
                profileViewController.delegate = self
                
                self.present(profileViewController, animated: true)
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        }
        
        delayWithSeconds(0.3) {
            if isContinue {
                let profileViewController = ProfileViewController(user: user, state: .withTextField)
                self.present(profileViewController, animated: true)
            }
        }
    }
}

extension PeopleViewController: ProfileNavigation {
    func show(_ chat: MChat) {
        let chatViewController = ChatsViewController(user: currentUser, chat: chat)
        chatViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

// MARK: - SwiftUI

//import SwiftUI
//
//struct PeopleVCProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//
//    struct ConteinerView: UIViewControllerRepresentable {
//
//        let tabBarVC = MainTabBarController()
//
//        func makeUIViewController(context: UIViewControllerRepresentableContext<PeopleVCProvider.ConteinerView>) -> MainTabBarController {
//            return tabBarVC
//        }
//
//        func updateUIViewController(_ uiViewController: PeopleVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<PeopleVCProvider.ConteinerView>) {
//
//        }
//    }
//}
