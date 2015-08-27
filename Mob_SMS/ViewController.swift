//
//  ViewController.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/14.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit
import AddressBook
class ViewController: UIViewController {

    var alert:UIAlertView?
    var testView:HYZBadgeView?
    @IBOutlet weak var fridenButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var badgeView = HYZBadgeView(frame: CGRectMake(0, 0, 30, 30))
        testView = badgeView
        testView?.setNumber(0)
        fridenButton.addSubview(testView!)
        //显示最近新好友条数回调
        SMS_SDK.showFriendsBadge { (state, friendsCount) -> Void in
            if state.value == 1 {
                println("新好友数目重新设置")
                var count:UInt = UInt(friendsCount)
                self.testView?.setNumber(count)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func getFriendAddress(sender: AnyObject) {
        testView?.setNumber(0)
        
        var friendsVC = storyboard?.instantiateViewControllerWithIdentifier("Section") as! SectionsViewController
        friendsVC.setMyBlock { (state, friendsCount) -> Void in
            if state.value == 1 {
                println("新好友数目重新设置")
                self.testView?.setNumber(UInt(friendsCount))
            }
        }
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "加载中..."
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 2)
        //向服务端请求获取通讯录好友信息
        SMS_SDK.getAppContactFriends(1, result: { ( state, array) -> Void in
            if state.value == 1 {
                println("获取好友列表成功")
                friendsVC.setMyData(array)
                self.presentViewController(friendsVC, animated: true, completion: nil)
            }else{
                println("获取好友列表失败")
            }
        })
            
        if alert != nil {
            alert?.show()
        }
            
        if ABAddressBookGetAuthorizationStatus() != ABAuthorizationStatus.Authorized && alert == nil{
            var alertView = UIAlertView(title: "notice", message: "authorizedcontact", delegate: self, cancelButtonTitle: "sure")
            alert = alertView
            alert?.show()
        }
        
    }
    
}

