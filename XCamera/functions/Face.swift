//
//  Face.swift
//  XCamera
//
//  Created by 刘智民 on 27/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation

extension XCameraViewController {
    func initFaceUI() {
        // 初始化 face Frame 来突显 脸部
        faceFrameView = UIViewEx()
        if let _ = faceFrameView
        {
            faceFrameView?.layer.borderColor = UIColor.yellow.cgColor
            faceFrameView?.layer.borderWidth = 2
            self.view.addSubview(faceFrameView!)
            self.view.bringSubview(toFront: faceFrameView!)
        }
    }
    
    func handleFace (metaFaceObj:AVMetadataFaceObject) {
        // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
        let faceObject = videoPreviewLayer?.transformedMetadataObject(for: metaFaceObj)
        
        self.faceFrameView?.preCenter = CGPoint(x: (faceObject?.bounds.origin.x)! + (faceObject?.bounds.size.width)! / 2, y: (faceObject?.bounds.origin.y)! + (faceObject?.bounds.size.height)! / 2)
        
        DispatchQueue.main.async {
            self.faceFrameView?.center = (self.faceFrameView?.preCenter)!;
            UIView.animate(withDuration: animateDuration, animations: {
                self.faceFrameView?.frame = faceObject!.bounds
            })
        }
    }
}
