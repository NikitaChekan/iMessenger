//
//  ListViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit

class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(named: "mainWhiteColor")

        setupSearchBar()
        setupCollectionView()
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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellid")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(84))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
            return section
        }
        return layout
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid", for: indexPath)
        cell.backgroundColor = .red
        cell.layer.borderWidth = 1
        return cell
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
