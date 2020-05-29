//
//  UIView+Ext.swift
//  RxMvvmChuLe
//
//  Created by chieh hsun on 2020/5/26.
//  Copyright © 2020 chieh hsun. All rights reserved.
//

import UIKit

extension UIView{

    func showToast(text: String){
        
        self.hideToast()
         //let toastLb = UILabel()
        let toastLb = UITextView()
               //toastLb.numberOfLines = 0
               //toastLb.lineBreakMode = .byWordWrapping
               toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
               toastLb.textColor = UIColor.white
               toastLb.layer.cornerRadius = 10.0
               toastLb.textAlignment = .center
               toastLb.font = UIFont.systemFont(ofSize: 15.0)
               toastLb.text = text
               //toastLb.adjustsFontSizeToFitWidth = true
        toastLb.isEditable = false
               toastLb.layer.masksToBounds = true
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2),
                               //y: self.bounds.height - expectedSize.height - 40 - 20,
                                y: 20,
                               width: expectedSize.width + 20,
                               height: expectedSize.height + 20)
                                //height: self.bounds.height)
        
        self.addSubview(toastLb)
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
    }
    
    func hideToast(){
        for view in self.subviews{
            if view is UITextView , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
}
