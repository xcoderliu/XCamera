//
//  XCaptureMetadataOutput.swift
//  XCamera
//
//  Created by 刘智民 on 27/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation

extension XCameraViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0
        {
            
            self.handleQr(metadataObj: nil)
            self.handleFace(metaFaceObjs: [])
            return
        }
        
        checkQR(metadataObjects: metadataObjects)
        checkFace(metadataObjects: metadataObjects)
    }
    
    func checkQR(metadataObjects: [AVMetadataObject]) {
        var isExistMRObj = false
        for metaObj in metadataObjects {
            if let metaMRObj = metaObj as?
                AVMetadataMachineReadableCodeObject {
                handleQr(metadataObj: metaMRObj)
                isExistMRObj = true
                break
            }
        }
        if !isExistMRObj {
            handleQr(metadataObj: nil)
        }
    }
    
    func checkFace(metadataObjects: [AVMetadataObject]) {
        var faceObjs: [AVMetadataFaceObject] = []
        for metaObj in metadataObjects {
            if let metaFaceObj = metaObj as?
                AVMetadataFaceObject {
                faceObjs.append(metaFaceObj)
            }
        }
        DispatchQueue.main.async {
            self.handleFace(metaFaceObjs: faceObjs)
        }
    }

    
}
