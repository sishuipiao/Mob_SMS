//
//  NSDictionaryDeepCopy.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/22.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit

class NSDictionaryDeepCopy: NSDictionary {
   
}

extension NSDictionary {
    func mutableDeepCopy() -> NSMutableDictionary{
        
        var ret = NSMutableDictionary(capacity: self.count)
        var keys = self.allKeys as NSArray
        for key in keys {
            var oneValue:AnyObject? = self.valueForKey(key as! String)
            var oneCopy:AnyObject?
            if oneValue?.respondsToSelector("mutableDeepCopy") == true {
                oneCopy = oneValue?.mutableDeepCopy()
            }else if oneValue?.respondsToSelector("mutableCopy") == true {
                oneCopy = oneValue?.mutableCopy()
            }
            if oneCopy == nil {
                oneCopy = oneValue?.copy()
            }
            ret.setValue(oneCopy, forKey:(key as! String))
        }
        return ret
    }
}