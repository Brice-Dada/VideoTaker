//
//  VideoTakerViewController.swift
//  WKCommonKit
//
//  Created by briceZhao on 2021/1/7.
//

import UIKit
import AVFoundation

class VideoTakerViewController: UIViewController {
    
    private var maxVideoRecordTime = 5.0
    
    private var videoSaveUrl: URL
    
    private var takedVideoComplete: (()->())?

    init(videoSaveUrl: URL, maxRecordTime: Double, completion: (()->())?) {
        self.videoSaveUrl = videoSaveUrl
        self.maxVideoRecordTime = maxRecordTime
        self.takedVideoComplete = completion
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 添加拍摄视频预览视图
        view.layer.addSublayer(captureVideoPreviewLayer)
        
        // 添加拍摄视频播放视图
        view.addSubview(videoPreviewView)
        
        // 视频录制按钮
        view.addSubview(recordButton)
        
        let buttonCancel = VideoDrawArcButton()
        
        buttonCancel.processBgColor = .lightGray
        
        buttonCancel.processWidth = 2
        
        buttonCancel.backgroundColor = .lightGray
        
        buttonCancel.setTitleColor(.white, for: .normal)
        
        buttonCancel.setTitle("✕", for: .normal)
        
        buttonCancel.titleLabel?.font = .boldSystemFont(ofSize: 24)
        
        buttonCancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        view.addSubview(buttonCancel)
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[btnOK(==70)]", options: [], metrics: nil, views: ["btnOK": recordButton])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[btnOK(==70)]-35-|", options: [], metrics: nil, views: ["btnOK": recordButton])
        
        self.view.addConstraints(constraints)
        
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[btnCancel(==40)]", options: [], metrics: nil, views: ["btnCancel": buttonCancel])
        
        self.view.addConstraints(constraints)
        

        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[buttonCancel(==40)]", options: [], metrics: nil, views: ["buttonCancel": buttonCancel])
        
        self.view.addConstraints(constraints)
        
        var constraint = NSLayoutConstraint(item: recordButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: buttonCancel, attribute: .centerY, relatedBy: .equal, toItem: recordButton, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraint(constraint)
        
        /// 完成按钮
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[btn(==60)]-20-|", options: [], metrics: nil, views: ["btn": completeButton])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[btn(==35)]-50-|", options: [], metrics: nil, views: ["btn": completeButton])
        
        self.view.addConstraints(constraints)
        
