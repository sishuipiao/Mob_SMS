//
//  CountryViewController.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/18.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit

protocol CountryViewControllerDelegate {
    func setSecondData (data:CountryAndAreaCode)
}

class CountryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var search:UISearchBar?
    var names:NSMutableDictionary?
    var allNames:NSDictionary?
    var keys:NSMutableArray?
    var isSearching:Bool?
    var toolBar:UIToolbar?
    var areaArray:NSMutableArray?
    var delegate:CountryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var path = NSBundle.mainBundle().pathForResource("country", ofType: "plist")!
        allNames = NSDictionary(contentsOfFile: path)
        self.resetSearch()
        tableView.reloadData()
        tableView.setContentOffset(CGPointMake(0.0, 44.0), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resetSearch() {
        names = allNames!.mutableDeepCopy()
        var keyarr = NSMutableArray()
        keyarr.addObjectsFromArray((allNames!.allKeys as NSArray).sortedArrayUsingSelector("compare:"))
        println(keyarr)
        keys = keyarr
    }
    
    func handleSearchForTerm(searchTerm:String) {
        var sectionsToRemove:NSMutableArray = NSMutableArray()
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if keys!.count == 0{
            return 0
        }
        var key = keys?.objectAtIndex(section) as! String
        var nameSection = names!.objectForKey(key) as! NSArray
        return nameSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var section = indexPath.section
        var key = keys?.objectAtIndex(section) as! String
        var nameSection = names?.objectForKey(key) as! NSArray
        var cell = tableView.dequeueReusableCellWithIdentifier("SectionsTableIdentifier") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "SectionsTableIdentifier")
        }
        var str1 = nameSection.objectAtIndex(indexPath.row) as! NSString
        var range = str1.rangeOfString("+")
        var str2 = str1.substringFromIndex(range.location)
        var areaCode = str2.stringByReplacingOccurrencesOfString("+", withString: "")
        var countryName = str1.substringToIndex(range.location) as String
        
        cell?.textLabel!.text = countryName
        cell?.detailTextLabel?.text = "+\(areaCode)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if keys?.count == 0 {
            return nil
        }
        return (keys?.objectAtIndex(section) as! String)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if isSearching == true {
            return nil
        }
        return keys! as [AnyObject]
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        search?.resignFirstResponder()
        search?.text = ""
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
        var str2 = str1.substringFromIndex(range.location) as String
        var areaCode = str2.stringByReplacingOccurrencesOfString("+", withString: "")
        var countryName = str1.substringToIndex(range.location) as String
        
        var country = CountryAndAreaCode()
        country.countryName = countryName
        country.areaCode = areaCode
        println("country:\(countryName)\(areaCode)")
        
        self.view.endEditing(true)
        
        var compareResult = 0
        for (var i:Int = 0;i < areaArray?.count;i++) {
            var dict1 = areaArray?.objectAtIndex(i) as! NSDictionary
            var code1 = dict1.valueForKey("zone") as! String
            println("code1:\(code1)")
            if code1 == areaCode {
                compareResult = 1
                break
            }
        }
        
        if compareResult == 0 {
            var alert = UIAlertView(title: "提示", message: "不支持这个地区", delegate: nil, cancelButtonTitle: "确定"
            )
            alert.show()
            return
        }
        
        self.delegate?.setSecondData(country)
        self.dismissViewControllerAnimated(true, completion: nil)
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
