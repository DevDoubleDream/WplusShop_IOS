//
//  MainViewController.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 2..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LoginViewControllerDelegate{
    
    let db = DBInterface()
    
    var id:String     = ""
    var pw:String     = ""
    var cardNo:String = ""
    var point:String  = ""
    var userNo:String = ""
    
    var tempCardNo:String = ""
    
    var dbValue:Dictionary<String,String> = Dictionary<String,String>()
    
    var setLogin:Bool = false
    
    @IBOutlet weak var btnCenterLogin: UIButton!
    @IBOutlet weak var labelPoint: UILabel!
    @IBOutlet weak var labelCardNo: UILabel!
    @IBOutlet weak var viewCenter: UIView!
    @IBOutlet weak var labelTip: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewCenterLogin: UIView!
    
    @IBOutlet weak var btnPayment: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "로그인", style: .plain, target: self, action: #selector(actionNaviRight))
        
        
        let tipColor:UIColor = UIColor(red: 31/255, green: 176/255, blue: 187/255, alpha: 1)
        labelTip.layer.borderColor = tipColor.cgColor
        labelTip.layer.borderWidth = 1.0
        labelTip.layer.cornerRadius = 10
        
        scrollview.contentSize = CGSize(width: 450, height:120)
        
        viewCenter.layer.cornerRadius = 8
        viewCenterLogin.layer.cornerRadius = 8
        
        btnCenterLogin.layer.borderWidth = 1
        btnCenterLogin.layer.borderColor = UIColor.white.cgColor
        btnCenterLogin.layer.cornerRadius = 3
        
        do{
            try dbValue = db.selectData()!
        } catch let e {
            print("\(e.localizedDescription)")
        }
        
        
        if !dbValue.isEmpty {
            if dbValue["auto_login"]! == "Y" {
                setLogin = true
                id = dbValue["id"]!
                pw = dbValue["pw"]!
                
                print("id in database : \(id)")
                
                userNo = dbValue["userNo"]!
                cardNo = dbValue["card_no"]!
                //----- 포인트 정보 가져오기 -------//

                let params:Dictionary = ["cmd":"info", "member_no":userNo, "member_cardno":cardNo]
                GetPointTask(URL: "https://api.wincash.co.kr:446/point/pointprocess.asp?", Params: params)
                
            } else {
                viewCenterLogin.isHidden = false
                viewCenter.isHidden = true
                setLogin = false
            }
        } else {
            viewCenterLogin.isHidden = false
            viewCenter.isHidden = true
            setLogin = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    func actionNaviRight(sender:UIBarButtonItem){
        if setLogin{
            setLogin = false
            
            labelPoint.text = ""
            labelCardNo.text = ""
            
            do{
                try db.updateTable(ID: "", PW: "",USER_NO: "", AUTO: "N", CARD: "", POINT: "")
            } catch let e {
                print("\(e.localizedDescription)")
            }
            
            viewCenter.isHidden = true
            viewCenterLogin.isHidden = false

        } else {
            performSegue(withIdentifier: "login", sender: nil)
        }
//        self.navigationController?.pushViewController(loginVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionPayment(_ sender: Any) {
        
        if setLogin {
            print("Main point : \(point)")
            let popOverVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "select") as! SelectPayViewController
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            
            popOverVC.cardNo = cardNo
            popOverVC.point  = point
            popOverVC.userNo = userNo
            
            popOverVC.didMove(toParentViewController: self)
            
        } else {
            performSegue(withIdentifier: "login", sender: self)
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "login" {
            let vc = segue.destination as! LoginViewController
            vc.delegate = self
        }
    }
    @IBAction func actionCenterLogin(_ sender: Any) {
        
    }

    func loginVCDidFinish(controller: LoginViewController, txtLogin login: String, txtPoint point: String, txtCard card: String, btnHidden hidden: Bool, txtUserNo userNo:String) {
        
        labelPoint.text = point
        
        self.userNo = userNo
        
        let card1 = card.substring(to: card.index(card.startIndex, offsetBy:4))
        let card2 = card.substring(with: card.index(card.startIndex, offsetBy:4) ..< card.index(card.endIndex, offsetBy: -8))
        let card3 = card.substring(with: card.index(card.startIndex, offsetBy:8) ..< card.index(card.endIndex, offsetBy: -4))
        let card4 = card.substring(from: card.index(card.endIndex, offsetBy:-4))
        
        
        tempCardNo = card1 + "-" + card2 + "-" + card3 + "-" + card4
        cardNo = card
        
        print("card1 : \(card1) , card2: \(card2)")
        print("card3 : \(card3) , card4: \(card4)")
        labelCardNo.text = tempCardNo
        
        setLogin = true
        
        viewCenter.isHidden = false
        viewCenterLogin.isHidden = true
        
        controller.navigationController!.popViewController(animated: true)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if setLogin{
            
            let params:Dictionary = ["cmd":"info", "member_no":userNo, "member_cardno":cardNo]
            GetPointTask(URL: "https://api.wincash.co.kr:446/point/pointprocess.asp?", Params: params)
        }
        
        let loginImage = UIImage(named: "logInOut.png")
        let navigation = self.navigationController?.navigationBar
        
        navigation?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navigation?.tintColor = UIColor.white
        
        navigation?.setBackgroundImage(UIImage(), for: .default)
        navigation?.shadowImage = UIImage()
        navigation?.isTranslucent = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: loginImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionNaviRight(sender: )))
        
        navigation?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigation?.shadowImage = UIImage()
        navigation?.isTranslucent = true
        navigation?.backgroundColor = UIColor.clear
        
        
        let imageView = UIImageView(image:UIImage(named: "logo.png"))
        self.navigationItem.titleView = imageView
        
    }
    
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
        
        MainViewController.execTask(request: request) { (ok, obj) in self.returnPoint(JSON: obj) }
        
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
            
            DispatchQueue.main.async {
                self.labelPoint.text = returnValue["cpoint"]
                self.point = returnValue["cpoint"]!
                
                let card1 = self.cardNo.substring(to: self.cardNo.index(self.cardNo.startIndex, offsetBy: 4))
                let card2 = self.cardNo.substring(with: self.cardNo.index(self.cardNo.startIndex, offsetBy: 4) ..< self.cardNo.index(self.cardNo.endIndex, offsetBy:-8))
                let card3 = self.cardNo.substring(with: self.cardNo.index(self.cardNo.startIndex, offsetBy: 8) ..< self.cardNo.index(self.cardNo.endIndex, offsetBy:-4))
                let card4 = self.cardNo.substring(from: self.cardNo.index(self.cardNo.endIndex, offsetBy:-4))
                
                self.labelCardNo.text = card1 + "-" + card2 + "-" + card3 + "-" + card4
                
                self.setLogin = true
                
                self.viewCenterLogin.isHidden = true
                self.viewCenter.isHidden = false
            }
        } else {

            let alertDialog = UIAlertController(title: "오류", message: "포인트 정보를 가져오지 못했습니다.", preferredStyle: UIAlertControllerStyle.alert)
            
            alertDialog.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            
            present(alertDialog, animated: true, completion: nil)
        }
        
    }
    
    
    
}
