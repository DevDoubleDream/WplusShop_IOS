//
//  PointUtil.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 13..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import Foundation

class PointUtil {
    func GetPointTask(URL url:String, Params params:Dictionary<String,String>){
        
        var strParameter:String = ""
        
        for (key, value) in params {
            strParameter += key + "="
            strParameter += value + "&"
        }
        
        let endIndex = strParameter.index(strParameter.endIndex, offsetBy: -1)
        strParameter = strParameter.substring(to: endIndex)
        
        let connectURL = URL(string: url + strParameter)
        let request = URLRequest(url: connectURL!)
        
        PointUtil.execTask(request: request) { (ok, obj) in self.returnPoint(JSON: obj) }
        
    }
    
    private class func execTask(request: URLRequest, taskCallback: @escaping (Bool,
        AnyObject?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    
                    taskCallback(true, json as AnyObject?)
                } else {
                    taskCallback(false, json as AnyObject?)
                }
            }
        })
        task.resume()
    }
    
    
    func returnPoint(JSON jsonResult:AnyObject?){
        var returnValue:Dictionary<String,String> = [:]
        var result:Dictionary = jsonResult!["RESULT"] as! Dictionary<String,String>
        let code:String = result["CODE"]!
        
        if "0000" == code {
            let data:Dictionary = jsonResult!["DATA"] as! Dictionary<String,AnyObject>
            
            let point = data["POINT"] as! Dictionary<String,AnyObject>
            
            returnValue["cpoint"] = String(describing:point["CPOINT"] as! NSNumber)
            returnValue["wpoint"] = String(describing:point["WPOINT"] as! NSNumber)
            returnValue["hpoint"] = String(describing:point["HPOINT"] as! NSNumber)
            returnValue["ipoint"] = String(describing:point["IPOINT"] as! NSNumber)
            returnValue["ppoint"] = String(describing:point["PPOINT"] as! NSNumber)
            returnValue["fpoint"] = String(describing:point["FPOINT"] as! NSNumber)
            
            returnValue["code"] = code
        } else {
            returnValue["code"] = code
        }
    }
    
}
