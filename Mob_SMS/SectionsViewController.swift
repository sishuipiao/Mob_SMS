//
//  SectionsViewController.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/15.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit

class SectionsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FriendsCellDelegate,UISearchBarDelegate {

    var addressBookData:NSMutableArray?
    var friendsData:NSMutableArray?
    var friendsData2:NSMutableArray? = NSMutableArray()
    var other:NSMutableArray? = NSMutableArray()
    var friendsBlock:ShowNewFriendsCountBlock?
    var names:NSMutableDictionary?
    var allNames:NSDictionary?
    var keys:NSMutableArray?
    
    var isSearching:Bool?
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //获取通讯录数据
        addressBookData = SMS_SDK.addressBook()
        
        println("addressbookData:\(addressBookData)")
        
        for (var i:Int = 0; i < friendsData?.count ;i++) {
            var dict = friendsData?.objectAtIndex(i) as! NSDictionary
            var phone = dict.objectForKey("phone") as! String
            var name = dict.objectForKey("nickname") as! String
            for (var j:Int = 0; j < addressBookData?.count ;j++) {
                var person = addressBookData?.objectAtIndex(j) as! SMS_AddressBook
                for (var k:Int = 0; k < person.phonesEx.count ;k++) {
                    if phone == person.phonesEx.objectAtIndex(k) as! String {
                        if person.name != nil {
                            var str = "\(name)+\(person.name)@"
                            println("str:\(str)")
                            friendsData2?.addObject(str)
                        }
                        addressBookData?.removeObjectAtIndex(j)
                    }
                }
            }
        }
        
        for (var l:Int = 0; l < addressBookData?.count ;l++) {
            var person1 = addressBookData?.objectAtIndex(l) as! SMS_AddressBook
            var str1 = "\(person1.name)+\(person1.phones)#"
            println("str1:\(str1)")
            other?.addObject(str1)
        }
        
        var namesDict = NSMutableDictionary()
        
        println("friendsData2:\(friendsData2),other:\(other)")
        if friendsData2?.count > 0 {
            namesDict.setObject(friendsData2!, forKey: "已加入的用户")
        }
        if other?.count>0 {
            namesDict.setObject(other!, forKey: "待邀请的好友")
        }
        allNames = namesDict
        self.resetSearch()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func resetSearch() {
        names = allNames!.mutableDeepCopy()
        var keyarr = NSMutableArray()
        keyarr.addObjectsFromArray((allNames!.allKeys as NSArray).sortedArrayUsingSelector("compare:"))
        println(keyarr)
        keys = keyarr
    }
    
    func handleSearchForTerm(searchTerm:String) {
        var sectionsToRemove = NSMutableArray()
        self.resetSearch()
        for key in keys! {
            var keyArr = names!.valueForKey("\(key)") as! NSMutableArray
            var toRemove = NSMutableArray()
            for name in keyArr{
                if name.rangeOfString(searchTerm, options: NSStringCompareOptions.CaseInsensitiveSearch).location == NSNotFound {
                    toRemove.addObject(name)
                }
            }
            if keyArr.count == toRemove.count {
                sectionsToRemove.addObject(key)
            }
            keyArr.removeObjectsInArray(toRemove as [AnyObject])
        }
        keys?.removeObjectsInArray(sectionsToRemove as [AnyObject])
        tableView.reloadData()
    }
    
    @IBAction func backClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        SMS_SDK.setLatelyFriendsCount(0)
        if friendsBlock != nil {
            friendsBlock!(SMS_ResponseStateSuccess,0)
        }
    }
    func setMyBlock(block:ShowNewFriendsCountBlock) -> Void {
        friendsBlock = block
    }
    
    func setMyData(array:NSArray) -> Void {
        friendsData = NSMutableArray(array: array)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if keys?.count == 0 {
            return 0
        }
        var key = keys!.objectAtIndex(section) as! String
        var nameSection = names?.objectForKey(key) as! NSArray
        return nameSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var key = keys!.objectAtIndex(indexPath.section) as! String
        var nameSection = names?.objectForKey(key) as! NSArray
        
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendsIdentifier", forIndexPath: indexPath) as? FriendsCell
        cell?.delegate = self

        var str1 = nameSection.objectAtIndex(indexPath.row) as! NSString
        var newstr1 = str1.substringFromIndex(str1.length-1)
        var range = str1.rangeOfString("+")
        var str2 = str1.substringFromIndex(range.location)
        var phone = str2.stringByReplacingOccurrencesOfString("+", withString: "") as NSString
        var ccc = phone.substringToIndex(phone.length-1)
        var name = str1.substringToIndex(range.location)

        if newstr1 == "@" {
            cell?.button.titleLabel?.text = "添加"
            cell?.nameDesc = "手机联系人:\(ccc)"
            cell?.nameDescLabel.text = "手机联系人:\(ccc)"
            cell?.nameDescLabel.hidden = false
        }else if newstr1 == "#" {
            cell?.button.titleLabel?.text = "邀请"
            cell?.nameDesc = ccc
            cell?.nameDescLabel.text = ccc
            cell?.nameDescLabel?.hidden = true
        }
        cell?.name = name
        cell?.img = UIImage(named: "smssdk.bundle/\((indexPath.row)%14+1).png")
        cell?.nameLabel.text = name
        cell?.imgView.image = UIImage(named: "smssdk.bundle/\((indexPath.row)%14+1).png")
        return cell!
    }
    //FriendsCellDelegate
    func FriendsCellClick(cell: FriendsCell) {
        self.view.endEditing(true)
        var buttonTitle = cell.button.titleLabel?.text
        if buttonTitle == "添加" {
            var alert = UIAlertView(title: "添加好友", message: "已经发送添加好友信息,请耐心等待好友回复", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
        if buttonTitle == "邀请" {
            var inviteVC = storyboard?.instantiateViewControllerWithIdentifier("invite") as! InvitationViewController
            inviteVC.name = cell.name
            inviteVC.phone = cell.nameDesc
            inviteVC.img = cell.img
            self.presentViewController(inviteVC, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if keys?.count == 0 {
            return nil
        }
        return keys!.objectAtIndex(section) as? String
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        search.resignFirstResponder()
        search.text = ""
        isSearching = false
        tableView.reloadData()
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var section = indexPath.section
        var key = keys?.objectAtIndex(section) as! String
        var nameSection = names?.objectForKey(key) as! NSArray
        var str1: AnyObject = nameSection.objectAtIndex(indexPath.row)
        var range:NSRange = str1.rangeOfString("+") as NSRange
        var str2:String = str1.substringFromIndex(range.location)
        var areaCode:String = str2.stringByReplacingOccurrencesOfString("+", withString: "")
        var countryName:String = str1.substringToIndex(range.location)
        println("countryName:\(countryName)areaCode:\(areaCode)")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.handleSearchForTerm(searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) == 0 {
            self.resetSearch()
            tableView.reloadData()
            return
        }
        self.handleSearchForTerm(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearching = false
        search?.text = ""
        self.resetSearch()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
