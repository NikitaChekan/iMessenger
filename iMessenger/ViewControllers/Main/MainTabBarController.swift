//
//  MainTabBarController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private let currentUser: MUser
//    private let user: User
    
    // MARK: - Init
    init(currentUser: MUser = MUser(
        userName: "Nick",
        email: "test999@mail.ru",
        avatarStringURL: "nil",
        description: "Hello",
        sex: "Male",
        id: "999"
    )) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.activeChatsListener == nil {
            appDelegate.addActiveChatsListener()
        }
        
        if appDelegate.waitingChatsListener == nil {
            appDelegate.addWaitingChatsListener()
        }
        
        let listViewController = ListViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        let settingsProfileViewController = SettingsProfileViewController(currentUser: currentUser)
            
        tabBar.tintColor = UIColor(named: "tabBarColor")
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        let conversationImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfig)!
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)!
        let settingsImage = UIImage(systemName: "gear")!
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: "People", image: peopleImage),
            generateNavigationController(rootViewController: listViewController, title: "Conversations", image: conversationImage),
            generateNavigationController(rootViewController: settingsProfileViewController, title: "Settings", image: settingsImage)
        ]
    }
    
    // MARK: - Methods
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}
