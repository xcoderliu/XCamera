//
//  Focus.swift
//  XCamera
//
//  Created by 刘智民 on 28/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation

let focusLarge:CGFloat = 160.0
let focusSmall:CGFloat = 80.0



extension XCameraViewController {
    func initFocus() {
        //初始化聚焦框
        focusFrameView = UIViewEx()
        if let _ = focusFrameView {
            focusFrameView?.layer.borderColor = UIColor.orange.cgColor
            focusFrameView?.layer.borderWidth = 2
            self.view.addSubview(focusFrameView!)
            self.view.bringSubview(toFront: focusFrameView!)
            focusFrameView?.frame = CGRect(x: 0, y: 0, width: focusLarge, height: focusLarge)
            focusFrameView?.isHidden = true
        }
        focusTap = UITapGestureRecognizer(target: self, action: #selector(handleFocus(tap:)))
        self.view.addGestureRecognizer(focusTap!)
    }
    
    @objc func handleFocus(tap: UITapGestureRecognizer) {
        //坐标系转换
        let tapPoint = tap.location(in:self.view)
        let itrPoint = CGPoint(x: tapPoint.y / self.view.bounds.size.height, y: 1 - tapPoint.x / self.view.bounds.size.width)
        //设置焦点
        try? captureDevice?.lockForConfiguration()
        captureDevice?.focusPointOfInterest = itrPoint
        captureDevice?.focusMode = .continuousAutoFocus
        captureDevice?.exposurePointOfInterest = itrPoint
        captureDevice?.exposureMode = .continuousAutoExposure
        captureDevice?.unlockForConfiguration()
        focusAnimate(point: tapPoint)
    }
    
    func focusAnimate(point: CGPoint) {
        focusFrameView?.center = point
        focusFrameView?.isHidden = false
        UIView.animate(withDuration: animateDuration, delay: 0, options: .beginFromCurrentState, animations: {
            //变小
            self.focusFrameView?.frame = CGRect(x: point.x - focusSmall / 2, y: point.y - focusSmall / 2, width: focusSmall, height: focusSmall)
        }) { (finish) in
            //闪烁
            UIView.animate(withDuration: 0.1, delay: 0, options: [.repeat,.autoreverse,.beginFromCurrentState], animations: {
                UIView.setAnimationRepeatCount(3)
                self.focusFrameView?.alpha = 0
            }, completion: { (finish) in
                self.focusFrameView?.alpha = 1
                self.focusFrameView?.isHidden = true
                self.focusFrameView?.frame = CGRect(x: 0, y: 0, width: focusLarge, height: focusLarge)
            })
        }
    }
    
}
