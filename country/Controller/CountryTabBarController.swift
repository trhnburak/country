//
//  CountryTabBarController.swift
//  adesso
//
//  Created by Burak Turhan on 12.11.2022.
//

import UIKit

class CountryTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.

        self.delegate = self

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .bold)], for: .normal)

        if let tabBarItem1 = self.tabBar.items?[0] {
                    tabBarItem1.title = "Home"
                    tabBarItem1.image = UIImage(systemName: "house.fill")

                }
                if let tabBarItem2 = self.tabBar.items?[1] {
                    tabBarItem2.title = "Saved"
                    tabBarItem2.image = UIImage(systemName: "heart.fill")

                }

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        if item.title == "Home" {
            print("Selected item 0")
            if let firstVC = viewControllers as? CountryTableViewController {
                firstVC.fetch()
                firstVC.tableView.reloadData()

            }

        }
        if item.title == "Saved" {
            print("Selected item 1")
        }

   }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
