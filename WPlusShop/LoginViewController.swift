//
//  LoginViewController.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 2..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
   
    func loginVCDidFinish(controller:LoginViewController, txtLogin login:String, txtPoint point:String, txtCard card:String, btnHidden hidden:Bool, txtUserNo userNo:String)
}

class LoginViewController: UIViewController {
    
    var delegate:LoginViewControllerDelegate? = nil
    
    @IBOutlet weak var textID: UITextField!
    @IBOutlet weak var textPW: UITextField!
    @IBOutlet weak var imgCheck: UIImageView!
    
    var isAuto:Bool = false
    
    var id:String = ""
    var pw:String = ""
    
    let db = DBInterface()
    
    var url:String = ""
    var params:Dictionary = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgCheck.layer.borderColor = UIColor(red: 243/255, green: 73/255, blue: 80/255, alpha: 1).cgColor
        imgCheck.layer.borderWidth = 1
        
        // Do any additional setup after loading the view.
        
        url = "https://api.wincash.co.kr:446/login/loginprocess.asp?"
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func actionAuto(_ sender: Any) {
        if !isAuto {
            print("isAuto: \(isAuto)")
            imgCheck.backgroundColor = UIColor(red: 243/255, green: 73/255, blue: 80/255, alpha: 1)
            imgCheck.image = UIImage(named: "check.png")
            
            isAuto = true
        } else {
            print("isAuto: \(isAuto)")
            imgCheck.backgroundColor = UIColor.white
            imgCheck.image = UIImage()
            isAuto = false
        }
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        if !textID.text!.isEmpty {
            id = textID.text!
            pw = textPW.text!
            
            var parameter:String = ""
            
            params = ["cmd":"login", "user_id":id, "user_pw":pw, "user_grade":"M", "user_dmn":"app.wincash.co.kr"]
            
            for (key, value) in params {
                parameter += key + "="
                parameter += value + "&"
            }
            
            let endIndex = parameter.index(parameter.endIndex, offsetBy: -1)
            parameter = parameter.substring(to: endIndex)
            
            let URLString = url + parameter
            let connectURL = URL(string: URLString)
            let request = URLRequest(url: connectURL!)
            
            
            LoginViewController.execTask(request: request) { (ok, obj) in
                self.startLogin(JSON: obj)
            }
            

        }
    }
    
    func startLogin(JSON jsonResult:AnyObject?){
        var result:Dictionary = jsonResult!["RESULT"] as! Dictionary<String,String>
        let code:String = result["CODE"]!
        
        if "0000" == code {
            
            var sscommon:Dictionary = jsonResult!["SSCOMMON"] as! Dictionary<String,String>
            
            let userNo:String = sscommon["SS_USER_NO"]!
            print("userNo : \(userNo)")
//            let userName:String = sscommon["SS_USER_NAME"]!
            let userPoint:String = sscommon["SS_USER_CPOINT"]!
            let userCard:String = sscommon["SS_USER_CARDNO"]!
            
            if isAuto {
                do{
                    try db.updateTable(ID: id as NSString, PW: pw as NSString, USER_NO: userNo as NSString, AUTO: "Y" as NSString, CARD: userCard as NSString, POINT: userPoint as NSString)
                } catch let e {
                    print("\(e.localizedDescription)")
                }
            } else {
                do{
                    try db.updateTable(ID: id as NSString, PW: pw as NSString, USER_NO: userNo as NSString, AUTO: "N" as NSString, CARD: userCard as NSString, POINT: userPoint as NSString)
                } catch let e {
                    print("\(e.localizedDescription)")
                }
            }
            
            if delegate != nil {
                DispatchQueue.main.async {
                    self.delegate!.loginVCDidFinish(controller: self, txtLogin: "로그인", txtPoint: userPoint, txtCard: userCard, btnHidden: true, txtUserNo: userNo)
                }
            }
        } else {
            DispatchQueue.main.async{
                let alertDialog = UIAlertController(title: "로그인 오류", message: "아이디와 비밀번호를 확인해주세요", preferredStyle: UIAlertControllerStyle.alert)
                alertDialog.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alertDialog, animated: true, completion: nil)

            }
                    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navigation = self.navigationController?.navigationBar
        
        navigation?.backgroundColor = UIColor.white
        
        navigation?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
        navigation?.tintColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)

        
        navigation?.backItem?.title = ""
    }
    
}
