//
//  MainTabVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import Firebase

final class MainTabVC: UITabBarController {

    //MARK: - Properties
    
    override func viewDidLoad() {
        print("MainTabVC viewDidLoad")
        super.viewDidLoad()

        //delegate
        self.delegate = self
    
        //VC configuration
        configureVC()
        
        //user validation
        checkUserLogIn()
    }
    
    func configureVC() {
        //embed controllers in navigation: move back and forth between VCs
        let listVC = constructNavController(unselectedImage: listUnselected!, selectedImage: listSelected!, rootViewController: ListVC())
        listVC.title = "목록"
        
        let addItemVC = constructNavController(unselectedImage: addImage!, selectedImage: addImage!)
        addItemVC.title = "추가"
        
        let accountVC = constructNavController(unselectedImage: accountUnselected!, selectedImage: accountSelected!, rootViewController: AccountVC())
        accountVC.title = "계정"
        
        viewControllers = [listVC, addItemVC, accountVC]
        
        //always start at listVC
        self.selectedIndex = 0
        
        //tabbar selection color
        tabBar.tintColor = brandColor
    }
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = viewBackgroundColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        return navController
    }
    
    //MARK: - API

    func checkUserLogIn() {
        if Auth.auth().currentUser == nil {
            print("Going to load LoginVC")
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            }
            return
        }
    }
    
}

//MARK: - TabBarControllerDelegate

extension MainTabVC: UITabBarControllerDelegate {
    
    //user tap on tabbar
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //get index of VC in tabbar
        let index = viewControllers?.firstIndex(of: viewController)
        
        //add item
        if index == 1 {
            let addItemVC = AddItemVC()
            let navController = UINavigationController(rootViewController: addItemVC)
            navController.navigationBar.tintColor = viewTextColor
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            
            return false
        }
        
        return true
    }
    
    
}
