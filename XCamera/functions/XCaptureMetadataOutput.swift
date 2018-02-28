//
//  XCaptureMetadataOutput.swift
//  XCamera
//
//  Created by 刘智民 on 27/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0
        {
            DispatchQueue.main.async {
                UIView.animate(withDuration: animateDuration, animations: {
                    if self.qrCodeFrameView?.frame.size.width != 0 && self.qrCodeFrameView?.frame.size.height != 0
                    {
                        self.qrCodeFrameView?.frame = CGRect(x: (self.qrCodeFrameView?.preCenter.x)!, y: (self.qrCodeFrameView?.preCenter.y)!, width: 0, height: 0)
                        self.messageLabel.isHidden = true
                    }
                    
                    if self.faceFrameView?.frame.size.width != 0 && self.faceFrameView?.frame.size.height != 0
                    {
                        self.faceFrameView?.frame = CGRect(x: (self.faceFrameView?.preCenter.x)!, y: (self.faceFrameView?.preCenter.y)!, width: 0, height: 0)
                    }
                })
            }
            return
        }
        
        if let metaMRObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        {
            handleQr(metadataObj: metaMRObj)
        }
        
        if let metaFaceObj = metadataObjects[0] as? AVMetadataFaceObject {
            handleFace(metaFaceObj: metaFaceObj)
        }
    }
}
