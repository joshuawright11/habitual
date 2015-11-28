//
//  MainTabBarController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let t1image = UIImage(named: "tab_network")
        let t1imageSelected = UIImage(named: "tab_network_filled")
        let t2image = UIImage(named: "tab_check")
        let t2imageSelected = UIImage(named: "tab_check_filled")
        let t3image = UIImage(named: "tab_pulse")
        let t3imageSelected = UIImage(named: "tab_pulse_filled")
        
        let tb1 = tabBar.items![0]
        let tb2 = tabBar.items![1]
        let tb3 = tabBar.items![2]
        
        tb1.image = t1image?.imageWithRenderingMode(.AlwaysTemplate)
        tb1.selectedImage = t1imageSelected?.imageWithRenderingMode(.AlwaysTemplate)
        tb1.title = "Connections"
        
        tb2.image = t2image?.imageWithRenderingMode(.AlwaysTemplate)
        tb2.selectedImage = t2imageSelected?.imageWithRenderingMode(.AlwaysTemplate)
        tb2.title = "Habits"
        
        tb3.image = t3image?.imageWithRenderingMode(.AlwaysTemplate)
        tb3.selectedImage = t3imageSelected?.imageWithRenderingMode(.AlwaysTemplate)
        tb3.title = "Pulse"

        self.selectedIndex = 1
        
        Styler.tabBarShader(self.tabBar)
        
//        self.tabBar.backgroundImage = UIImage(named: "clear")
        
//        let frost = UIVisualEffectView(effect: UIVibrancyEffect())
//        frost.frame = self.tabBar.bounds
//        self.tabBar.insertSubview(frost, atIndex: 0)
        
    }
}
