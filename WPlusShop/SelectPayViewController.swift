//
//  SelectPayViewController.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 9..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import UIKit

class SelectPayViewController: UIViewController {
    
    var cardNo:String = ""
    var point:String  = ""
    var userNo:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionUse(_ sender: Any) {
        let payVC = self.storyboard?.instantiateViewController(withIdentifier: "Pay") as! PaymentViewController
        
        payVC.cardNo = cardNo
        payVC.point  = point
        payVC.userNo = userNo
        payVC.select = "USE"
        
        closeDialog()
        self.navigationController?.pushViewController(payVC, animated: true)
    }

    @IBAction func actionSave(_ sender: Any) {
        let payVC = self.storyboard?.instantiateViewController(withIdentifier: "Pay") as! PaymentViewController
        
        payVC.cardNo = cardNo
        payVC.point  = point
        payVC.userNo = userNo
        payVC.select = "SAVE"
        
        closeDialog()
        self.navigationController?.pushViewController(payVC, animated: true)
    }
    
    func closeDialog(){
        self.view.removeFromSuperview()
//        self.navigationController?.popToRootViewController(animated: true)
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
