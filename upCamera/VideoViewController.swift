
//
//  ViewController.swift
//  upCamera
//
//  Created by wataokakoki on 2018/02/14.
//  Copyright © 2018年 wataokakoki. All rights reserved.
//


import UIKit
import AVFoundation
import AssetsLibrary
import Social

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var myComposeView: SLComposeViewController!
    
    // ビデオのアウトプット.
    private var myVideoOutput: AVCaptureMovieFileOutput!
    
    // スタートボタン.
    private var myButtonStart: UIButton!
    
    // ストップボタン.
    private var myButtonStop: UIButton!
    
    var startInstance : AVAudioPlayer! = nil
    var stopInstance : AVAudioPlayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // サウンドファイルのパスを生成
        let startFilePath = Bundle.main.path(forResource: "start", ofType: "mp3")!
        let start:URL = URL(fileURLWithPath: startFilePath)
        // AVAudioPlayerのインスタンスを作成
        do {
            startInstance = try AVAudioPlayer(contentsOf: start, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成失敗")
        }
        
        // サウンドファイルのパスを生成
        let stopFilePath = Bundle.main.path(forResource: "stop", ofType: "mp3")!
        let stop:URL = URL(fileURLWithPath: stopFilePath)
        // AVAudioPlayerのインスタンスを作成
        do {
            stopInstance = try AVAudioPlayer(contentsOf: stop, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成失敗")
        }
        
        
        // バッファに保持していつでも再生できるようにする
        startInstance.prepareToPlay()
        stopInstance.prepareToPlay()
        
        // セッションの作成.
        let mySession = AVCaptureSession()
        
        // デバイス.
        var myDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // 出力先を生成.
        let myImageOutput = AVCaptureStillImageOutput()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // マイクを取得.
        let audioCaptureDevice = AVCaptureDevice.devices(for: AVMediaType.audio)
        
        // マイクをセッションのInputに追加.
        let audioInput = try! AVCaptureDeviceInput.init(device: audioCaptureDevice.first as! AVCaptureDevice)
        
        
        // バックカメラを取得.
        let videoInput = try! AVCaptureDeviceInput.init(device: myDevice!)
        
        // ビデオをセッションのInputに追加.
        mySession.addInput(videoInput)
        
        // オーディオをセッションに追加.
        mySession.addInput(audioInput)
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 動画の保存.
        myVideoOutput = AVCaptureMovieFileOutput()
        
        // ビデオ出力をOutputに追加.
        mySession.addOutput(myVideoOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer = AVCaptureVideoPreviewLayer.init(session: mySession)
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
        // UIボタンを作成.
        myButtonStart = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        myButtonStop = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        
        myButtonStart.backgroundColor = UIColor.red
        myButtonStop.backgroundColor = UIColor.gray
        
        myButtonStart.layer.masksToBounds = true
        myButtonStop.layer.masksToBounds = true
        
        myButtonStart.setTitle("Start", for: .normal)
        myButtonStop.setTitle("Stop", for: .normal)
        
        myButtonStart.layer.cornerRadius = 20.0
        myButtonStop.layer.cornerRadius = 20.0
        
        myButtonStart.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height-50)
        myButtonStop.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height-50)
        
        myButtonStart.addTarget(self, action: #selector(ViewController.onClickMyButton), for: .touchUpInside)
        myButtonStop.addTarget(self, action: #selector(ViewController.onClickMyButton), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButtonStart)
        self.view.addSubview(myButtonStop)
        
        // UIボタンを作成.
        let cButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        cButton.backgroundColor = UIColor.orange
        cButton.layer.masksToBounds = true
        cButton.setTitle("■", for: .normal)
        cButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        cButton.layer.cornerRadius = 20.0
        cButton.layer.position = CGPoint(x: self.view.bounds.width - 50, y:self.view.bounds.height-50)
        cButton.addTarget(self, action: #selector(onClickcButton), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(cButton);
    }
    
    /*
     ボタンイベント.
     */
    
    @objc func onClickcButton(sender: UIButton){
        var storyboard: UIStoryboard = self.storyboard!
        var next = storyboard.instantiateViewController(withIdentifier: "ViewController")
        self.present(next as! UIViewController,animated: true, completion: nil)
    }
    
    @objc internal func onClickMyButton(sender: UIButton){
        
        // 撮影開始.
        if( sender == myButtonStart ){
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            // フォルダ.
            let documentsDirectory = paths[0]
            // ファイル名.
            let filePath = "\(documentsDirectory)/test.mp4"
            // URL.
            let fileURL = URL(fileURLWithPath: filePath)
            // 録画開始.
            myVideoOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
            // 撮影停止.
        else if ( sender == myButtonStop ){
            print(0)
            myVideoOutput.stopRecording()
            print(1)
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    /*
     動画がキャプチャー開始時に呼ばれる.
     */
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("start recording")
        startInstance.play()
    }
    
    /*
     動画のキャプチャー終了時に呼ばれる.
     */
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(2)
        stopInstance.play()
        
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() == false {
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if (session != nil) {
                    print("signed in as \(session?.userName)");
                } else {
                    print("error: \(error?.localizedDescription)");
                }
            })
        }
        
        
        
        var check = FileManager()
       
        
        if check.fileExists(atPath:"file:///var/mobile/Containers/Data/Application/4B58DDDD-2BDD-43A5-ABA7-4D19A71E394E/Documents/test.mp4") {
            print("あるよ〜〜〜〜〜")
        } else {
            print("なんーーーにもないよ~~~")
        }
       
        
        
        //let data = try? NSData.init(contentsOfFile: String(describing: outputFileURL), options: .mappedIfSafe)
        
        
        // AssetsLibraryを生成する.
        let assetsLib = ALAssetsLibrary()
        
        // 動画のパスから動画をフォトライブラリに保存する.
        assetsLib.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL, completionBlock: nil)
        
        // guard let session = TWTRTwitter.sharedInstance().sessionStore.session() else {
        //     return
        // }
        // 
        // let apiClient = TWTRAPIClient(userID: session.userID)
        // apiClient.sendTweet(withText: "", videoData: data! as Data, completion:{(success, error) in
        //     if (success != nil) {
        //         print("success")
        //         print("did finish recording to output file at url")
        //     } else {
        //         print("not success")
        //     }
        // })
        
        
    }
}