        self.captureSession.startRunning()
        
    }
    
    // AVCaptureSession提供了视频捕获的功能
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        
        if session.canSetSessionPreset(.high) {
            
            session.sessionPreset = .high
        }
        
        // 添加视频捕捉设备
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            
            if let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
                
                if session.canAddInput(videoInput) {
                    
                    session.addInput(videoInput)
                }
            }
        }
        
        // 添加音频捕捉设备
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            
            if let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                
                if session.canAddInput(audioInput) {
                    
                    session.addInput(audioInput)
                }
            }
        }
        
        return session
    }()
    
    /// 使用 AVCaptureVideoPreviewLayer 可以将摄像头拍摄的画面实时预览
    private lazy var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer = {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.frame = self.view.frame
        
        previewLayer.videoGravity = .resizeAspectFill
        
        previewLayer.masksToBounds = true
        
        return previewLayer
    }()
    
    /// 视频播放图层
    private lazy var videoPreviewView: VideoPreviewView = {
        
        let playView = VideoPreviewView(frame: self.view.frame)
        
        playView.backgroundColor = .clear
        
        playView.isHidden = true
        
        playView.isUserInteractionEnabled = false
        
        return playView
        
    }()
    
    /// 捕捉视频输出流
    private lazy var captureMovieFileOutput: AVCaptureMovieFileOutput = {
        
        let output = AVCaptureMovieFileOutput()
        
        // 设置录制模式
        if let con = output.connection(with: .video) {
            
            if con.isVideoStabilizationSupported {
                
                con.preferredVideoStabilizationMode = .auto
            }
        }
        
        // 添加到捕捉会话
        if captureSession.canAddOutput(output) {
            
            captureSession.addOutput(output)
        }
        
        return output
    }()
    
    /// 拍摄按钮
    private lazy var recordButton: VideoDrawArcButton = {
        
        let button = VideoDrawArcButton()
        
        button.processColor = .green
        
        button.processBgColor = .white
        
        button.processWidth = 4
        
        button.backgroundColor = .red
        
        button.setTitle("■", for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 32)
        
        button.setTitleColor(.red, for: .normal)
        
        button.addTarget(self, action: #selector(startDraw), for: .touchUpInside)
        
        return button
        
    }()
    
    /// 拍摄按钮
    private lazy var completeButton: UIButton = {
        
        let btn = UIButton()
        
        btn.backgroundColor = .red
        
        btn.setTitle("完成", for: .normal)
        
        btn.setTitleColor(.white, for: .normal)
        
        btn.layer.cornerRadius = 5
        
        btn.isHidden = true
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(takedComplete), for: .touchUpInside)
        
        self.view.addSubview(btn)
        
        return btn
        
    }()
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    @objc private func takedComplete() {
        
        close(isTaked: true)
    }
    
    @objc private func cancel() {
        
        close()
    }
    
    private func close(isTaked:Bool = false) {
        
        self.videoPreviewView.stop()
        
        self.captureSession.stopRunning()
        
        if FileManager.default.fileExists(atPath: tempVideoFilePath) {
            
            do {
                
                try FileManager.default.removeItem(atPath: tempVideoFilePath)
                
            } catch {
                
                print("清理临时视频文件失败：\(error)")
            }
        }
        
        if !isTaked, takedVideoComplete != nil {
            
            takedVideoComplete = nil
        }
        
        self.dismiss(animated: true, completion: {
            
            self.takedVideoComplete?()
        })
    }
    
    private lazy var tempVideoFilePath: String = {
        return NSTemporaryDirectory().appending("taked_temp_video.mov")
    }()
    
    /// 录制状态
    private var recordingStatus = 0
    
    /// 录制视频按钮
    @objc private func startDraw() {
        
        self.videoPreviewView.isHidden = true
        
        self.completeButton.isHidden = true
        
        if recordingStatus == 1 {
            
            changeRecordStatus(0)
            
            recordButton.stop()
            
            if self.captureMovieFileOutput.isRecording {
                
                self.captureMovieFileOutput.stopRecording()
            }
            
            return
        }
        
        if recordingStatus == 0 {
            
            changeRecordStatus(1)
            
            startRecordVedio()
            
            recordButton.startWithDuration(duration: maxVideoRecordTime) {
                
                // 视频拍摄时长达到最大，自动结束拍摄
                
                if self.captureMovieFileOutput.isRecording {
                    
                    self.captureMovieFileOutput.stopRecording()
                }
                
                self.changeRecordStatus(0)
            }
            
            return
        }
    }
    
    /// 改变录制按钮状态（0：非录制状态，1：正在录制，2：录制完成）
    private func changeRecordStatus(_ status: Int) {
        
        self.recordingStatus = status
        
        if !captureSession.isRunning {
            
            videoPreviewView.stop()
            
            captureSession.startRunning()
        }
        
        recordButton.backgroundColor = status > 0 ? nil : .red
    }
    
    /// 选择摄像头
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: .video, position: position).devices
        
        return devices.first
    }
    
    /// 开始录制视频
    private func startRecordVedio() {
        
        if !self.captureMovieFileOutput.isRecording {
            
            if let conn = self.captureMovieFileOutput.connection(with: .video) {
                
                if let videoOrientation = self.captureVideoPreviewLayer.connection?.videoOrientation {
                    
                    conn.videoOrientation = videoOrientation
                }
            }
            
            let url = URL(fileURLWithPath: tempVideoFilePath)
            
            // 录制 缓存地址。
            self.captureMovieFileOutput.startRecording(to: url, recordingDelegate: self)
            
        }
    }
    
    private var loadingHud: CommonHud?
    
    /// 显示提示信息
    private func showAlert(message:String) {
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("***deinit***  VideoTakerViewController  deinit")
    }
}

extension VideoTakerViewController: AVCaptureFileOutputRecordingDelegate {
    
    internal func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        // 录制结束压缩视频
        videoCompression()
    }
    
    /// 压缩视频
    private func videoCompression() {
        
        if !FileManager.default.fileExists(atPath: tempVideoFilePath) {
            
            showAlert(message: "视频文件意外丢失")
            
            return
        }
        
        if FileManager.default.fileExists(atPath: videoSaveUrl.path) {
            
            try? FileManager.default.removeItem(atPath: videoSaveUrl.path)
        }
        
        let takedVideoUrl = URL(fileURLWithPath: tempVideoFilePath)
        
        // 加载视频资源
        let asset = AVAsset(url: takedVideoUrl)
        
        // 创建视频资源导出会话
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            
            showAlert(message: "抱歉，获取视频资源导出会话失败")
            
            return
        }
        
        self.captureSession.stopRunning()
        
        // 导出视频路径
        
        session.outputURL = videoSaveUrl
        
        session.shouldOptimizeForNetworkUse = true
        
        // 配置输出属性
        session.outputFileType = .mp4
        
        if loadingHud == nil {
            
            loadingHud = CommonHud()
        }
        
        loadingHud?.show(text: "视频压缩中...", parrent: self.view)
        
        session.exportAsynchronously {
            
            switch session.status {
            
            case .completed:
                
                self.videoPreviewView.videoUrl = takedVideoUrl
                
                self.videoPreviewView.play()
                
                DispatchQueue.main.sync {
                    
                    self.videoPreviewView.isHidden = false
                    
                    self.completeButton.isHidden = false
                    
                    if let loading = self.loadingHud {
                        loading.dismiss()
                    }
                }
                
            case .failed:
                print("video export error: \(session.error?.localizedDescription ?? "")")
            case .cancelled:
                print("video export cancelled")
            case .unknown:
                print("video export unknown")
            case .waiting:
                print("video export waiting")
            case .exporting:
                print("video export exporting")
            @unknown default:
                break
            }
        }
    }
}
