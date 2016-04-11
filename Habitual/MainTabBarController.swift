//
//  MainTabBarController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

// -TODO: Needs refactoring/documentation

class MainTabBarController: UITabBarController, ServiceObserver {

    var serviceManager: ServiceManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceManager.addAccountServiceObserver(self)
        
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
        
        let connections = (viewControllers![0] as! UINavigationController).viewControllers[0] as! NetworkController
        let calendarViewController = (viewControllers![1] as! UINavigationController).viewControllers[0] as! CalendarController
        let userController = (viewControllers![2] as! UINavigationController).viewControllers[0] as! UserController
        
        connections.connectionService = serviceManager
        connections.accountService = serviceManager
        calendarViewController.habitService = serviceManager
        calendarViewController.connectionService = serviceManager
        userController.habits = serviceManager.habits
        
//        self.tabBar.backgroundImage = UIImage(named: "clear")
        
//        let frost = UIVisualEffectView(effect: UIVibrancyEffect())
//        frost.frame = self.tabBar.bounds
//        self.tabBar.insertSubview(frost, atIndex: 0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        serviceDidUpdate()
    }
    
    func serviceDidUpdate() {
        if !serviceManager.isLoggedIn || serviceManager.isFakeEmail {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("account") as! AccountController
            vc.accountService = serviceManager
            let nav = UINavigationController(rootViewController: vc)
            presentViewController(nav, animated: false, completion: nil)
        } else {
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }
}
