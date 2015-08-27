//
//  InvitationViewController.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/24.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit

class InvitationViewController: UIViewController,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var name:String?
    var phone:String?
    var img:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func inviteFriend(sender: AnyObject) {
        var alert = UIAlertView(title: "提示", message: "将要向\(name!)发送邀请，电话是：\(phone!)", delegate: self, cancelButtonTitle: "确定", otherButtonTitles: "取消")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            //发送短信
            SMS_SDK.sendSMS(phone!, andMessage: "Devstore邀请你快使用SMS_SDK吧")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        cell?.textLabel!.text = name
        cell?.imageView!.image = img
        cell?.detailTextLabel?.text = "电话号码:\(phone!)"
        return cell!
    }

}
