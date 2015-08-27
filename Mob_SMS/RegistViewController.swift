//
//  RegistViewController.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/15.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit

class RegistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CountryViewControllerDelegate,UIAlertViewDelegate {
    
    var defaultCode:String?
    var defaultCountryName:String?
    var areaArray:NSMutableArray?
    var data2:CountryAndAreaCode?
    var telString:String?
    var Verify: VerifyViewController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var areaCodeField: UITextField!
    @IBOutlet weak var telField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        Verify = storyboard?.instantiateViewControllerWithIdentifier("Veri") as? VerifyViewController
        //请求所支持的区号
        SMS_SDK.getZone { (state, array) -> Void in
            if state.value == 1{
                println("获取区号成功")
                self.areaArray = NSMutableArray(array: array)
            }else if state.value == 0{
                println("获取区号失败")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextStep(sender: AnyObject) {
        var compareResult:Bool = false
        for (var i:Int = 0;i<areaArray?.count;i++) {
            var dict1:NSDictionary = areaArray?.objectAtIndex(i) as! NSDictionary
            var code1:String = dict1.valueForKey("zone") as! String
            println("areaCode:\(code1)")
            if code1 == areaCodeField.text.stringByReplacingOccurrencesOfString("+", withString: "") {
                compareResult = true
                var rule1:String = dict1.valueForKey("rule") as! String

                var pred:NSPredicate = NSPredicate(format:"SELF MATCHES %@",rule1)

                var isMatch:Bool = pred.evaluateWithObject(telField.text)
                if isMatch == false {
                    var alert:UIAlertView = UIAlertView(title: "提示", message: "手机号码有误", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    return
                }
                break
            }
        }
        if compareResult == false {
            if count(telField.text) != 11 {
                var alert:UIAlertView = UIAlertView(title: "提示", message: "手机号码有误", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
        }
        var str:String = "即将发送验证码短信到这个号码:\(areaCodeField.text) \(telField.text)"
        telString = telField.text
        var alert:UIAlertView = UIAlertView(title: "确认手机号码", message: str, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.show()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var str = areaCodeField.text.stringByReplacingOccurrencesOfString("+", withString: "")
            Verify?.setPhoneAndAreaCode(telField.text, areaCodeString: str)
            //获取验证码
            SMS_SDK.getVerifyCodeByPhoneNumber(telField.text, andZone: str, result: { (state) -> Void in
                switch state.value {
                case 0: println("获取验证码失败")
                    var alert:UIAlertView = UIAlertView(title: "提示", message: "获取验证码失败", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    break
                case 1: println("获取验证码成功")
                    self.presentViewController(self.Verify!, animated: true, completion: nil)
                    break
                case 2: var alert:UIAlertView = UIAlertView(title: "超过上限", message: "请求验证码超上限，请稍后重试。", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    break
                default: var alert:UIAlertView = UIAlertView(title: "提示", message: "客户端请求发送短信验证过于频繁。", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    break
                }
            })
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        }
        cell?.textLabel!.text = "国家和地区"
        cell?.textLabel!.textColor = UIColor.darkGrayColor()
        cell?.detailTextLabel?.textColor = UIColor.blackColor()
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if data2 != nil {
            cell?.detailTextLabel?.text = data2?.countryName
        }else{
            cell?.detailTextLabel?.text = "China"
        }
        
        var tempView = UIView(frame: CGRectMake(0, 0, 0, 0))
        cell?.backgroundView = tempView
        cell?.backgroundColor = UIColor.clearColor()
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("CountryVC", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CountryVC"{
            var page1 = segue.destinationViewController as! CountryViewController
            page1.delegate = self
            page1.areaArray = areaArray
            //page1.setAreaArray(areaArray!)
        }
        
    }
    
    func setSecondData(data: CountryAndAreaCode) {
        data2 = data
        println("从Second传过来的数据：\(data.areaCode)\(data.countryName)")
        areaCodeField.text = "+\(data.areaCode)"
        self.tableView.reloadData()
    }
    
    
}
