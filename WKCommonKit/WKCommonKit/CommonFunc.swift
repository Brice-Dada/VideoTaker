//
//  CommonFunc.swift
//  WKCommonKit
//
//  Created by WisdomMini on 2021/1/8.
//

import UIKit

class CommonFunc: NSObject {
    
    /**
    弹出提示框
    
    - paramevar    title:NSString:     提示框标题
    - parameter    message:NSString:     提示框信息
     */
    class func alertMessage(title:String,message:String) {
        let alert:UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "确定")
        alert.show()
    }
    
    class func confirmAlert(parentController:UIViewController,title:String,message:String, okText:String = "确定", complete:@escaping ((Bool)->Void)) -> UIAlertController {
        
        let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
            
            complete(false)
        })
        
        let okAction = UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
            complete(true)
            
        })
        
        confirmAlert.addAction(cancelAction)
        
        confirmAlert.addAction(okAction)
        
        parentController.present(confirmAlert, animated: true, completion: nil)
        
        return confirmAlert
    }
    
}
