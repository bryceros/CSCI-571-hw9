//
//  MainTabController.swift
//  HW9
//
//  Created by bryce on 11/26/19.
//  Copyright © 2019 bryce. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MainTabController: UITabBarController {
    var data: JSON = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("init")
        title = data["city"].stringValue
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(addTapped))

        let first =  viewControllers![0] as! TodayTabController
        first.data = data
        
        let second =  viewControllers![1] as! WeeklyTabController
        second.data = data
        
        let third =  viewControllers![2] as! GooglePhotosTab
        third.data = data
        
    }
    @objc func addTapped() {
        print("Twitter Clicked")
        let url = String( "https://twitter.com/intent/tweet?text="+"The current temperature at "+self.data["city"].stringValue+" is "+self.data["currently"]["Temperature"].stringValue+"°F.The weather conditions are "+self.data["currently"]["Summary"].stringValue+"&hashtags=CSCI571WeatherSearch").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let link = URL(string:url)!
        UIApplication.shared.open(link)
        
    }
}
