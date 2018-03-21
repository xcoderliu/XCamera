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
        // 初始化 faceFrame 来突显 脸部
        faceFrameViews = []
    }
    
    func setFaceEnable(enable: Bool) {
        if bFace != enable {
            bFace = enable
            if !bFace
            {
                if ((self.faceFrameViews?.count) != nil)
                {
                    faceViewOut(faceViews: self.faceFrameViews!)
                }
            }
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
    
    private func handleFace (metaFaceObjs:[AVMetadataFaceObject]?) {
        if !bFace {
            return
        }
        var deleteViews = [UIViewFace]()
        var newfaceIDs = [Int]()
        for metaFaceObj in metaFaceObjs! {
            newfaceIDs.append(metaFaceObj.faceID)
        }
        
        //排查已经存在的 faceID 不删除
        for faceView in faceFrameViews! {
            if !newfaceIDs.contains(faceView.faceID)
            {
                deleteViews.append(faceView)
            }
        }
        
        faceViewOut(faceViews: deleteViews)
        
        //add all face obj
        for metaFaceObj in metaFaceObjs! {
            let faceObject = videoPreviewLayer?.transformedMetadataObject(for: metaFaceObj)
            handleFaceView(faceObj: faceObject as! AVMetadataFaceObject)
        }
    }
    
    private func handleFaceView(faceObj: AVMetadataFaceObject){
        if (faceFrameViews?.count ?? 0 > 0) {
            for faceView in faceFrameViews!
            {
                if faceView.faceID == faceObj.faceID
                {
                    //update
                    updateFaceViewByMeta(faceView: faceView, faceObj: faceObj)
                    return
                }
            }
        }
        addFaceView(faceObj: faceObj)
    }
    
    private func addFaceView(faceObj: AVMetadataFaceObject) {
        //add view
        let faceView = UIViewFace()
        faceView.layer.borderColor = UIColor.yellow.cgColor
        faceView.layer.borderWidth = 2
        self.view.addSubview(faceView)
        self.view.bringSubview(toFront: faceView)
        faceView.faceID = faceObj.faceID
        self.faceFrameViews?.append(faceView)
        
        //labtip
        faceView.labelTip = UILabel()
        faceView.labelTip?.textColor = UIColor.yellow
        faceView.clipsToBounds = true
        faceView.addSubview(faceView.labelTip!)
        
        updateFaceViewByMeta(faceView: faceView, faceObj: faceObj)
    }
    
    private func updateFaceViewByMeta(faceView: UIViewFace,faceObj: AVMetadataFaceObject) {
                
        faceView.preCenter = CGPoint(x: (faceObj.bounds.origin.x) + (faceObj.bounds.size.width) / 2, y: (faceObj.bounds.origin.y) + (faceObj.bounds.size.height) / 2)
        
        DispatchQueue.main.async {
            faceView.center = (faceView.preCenter);
            UIView.animate(withDuration: animateDuration, animations: {
                UIView.animate(withDuration: animateDuration, animations: {
                    faceView.frame = faceObj.bounds
                })
            })
        }
    }
    
    private func faceViewOut(faceViews:[UIViewFace])  {
        for faceView in faceViews {
            DispatchQueue.main.async {
                UIView.animate(withDuration: animateDuration, animations: {
                    faceView.frame = CGRect(x: (faceView.preCenter.x), y: (faceView.preCenter.y), width: 0, height: 0)
                }, completion: { _ in
                    let deleteViews :[UIViewFace] = Array.init(faceViews)
                    for faceView in deleteViews
                    {
                        faceView.removeFromSuperview()
                        if let index = (self.faceFrameViews?.index(of: faceView )) {
                            self.faceFrameViews?.remove(at: index)
                        }
                    }
                })
            }
        }
    }
}
