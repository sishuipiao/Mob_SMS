//
//  VerifyViewController.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/19.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit

class VerifyViewController: UIViewController,UIAlertViewDelegate {

    var phoneNumber:String?
    var areaCode:String?
    var timer1:NSTimer?
    var timer2:NSTimer?
    var count:Int = 0
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repeatSMSBtn: UIButton!
    @IBOutlet weak var verifyCodeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        telLabel.text = phoneNumber
        timer1?.invalidate()
        timer2?.invalidate()
        
        count = 0
        timer1 = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "showRepeatButton", userInfo: nil, repeats: true)
        timer2 = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        
        var hud:MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "正在发送中..."
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 2)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        telLabel.text = phoneNumber
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func setPhoneAndAreaCode(phoneString:String,areaCodeString:String) {
        phoneNumber = phoneString
        areaCode = areaCodeString
    }
    
    func updateTime() {
        ++count
        if count >= 60 {
            timer2?.invalidate()
            return
        }
        timeLabel.text = "接收验证码短信大约需要\(60-count)秒"
    }
    
    func showRepeatButton() {
        timeLabel.hidden = true
        repeatSMSBtn.hidden = false
        timer1?.invalidate()
        return
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.timer1?.invalidate()
            self.timer2?.invalidate()
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 102 {
            if buttonIndex == 1 {
                //获取验证码
                SMS_SDK.getVerifyCodeByPhoneNumber(phoneNumber, andZone: areaCode, result: { (state) -> Void in
                    switch state.value {
                    case 0: println("获取验证码失败")
                        var alert = UIAlertView(title: "提示", message: "获取验证码失败", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        break
                    case 1: println("获取验证码成功")
                        var alert = UIAlertView(title: "提示", message: "获取验证码成功", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        break
                    case 2: var alert = UIAlertView(title: "超过上限", message: "请求验证码超上限，请稍后重试。", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        break
                    default: var alert = UIAlertView(title: "提示", message: "客户端请求发送短信验证过于频繁。", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        break
                    }
                })
            }
        }else if alertView.tag == 103 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    @IBAction func RePeatSMS(sender: AnyObject) {
        var alert = UIAlertView(title: "确认手机号码", message: "我们将重新发送验证码短信到这个号码:\(phoneNumber!)", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.tag = 102
        alert.show()
    }
    
    @IBAction func Submit(sender: AnyObject) {
        self.view.endEditing(true)
        if verifyCodeField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 4 {
            var alert = UIAlertView(title: "提示", message: "验证码格式错误,请重新填写", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }else {
            //提交验证码
            SMS_SDK.commitVerifyCode(verifyCodeField.text, result: { (state) -> Void in
                if state.value == 0 {
                    var alert = UIAlertView(title: "验证失败", message: "验证码无效，请重新获取验证码。", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                }else if state.value == 1 {
                    var alert = UIAlertView(title: "验证成功", message: "恭喜你！验证码正确!", delegate: self, cancelButtonTitle: "确定")
                    alert.tag = 103
                    alert.show()
                }
            })
        }
    }
    
}
