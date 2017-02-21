//
//  PaymentViewController.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 3..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController, ScanViewControllerDelegate {
    
    var cardNo:String = ""
    var point:String = ""
    var userNo:String = ""
    var cardPw:String = ""
    var select:String = ""
    
    var usePoint:String = ""
    
    @IBOutlet weak var labelCardNo: UILabel!
    @IBOutlet weak var labelPoint: UILabel!
    @IBOutlet weak var btnPay: UIButton!
    
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet var labelInfoPrice: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor(red: 243/255, green: 73/255, blue: 80/255, alpha: 1)
        let tempString = "회원번호 " + cardNo + " 님"
        let textColorString = NSMutableAttributedString(string:tempString, attributes: nil)
        textColorString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location:5, length:cardNo.characters.count))
        
        labelCardNo.attributedText = textColorString
        labelPoint.text = point
        
        addDoneButtonOnKeyBorad()
        
        // Do any additional setup after loading the view.
    }
    
    func addDoneButtonOnKeyBorad(){
        //        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let doneToolbar = UIToolbar.init()
        doneToolbar.sizeToFit()
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "완료", style: UIBarButtonItemStyle.done, target: self, action: #selector(PaymentViewController.doneButtonAction))
        
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txtPrice.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction(){
        self.txtPrice.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var isEmpty:Bool = false
        
        if identifier == "Camera" {
            usePoint = txtPrice.text!
            print("usePoint : \(usePoint)")
            if usePoint == "0" || usePoint.characters.count == 0 {
                
            } else {
                isEmpty = true
            }
        }
        
        
        return isEmpty
    }
    
    func finishScan(controller: ScanViewController, QRCode code: String) {
        
        var mode:String = ""
        var trsubgbncd:String = ""
        var strParameter:String = ""
        
        let url:String = "https://api.wincash.co.kr:446/point/pointprocess.asp?"
        
        if select == "USE" {
            mode = "consume_insert"
            trsubgbncd = "CC"
        } else {
            mode = "reserve_insert"
            trsubgbncd = "CR"
        }
        
        print("userNo: \(userNo)")
        
        let authKey = code.substring(to:code.index(code.startIndex, offsetBy: 64))
        print("authKey : \(authKey)")
        let code2 = code.substring(from: code.index(code.endIndex, offsetBy: -10))
        print("code : \(code2)")
        
        let params:Dictionary = ["cmd":"pointpayment",
                                 "mode":mode,
                                 "trsubgbncd":trsubgbncd,
                                 "paymethod":"P",
                                 "OTYPE":"J",
                                 "auth_key":authKey,
                                 "stcd":code2,
                                 "usecardno":cardNo,
                                 "usecardpw":cardPw,
                                 "payamount":usePoint]
        
        for (key, value) in params {
            strParameter += key + "="
            strParameter += value + "&"
        }
        
        let endIndex = strParameter.index(strParameter.endIndex, offsetBy: -1)
        strParameter = strParameter.substring(to: endIndex)
        
        let connectURL = URL(string:url + strParameter)
        
        //        print(connectURL)
        
        let request = URLRequest(url: connectURL!)
        
        PaymentViewController.execTask(request: request){(ok, obj) in self.startPayment(JSON: obj)}
        
        controller.navigationController!.popViewController(animated: true)
    }
    
    
    @IBAction func actionPay(_ sender: Any) {
        print("usePoint : \(usePoint), Point : \(point)")
        
        if txtPrice.text!.characters.count == 0 {
            usePoint = "0"
        } else {
            usePoint = txtPrice.text!
        }
        if "USE" == select {
            if Int(usePoint)! > Int(point)! {
                let alertDialog = UIAlertController(title: "오류", message: "사용할 수 있는 포인트를 초과하였습니다.", preferredStyle: UIAlertControllerStyle.alert)
                alertDialog.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                
                present(alertDialog, animated:true, completion:nil)
            } else if Int(usePoint)! < 1000 {
                let alertDialog = UIAlertController(title: "오류", message: "1000포인트 이상 입력해주세요", preferredStyle: UIAlertControllerStyle.alert)
                alertDialog.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                
                present(alertDialog, animated:true, completion:nil)
            } else {
                performSegue(withIdentifier: "camera", sender: nil)
            }
        } else {
            if Int(usePoint)! < 1000 {
                let alertDialog = UIAlertController(title: "오류", message: "1000포인트 이상 입력해주세요", preferredStyle: UIAlertControllerStyle.alert)
                alertDialog.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                
                present(alertDialog, animated:true, completion:nil)
            } else {
                performSegue(withIdentifier: "camera", sender: nil)
            }
        }
        //        performSegue(withIdentifier: "camera", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let navigation = self.navigationController?.navigationBar
        
        navigation?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
        navigation?.tintColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        navigation?.backItem?.title = ""
        if "USE" == select {
            self.navigationItem.title = "포인트 사용하기"
            labelInfoPrice?.text = "사용하실 포인트를 입력하세요"
        } else {
            self.navigationItem.title = "포인트 적립하기"
            labelInfoPrice?.text = "사용한 금액을 입력해주세요."
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new vi기w controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "camera" {
            let vc = segue.destination as! ScanViewController
            vc.usePoint = txtPrice.text!
            vc.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = "https://api.wincash.co.kr:446/card/cardprocess.asp?"
        let infoParams = ["cmd":"info", "member_no":userNo, "member_cardno":cardNo]
        var strParameter:String = ""
        for (key, value) in infoParams {
            strParameter += key + "="
            strParameter += value + "&"
        }
        
        let endIndex = strParameter.index(strParameter.endIndex, offsetBy:-1)
        strParameter = strParameter.substring(to: endIndex)
        
        let connectURL = URL(string:url+strParameter)
        let request = URLRequest(url:connectURL!)
        
        PaymentViewController.execTask(request: request) { (ok, obj) in self.returnCard(JSON: obj) }
    }
    
    private class func execTask(request: URLRequest, taskCallback: @escaping (Bool, AnyObject?) -> ()) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode{
                    
                    taskCallback(true, json as AnyObject?)
                } else {
                    taskCallback(false, json as AnyObject?)
                }
            }
        })
        task.resume()
    }
    
    func returnCard(JSON jsonResult:AnyObject?){
        var result = jsonResult!["RESULT"] as! Dictionary<String,String>
        let code:String = result["CODE"]!
        
        if "0000" == code {
            let data = jsonResult!["DATA"] as! Dictionary<String,AnyObject>
            
            cardPw = data["CARDPW"] as! String
            print(cardPw)
        }
    }
    
    func startPayment(JSON jsonResult:AnyObject?){
        print(jsonResult!)
        
        let result = jsonResult!["RESULT"] as! Dictionary<String,String>
        
        let code:String = result["CODE"]!
        
        if "0000" == code {
            let popOverVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "popUp") as! PaySuccessViewController
            popOverVC.cardNo = self.cardNo
            popOverVC.select = self.select
            popOverVC.usePoint = self.usePoint
            popOverVC.beforeSumPoint = self.point

            DispatchQueue.main.async {
                self.addChildViewController(popOverVC)
                
                popOverVC.view.frame = self.view.frame
                
                self.view.addSubview(popOverVC.view)
                popOverVC.didMove(toParentViewController: self)
            }
        } else {
            let alertDialog:UIAlertController = UIAlertController(title: "오류", message: "가맹점 정보가 올바르지 않습니다.", preferredStyle: .alert)
            alertDialog.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            
            present(alertDialog, animated: true, completion: nil)
        }
    }
}
