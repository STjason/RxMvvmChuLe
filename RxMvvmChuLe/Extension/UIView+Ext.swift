//
//  UIView+Ext.swift
//  RxMvvmChuLe
//
//  Created by chieh hsun on 2020/5/26.
//  Copyright © 2020 chieh hsun. All rights reserved.
//

import UIKit

extension UIView {
    func showToast(text: String) {

        self.hideToast()
        let toastTextView = UITextView()
        toastTextView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastTextView.textColor = UIColor.white
        toastTextView.layer.cornerRadius = 10.0
        toastTextView.textAlignment = .center
        toastTextView.font = UIFont.systemFont(ofSize: 15.0)
        toastTextView.text = text
        toastTextView.isEditable = false
        toastTextView.layer.masksToBounds = true

        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastTextView.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width {
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height {
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastTextView.frame =
            CGRect(
                x: ((self.bounds.size.width) / 2) - ((expectedSize.width + 20) / 2),
                y: 20,
                width: expectedSize.width + 20,
                height: expectedSize.height - 40)

        self.addSubview(toastTextView)
        toastTextView.tag = 9999
    }

    func hideToast() {
        for view in self.subviews {
            if view is UITextView, view.tag == 9999 {
                view.removeFromSuperview()
            }
        }
    }
}
