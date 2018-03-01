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
        checkQR(metadataObjects: metadataObjects)
        checkFace(metadataObjects: metadataObjects)
    }
    
}
