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
        
        let overviewVC = UINavigationController(rootViewController: OverviewViewController())
        let travelPlanOverviewVC = UINavigationController(rootViewController: TravelPlanOverviewViewController())
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        
        overviewVC.title = "메인"
        overviewVC.tabBarItem.image = UIImage(systemName: "airplane.circle")
        
        travelPlanOverviewVC.title = "여행 계획"
        travelPlanOverviewVC.tabBarItem.image = UIImage(systemName: "calendar.circle")
        
        profileVC.title = "프로필"
        profileVC.tabBarItem.image = UIImage(systemName: "person.circle")
        
        setViewControllers([overviewVC, travelPlanOverviewVC, profileVC], animated: false)
    }
}
