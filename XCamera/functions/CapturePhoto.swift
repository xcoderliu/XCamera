//
//  CapturePhotoUI.swift
//  XCamera
//
//  Created by 刘智民 on 26/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit


extension CameraViewController {
    func initCapturePhotoUI() {
        //capture btn setup
        btnCapture.backgroundColor = UIColor.white
        self.view.addSubview(btnCapture)
        btnCapture.snp.makeConstraints { (make) in
            make.width.equalTo(2*nBtnCaptureRadius)
            make.height.equalTo(2*nBtnCaptureRadius)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.snp.bottom).offset(-20)
        }
        btnCapture.layer.cornerRadius = CGFloat(nBtnCaptureRadius)
        btnCapture.clipsToBounds = true
        btnCapture.rx.tap.bind { [weak self] in
            self?.onTapTakePhoto(nil)
            }.disposed(by: disposeBag)
    }
    
    func onTapTakePhoto(_ sender: Any?) {
        // 确保 capturePhotoOutput 是有效的
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // 获取 AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // 设置照片参数
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // 拍照
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // 保存相片到相册
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
