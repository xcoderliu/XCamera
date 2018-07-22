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
    let cameraOperateQueue = DispatchQueue(label: "com.xcoderliu.capture.CameraOperate")
    let btnSetting = UIButton()
    let btnCameraSwitch = UIButton()
    var isFront = false
    
    var captureDevice: AVCaptureDevice?
    
    //avfoundation
    var captureMetaQueue: DispatchQueue?
    var captureSession: AVCaptureSession?
    var captureInput: AVCaptureDeviceInput?
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
    var bQR = false
    let messageLabel = UILabel.init()
    var qrCodeFrameView: UIViewEx?
    
    // 脸部识别
    var bFace = false
    var faceFrameViews: [UIViewFace]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCamera() {
        cameraOperateQueue.async  { [weak self] in
            do {
                self?.captureDevice = AVCaptureDevice.default(for: .video)
                try? self?.captureDevice?.lockForConfiguration()
                self?.captureDevice?.focusMode = .continuousAutoFocus
                self?.captureDevice?.exposureMode = .continuousAutoExposure
                self?.captureDevice?.unlockForConfiguration()
                
                //获取输入设备
                self?.captureInput = try AVCaptureDeviceInput(device: (self?.captureDevice)!)
                self?.captureSession = AVCaptureSession()
                self?.captureSession?.addInput((self?.captureInput)!)
                
                //输出存储
                self?.capturePhotoOutput = AVCapturePhotoOutput()
                self?.capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                if (self?.captureSession?.canAddOutput((self?.capturePhotoOutput)!))!
                {self?.captureSession?.addOutput((self?.capturePhotoOutput)!)}
                
                // 初始化 AVCaptureMetadataOutput  对象并设置成输出设备
                self?.captureMetadataOutput = AVCaptureMetadataOutput()
                if (self?.captureSession?.canAddOutput((self?.captureMetadataOutput)!))!
                {
                    self?.captureSession?.addOutput((self?.captureMetadataOutput)!)
                    self?.captureMetaQueue = DispatchQueue(label: "com.xcoderliu.capture.AVCaptureMetadataOutput")
                    self?.captureMetadataOutput?.setMetadataObjectsDelegate(self, queue: self?.captureMetaQueue)
                    self?.captureMetadataOutput?.metadataObjectTypes = self?.captureMetadataOutput?.availableMetadataObjectTypes
                }
                
                self?.captureSession?.startRunning()
                
                DispatchQueue.main.async {
                    self?.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: (self?.captureSession)!)
                    self?.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self?.videoPreviewLayer?.frame = (self?.view.layer.bounds)!
                    self?.view.layer.addSublayer((self?.videoPreviewLayer)!)
                    self?.setUpViews()
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func switchCamera() {
            clearQR()
            clearFace()
            cameraOperateQueue.async { [weak self] in
            do
            {
                if (self?.captureSession?.isRunning)! {
                    self?.captureSession?.stopRunning()
                }
                self?.captureSession?.removeInput((self?.captureInput!)!)
                
                self?.isFront = !(self?.isFront)!
                self?.captureDevice = self?.getDevice(position: (self?.isFront)! ? .front:.back)
                try? self?.captureDevice?.lockForConfiguration()
                
                if !(self?.isFront)!
                {
                    self?.captureDevice?.focusMode = .continuousAutoFocus
                }
                
                self?.captureDevice?.exposureMode = .continuousAutoExposure
                self?.captureDevice?.unlockForConfiguration()
                self?.captureInput = try AVCaptureDeviceInput(device: (self?.captureDevice!)!)
                self?.captureSession?.addInput((self?.captureInput)!)
                
                self?.captureSession?.startRunning()
            }
            catch {
                print(error)
            }
        }
    }
    
    //Get the device (Front or Back)
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discover = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera,.builtInTelephotoCamera,.builtInDualCamera,.builtInTrueDepthCamera], mediaType: .video, position: position)
        if discover.devices.count > 0 {
            return discover.devices[0]
        }
        return nil
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
        
        //btnsetting
        btnSetting.setImage(#imageLiteral(resourceName: "img_btnSetting"), for: .normal)
        self.view.addSubview(btnSetting)
        btnSetting.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.top.equalTo(self.view.snp.topMargin).offset(4)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        btnSetting.rx.tap.bind {
            
        }.disposed(by: disposeBag)
        
        //btnCameraSwitch
        btnCameraSwitch.setImage(#imageLiteral(resourceName: "img_btnCameraSwitch"), for: .normal)
        self.view.addSubview(btnCameraSwitch)
        btnCameraSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.right).offset(-30)
            make.bottom.equalTo(self.view.snp.bottomMargin).offset(-25)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        btnCameraSwitch.rx.tap.bind {
            self.switchCamera()
        }.disposed(by: disposeBag)
        
        print("setupview end");
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

