//
//  ViewController.swift
//  avfoundation002
//
//  Copyright © 2016年 FaBo, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import TwitterKit


class ViewController: UIViewController {
    
    
    var myComposeView : SLComposeViewController!
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput: AVCaptureStillImageOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices {
            if(device.position == AVCaptureDevice.Position.back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        // バックカメラからVideoInputを取得.
        let videoInput = try! AVCaptureDeviceInput.init(device: myDevice)
        // セッションに追加.
        mySession.addInput(videoInput)
        
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer = AVCaptureVideoPreviewLayer.init(session: mySession)
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
        // UIボタンを作成.
        let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        myButton.backgroundColor = UIColor.red
        myButton.layer.masksToBounds = true
        myButton.setTitle("●", for: .normal)
        myButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 40)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height-50)
        myButton.addTarget(self, action: #selector(onClickMyButton), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButton);
        
        // UIボタンを作成.
        let vButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        vButton.backgroundColor = UIColor.orange
        vButton.layer.masksToBounds = true
        vButton.setTitle("▶︎", for: .normal)
        vButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        vButton.layer.cornerRadius = 20.0
        vButton.layer.position = CGPoint(x: self.view.bounds.width - 50, y:self.view.bounds.height-50)
        vButton.addTarget(self, action: #selector(onClickvButton), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(vButton);
        
    }
    
    @objc func onClickvButton(sender: UIButton){
        var storyboard: UIStoryboard = self.storyboard!
        var next = storyboard.instantiateViewController(withIdentifier: "VideoViewController")
        self.present(next as! UIViewController,animated: true, completion: nil)
    }
    
    
    // ボタンイベント.
    @objc func onClickMyButton(sender: UIButton){
        
        // ビデオ出力に接続.
        // let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        let myVideoConnection = myImageOutput.connection(with: AVMediaType.video)
        
        // 接続から画像を取得.
        self.myImageOutput.captureStillImageAsynchronously(from: myVideoConnection!, completionHandler: {(imageDataBuffer, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            // 取得したImageのDataBufferをJpegに変換.
            let myImageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: imageDataBuffer!, previewPhotoSampleBuffer: nil)
            // JpegからUIIMageを作成.
            var myImage = UIImage(data: myImageData!)
            let rotateImage = UIImage(cgImage: (myImage?.cgImage)!, scale: (myImage?.scale)!, orientation: .up)
            
            
            
            //self.myComposeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            //self.myComposeView.setInitialText("test")
            //self.myComposeView.add(myImage)
            
            
 
            if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() == false {
                TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                    if (session != nil) {
                        print("signed in as \(session?.userName)");
                    } else {
                        print("error: \(error?.localizedDescription)");
                    }
                })
            }
            
            
            guard var session = TWTRTwitter.sharedInstance().sessionStore.session() else {
                return
            }
            
            var apiClient = TWTRAPIClient(userID: session.userID)
            apiClient.sendTweet(withText: "", image: rotateImage, completion: {(success, error) in
                if (success != nil) {
                    print("success is no nil")
                }
            })
        })
    }
    
    

}
