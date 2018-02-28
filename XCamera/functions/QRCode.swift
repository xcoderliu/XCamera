//
//  QRCodeUI.swift
//  XCamera
//
//  Created by 刘智民 on 26/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation

extension XCameraViewController {
    func initQRView() {
        // 初始化 QR Code Frame 来突显 QR code
        qrCodeFrameView = UIViewEx()
        if let _ = qrCodeFrameView
        {
            qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
            self.view.addSubview(qrCodeFrameView!)
            self.view.bringSubview(toFront: qrCodeFrameView!)
        }
        
        // 初始化 messageLabel 来显示 QR code
        messageLabel.backgroundColor = UIColor.clear
        self.view.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .green
        messageLabel.font = UIFont.boldSystemFont(ofSize: 40)
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.height.equalTo(40)
            make.centerX.equalTo(self.qrCodeFrameView!)
            make.top.equalTo((self.qrCodeFrameView?.snp.top)!).offset(-60)
        }
        messageLabel.isHidden = true
    }
    
    func handleQr(metadataObj: AVMetadataMachineReadableCodeObject) {
        // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        
        self.qrCodeFrameView?.preCenter = CGPoint(x: (barCodeObject?.bounds.origin.x)! + (barCodeObject?.bounds.size.width)! / 2, y: (barCodeObject?.bounds.origin.y)! + (barCodeObject?.bounds.size.height)! / 2)
        
        if metadataObj.stringValue != nil {
            DispatchQueue.main.async {
                self.qrCodeFrameView?.center = (self.qrCodeFrameView?.preCenter)!;
                UIView.animate(withDuration: animateDuration, animations: {
                    self.qrCodeFrameView?.frame = barCodeObject!.bounds
                    self.messageLabel.isHidden = false
                    self.messageLabel.text = metadataObj.stringValue
                })
            }
        }
    }

}
