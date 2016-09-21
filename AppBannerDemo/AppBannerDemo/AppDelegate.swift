//
//  AppDelegate.swift
//  AppBannerDemo
//
//  Created by LawLincoln on 2016/9/20.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//

import UIKit
import Rem
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        callRem()
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) { }
    func applicationDidEnterBackground(_ application: UIApplication) { }
    func applicationWillEnterForeground(_ application: UIApplication) { }
    func applicationDidBecomeActive(_ application: UIApplication) { }
    func applicationWillTerminate(_ application: UIApplication) { }
}

extension AppDelegate {
    
    internal func callRem() {
        let size = UIScreen.main.bounds.size
        let y = size.height - 94
        let imageView = UIImageView(frame: CGRect(x: 0, y: y, width: size.width, height: 94))
        imageView.image = #imageLiteral(resourceName: "copyright")
        let gif = "http://s1.dwstatic.com/group1/M00/5F/BC/acb6fe9fb1c8b83622404b3f7e514f9d.gif"
        let jpg = "http://ww4.sinaimg.cn/large/47481d23gw1f80z3ayvpij20vi18gdz1.jpg"
        let img = (arc4random() % 2 == 0) ? gif : jpg
        let ad = Rem.Work(url: img, duration: 105, showBlank: true, imageOverBanner: imageView, enableTap: true, countdown: .countdown(.topRight), skip: .skip(.bottomRight)) { (state) in
            print("done with:\(state)")
            if state == .skip {
                Rem.cleanHouse()
            }
        }
        Rem.shared.handle(work: ad)
    }
}

