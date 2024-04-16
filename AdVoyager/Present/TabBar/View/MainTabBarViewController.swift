//
//  MainTabBarViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overviewVC = OverviewViewController()
        let profileVC = ProfileViewController()
        
        overviewVC.title = "메인"
        overviewVC.tabBarItem.image = UIImage(systemName: "airplane.circle")
        
        profileVC.title = "프로필"
        profileVC.tabBarItem.image = UIImage(systemName: "person.circle")
        
        setViewControllers([overviewVC, profileVC], animated: false)
    }
}
