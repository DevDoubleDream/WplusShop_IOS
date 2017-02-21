//
//  PaySuccessViewController.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 6..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import UIKit

class PaySuccessViewController: UIViewController {
    
    var select:String = ""
    
    var cardNo:String?
    
    var usePoint:String?
    var beforeSumPoint:String?
    
    var totalPoint:String = ""
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCardNo: UILabel!
    @IBOutlet weak var labelUsePoint: UILabel!
    @IBOutlet weak var labelTotalPoint: UILabel!
    
    @IBOutlet weak var labelInfoUse: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("cardNo : \(cardNo), usePoint : \(usePoint), beforeSumPoint : \(beforeSumPoint)")
        if let _ = cardNo, let _ = usePoint, let _ = beforeSumPoint{
            labelCardNo.text = cardNo
            labelUsePoint.text = usePoint
            
            let tempPoint:Int? = Int(usePoint!)
            let calcPoint = Double(tempPoint!) * 0.055
            
            if "USE" == select {
                labelTitle.text = "사용 포인트"
                labelInfoUse.text = "사용 포인트"
                let intTotalPoint = Int(beforeSumPoint!)! - Int(usePoint!)!
                let doubleTotalPoint = Int(Double(intTotalPoint) + calcPoint)
                
                let strTotalPoint = String(intTotalPoint + doubleTotalPoint)
                labelTotalPoint.text = strTotalPoint
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.closePopup), userInfo: nil, repeats: false)
            } else {
                labelTitle.text = "적립 포인트"
                labelInfoUse.text = "잔여 포인트"
                
                let intTotalPoint = Int(beforeSumPoint!)!
                let doubleTotalPoint = Int(Double(intTotalPoint) + calcPoint)
                let strTotalPoint = String(doubleTotalPoint)
                labelTotalPoint.text = strTotalPoint
                
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                
                _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.closePopup), userInfo: nil, repeats: false)
            }
            // Do any additional setup after loading the view.
        } else {
            let alertDialog = UIAlertController(title: "오류", message: "관리자에게 문의하세요.", preferredStyle: .alert)
            alertDialog.addAction(UIAlertAction(title: "확인", style: .default, handler: {(action: UIAlertAction!)
                in
                self.view.removeFromSuperview()
                self.navigationController?.popToRootViewController(animated: true)}))
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closePopup(){
        self.view.removeFromSuperview()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
