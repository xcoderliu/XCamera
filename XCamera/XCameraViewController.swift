//
//  ViewController.swift
//  CameraDemo
//
//  Created by 刘智民 on 24/02/2018.
//  Copyright © 2018 刘智民. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import RxCocoa
import RxSwift

let animateDuration = 0.2

class XCameraViewController: UIViewController {
    //公共
    let disposeBag = DisposeBag()
    var captureDevice: AVCaptureDevice?
    
    //avfoundation
    var captureMetaQueue: DispatchQueue?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var captureMetadataOutput: AVCaptureMetadataOutput?
    
    //聚焦
    var focusTap: UITapGestureRecognizer?
    var focusFrameView: UIViewEx?

    //拍照
    let btnCapture = UIButton.init()
    let nBtnCaptureRadius = 28
    
    //QR Code
    let messageLabel = UILabel.init()
    var qrCodeFrameView: UIViewEx?
    
    // 脸部识别
    var faceFrameView: UIViewEx?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initCamera()
        setUpViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCamera() {
        do {
            captureDevice = AVCaptureDevice.default(for: .video)
            try? captureDevice?.lockForConfiguration()
            captureDevice?.focusMode = .continuousAutoFocus
            captureDevice?.exposureMode = .continuousAutoExposure
            captureDevice?.unlockForConfiguration()

            //获取输入设备
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            //输出存储
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            if (captureSession?.canAddOutput(capturePhotoOutput!))! {captureSession?.addOutput(capturePhotoOutput!)}
            
            // 初始化 AVCaptureMetadataOutput  对象并设置成输出设备
            captureMetadataOutput = AVCaptureMetadataOutput()
            if (captureSession?.canAddOutput(captureMetadataOutput!))!
            {
                captureSession?.addOutput(captureMetadataOutput!)
                captureMetaQueue = DispatchQueue(label: "com.xcoderliu.capture.AVCaptureMetadataOutput")
                captureMetadataOutput?.setMetadataObjectsDelegate(self, queue: captureMetaQueue)
                captureMetadataOutput?.metadataObjectTypes = captureMetadataOutput?.availableMetadataObjectTypes
            }

            //设置图形渲染层
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            self.view.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    }
    
    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = view.bounds
        if let previewLayer = videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported)! {
            previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.videoOrientation ?? .portrait
            captureMetadataOutput?.rectOfInterest = self.view.bounds
        }
    }
    
    public func setUpViews() {
        initCapturePhotoUI()
        initQRView()
        initFaceUI()
        initFocus()
    }
    
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}

