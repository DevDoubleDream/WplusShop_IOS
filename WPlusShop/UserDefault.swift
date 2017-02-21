//
//  UserDefault.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 3..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import Foundation

class UserDefault{
    class func save(Key key:String, Value value:String){
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    
    class func load(Key key:String) -> String {
        let userDefaults = UserDefaults.standard
        if let value = userDefaults.value(forKey: key) as? String {
            return value
        } else {
            return "-1"
        }
    }
    
    class func delete(key:String){
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
    }
}
