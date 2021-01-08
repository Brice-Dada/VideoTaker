//
//  ScannerViewController.swift
//  WKCommonKit
//
//  Created by briceZhao on 2021/1/8.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    /// 扫描结果返回
    var scanerCompletion:((_ result:String)->Void)?
    
    /// 扫描框周围间隔
    private let _scannerViewMargin:CGFloat = 55
    
    /// 顶部区域
    private lazy var _headView:UIView = {
       
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(hexString: "#232126")
        
        self.view.addSubview(view)
        
        return view
        
    }()
    
    /// 扫描视图
    private lazy var _scannerView:UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.borderColor = UIColor(hexString: "#000000", alpha: 0.7)?.cgColor
        
        view.layer.borderWidth = _scannerViewMargin
        
        self.view.addSubview(view)
        
        return view
        
    }()
    
    /// 底部视图
    private lazy var _bottomView:UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(hexString: "#000000", alpha: 0.7)
        
        self.view.addSubview(view)
        
        return view
        
    }()
    
    private lazy var _scannerLine:UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "scan_Line")
        
        return imageView
        
    }()
    
    private var _scannerViewY:CGFloat = 0
    
    private let _windowWidth = UIScreen.main.bounds.width
    
    private let _windowHeight = UIScreen.main.bounds.height
    
    private let _marginBottom: CGFloat = (UIApplication.shared.statusBarFrame.height == 20) ? 15 : 20

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mainViewLayout()
        
        /// 相机权限检测
        checkPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 开始捕获
        _captureSession.startRunning()
    }
    
    /// 检查相机权限
    private func checkPermission(){
        
        if AVCaptureDevice.authorizationStatus(for: .video) != AVAuthorizationStatus.authorized {
            
            _ = CommonFunc.confirmAlert(parentController: self, title: "无法使用相机", message: "请在手机的\"设置-隐私-相机\"中允许访问相机", okText: "前往设置") { (isok) in
                
                if isok {
                    
                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                        
                        return
                    }
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
    }
    
    /// 主视图布局
    private func mainViewLayout() {
        
        let viewMargin = UIView()
        
        viewMargin.backgroundColor = UIColor(hexString: "#000000", alpha: 0.7)
        
        viewMargin.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(viewMargin)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headView]-0-|", options: [], metrics: nil, views: ["headView":_headView])
        
        self.view.addConstraints(constraints)
        
        let headViewHeight:CGFloat = 34 + UIApplication.shared.statusBarFrame.height
        
        let marginViewHeight:CGFloat = (_windowHeight-headViewHeight-_windowWidth-_marginBottom-40) / 2 - 50
        
        _scannerViewY = headViewHeight + marginViewHeight
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headView(hheight)]-0-[marginView(marginViewHeight)]-0-[scannerView(sheight)]-0-[bottomView]-0-|", options: [.alignAllLeft, .alignAllRight], metrics: ["hheight": headViewHeight, "sheight": _windowWidth, "marginViewHeight": marginViewHeight], views: ["headView":_headView, "scannerView":_scannerView, "bottomView":_bottomView, "marginView": viewMargin])
        
        self.view.addConstraints(constraints)
        
        
        let tipLabel = UILabel()
        
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tipLabel.text = "放入框内，自动扫描"
        
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        
        tipLabel.textColor = UIColor(hexString: "#ddd")
        
        tipLabel.textAlignment = NSTextAlignment.center
        
        self.view.addSubview(tipLabel)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[scannerView]-(-35)-[tipLabel]", options: [], metrics: nil, views: ["tipLabel": tipLabel,"scannerView": _scannerView])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tipLabel]-0-|", options: [], metrics: nil, views: ["tipLabel": tipLabel])
        
        self.view.addConstraints(constraints)
        
        headViewLayout()
        
        bottomViewLayout()
        
        sannerViewLayout()
        
        initCamera()
    }
    
    /// 底部视图布局
    private func headViewLayout() {
        
        let backButton = UIButton()
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setTitle("く", for: .normal)
        
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        backButton.showsTouchWhenHighlighted = true
        
        backButton.addTarget(self, action: #selector(backButtonAction(sender:)), for: .touchUpInside)
        
        _headView.addSubview(backButton)
        
        
        let title = UILabel()
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        title.text = "扫一扫"
        
        title.textColor = .white
        
        title.textAlignment = .center
        
        _headView.addSubview(title)
        
        
        let photoButton = UIButton()
        
        photoButton.setTitle("相册", for: .normal)
        
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        
        photoButton.showsTouchWhenHighlighted = true
        
        photoButton.addTarget(self, action: #selector(photoButtonAction(sender:)), for: .touchUpInside)
        
        _headView.addSubview(photoButton)
        
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backButton(==50)]-0-[title]-0-[photoButton(==40)]-15-|", options: [.alignAllCenterY], metrics: nil, views: ["backButton": backButton,"title":title, "photoButton": photoButton])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[backButton(==34)]-0-|", options: [], metrics: nil, views: ["backButton": backButton])
        
        self.view.addConstraints(constraints)
        
    }
    
    /// 扫描区域相关视图布局（边框、边角、扫描线）
    private func sannerViewLayout() {
        
        let rectView = UIView()
        
        rectView.translatesAutoresizingMaskIntoConstraints = false
        
        rectView.layer.borderWidth = 0.5
        
        rectView.layer.borderColor = UIColor.gray.cgColor
        
        _scannerView.addSubview(rectView)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[rectView]-margin-|", options: [], metrics: ["margin": _scannerViewMargin ], views: ["rectView": rectView])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[rectView]-margin-|", options: [], metrics: ["margin": _scannerViewMargin ], views: ["rectView": rectView])
        
        self.view.addConstraints(constraints)
        
        
        var imageCorner = UIImageView()
        
        imageCorner.translatesAutoresizingMaskIntoConstraints = false
        
        imageCorner.image = UIImage(named: "scan_TopLeft")
        
        rectView.addSubview(imageCorner)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageCorner(==18)]", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageCorner(==18)]", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        imageCorner = UIImageView()
        
        imageCorner.translatesAutoresizingMaskIntoConstraints = false
        
        imageCorner.image = UIImage(named: "scan_TopRight")
        
        rectView.addSubview(imageCorner)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imageCorner(==18)]-0-|", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageCorner(==18)]", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        imageCorner = UIImageView()
        
        imageCorner.translatesAutoresizingMaskIntoConstraints = false
        
        imageCorner.image = UIImage(named: "scan_BottomRight")
        
        rectView.addSubview(imageCorner)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imageCorner(==18)]-0-|", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imageCorner(==18)]-(-1.4)-|", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        
        imageCorner = UIImageView()
        
        imageCorner.translatesAutoresizingMaskIntoConstraints = false
        
        imageCorner.image = UIImage(named: "scan_BottomLeft")
        
        rectView.addSubview(imageCorner)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageCorner(==18)]", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imageCorner(==18)]-(-1.4)-|", options: [], metrics: nil, views: ["imageCorner": imageCorner])
        
        self.view.addConstraints(constraints)
        
        rectView.addSubview(_scannerLine)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[sannerLine]-0-|", options: [], metrics: nil, views: ["sannerLine": _scannerLine])
        
        self.view.addConstraints(constraints)
        
        let centerHeight = (_windowWidth - _scannerViewMargin * 2 - 2 ) / 2
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[sannerLine(==2)]", options: [], metrics: ["margin": centerHeight], views: ["sannerLine": _scannerLine])
        
        self.view.addConstraints(constraints)
        
    }
    
    /// 底部布局
    private func bottomViewLayout() {
        
        /// 手电筒
        
        let _lightButton = UIButton()
        
        _lightButton.translatesAutoresizingMaskIntoConstraints = false
        
        _lightButton.setImage(UIImage(named: "scan_btn5"), for: .normal)
        
        _lightButton.setImage(UIImage(named: "scan_btn6"), for: .selected)
        
        _lightButton.addTarget(self, action: #selector(lightButtonAction(sender:)), for: .touchUpInside)
        
        _bottomView.addSubview(_lightButton)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-marginLeft-[lightButton(==40)]", options: [], metrics: ["marginLeft": (_windowWidth - 40) / 2 ], views: ["lightButton": _lightButton])
        
        self.view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[lightButton(==40)]-marginBottom-|", options: [], metrics: ["marginBottom": _marginBottom], views: ["lightButton": _lightButton])
        
        self.view.addConstraints(constraints)
        
    }
    
    /// 返回按钮事件
    @objc private func backButtonAction(sender:UIButton) {
        
        sender.isEnabled = false
        
        self._scannerLineAnimationTimer.invalidate()
        
        self._captureSession.stopRunning()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /// 手电筒按钮事件
    @objc private func lightButtonAction(sender:UIButton) {
        
        sender.isEnabled = false
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            
            return
        }
        
        if !device.hasTorch {
            
            return
        }
        
        sender.isSelected = device.torchMode != .on
        
        let model: AVCaptureDevice.TorchMode = device.torchMode == .on ? .off : .on
        
        do {
            try device.lockForConfiguration()
            
            device.torchMode = model
            
            let flashOff = (model == .off)
            
            device.flashMode = flashOff ? .off : .on
            
            device.unlockForConfiguration()
            
        } catch {
            
            
        }
        
        sender.isEnabled = true
        
    }
    
    /// 相册按钮事件
    @objc private func photoButtonAction(sender:UIButton) {
        
        sender.isEnabled = false
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            CommonFunc.alertMessage(title: "提示", message: "无权限访问相册")
            
            return
        }
        
        //1.初始化相册拾取器
        let controller = UIImagePickerController()
        
        //2.设置代理
        controller.delegate = self
        
        //3.设置资源
        controller.sourceType = .photoLibrary
        
        self.present(controller, animated: true, completion: {
            
            self._captureSession.stopRunning()
            
            sender.isEnabled = true
        })
        
    }
    
    /// 动画控制器
    private lazy var _scannerLineAnimationTimer:Timer = {
       
        let timer = Timer(timeInterval: 0.01, target: self, selector: #selector(scannerLineAnimation), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: .default)
        
        return timer
        
    }()
    
    /// 扫描线执行动画
    @objc private func scannerLineAnimation() {
        
        var currentY = _scannerLine.frame.origin.y
        
        let mainHeight = _windowWidth - _scannerViewMargin * 2
        
        if currentY > mainHeight {
            
            currentY = -5
            
            self._scannerLine.frame = CGRect(x: 0, y: currentY + 1, width: mainHeight, height: 2)
        
            // 不执行延迟动画 屏蔽跳动错觉
            return
        }
        
        // 动画削弱跳动感
        UIView.animate(withDuration: 0.01) {
            
            self._scannerLine.frame = CGRect(x: 0, y: currentY + 1, width: mainHeight, height: 2)
            
        }
        
    }
    
    /// 连接对象会话
    private lazy var _captureSession: AVCaptureSession = {
        
        let session = AVCaptureSession()
        
        session.sessionPreset = .high
        
        return session
    }()
    
    /// 设置相机
    private func initCamera() {
    
        // 获取摄像头设备
        guard let camera = AVCaptureDevice.default(for: .video) else {
            return
        }
    
        // 创建输入流
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        // 创建输出流
        let output = AVCaptureMetadataOutput()
        
        // 设置会话输入流
        _captureSession.addInput(input)
        
        // 设置会话输出流
        _captureSession.addOutput(output)
        
        /// 设置输出代理类型
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [.qr]
        
        let sx = (_scannerViewY + _scannerViewMargin) / self.view.frame.height
        
        let sy =  _scannerViewMargin / self.view.frame.width
        
        let sw = (_windowWidth - _scannerViewMargin) / self.view.frame.height
        
        let sh = (_windowWidth - _scannerViewMargin) / self.view.frame.width
        
        output.rectOfInterest = CGRect(x: sx, y: sy, width: sw, height: sh)
        
        // 设置视频预览层
        
        let layer = AVCaptureVideoPreviewLayer(session: _captureSession)
        
        layer.frame = self.view.frame
        
        layer.videoGravity = .resizeAspectFill
        
        self.view.layer.insertSublayer(layer, at: 0)
    }
    
    /// AVCaptureMetadataOutputObjectsDelegate
    
    internal func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            
            if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                
                if let qrcode = metadataObj.stringValue {
                    
                    scanResultDeal(result: qrcode)
                }
                
            }
        }
    }
    
    /// UIImagePickerControllerDelegate
    
    /// 取消相册选择
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// 相册选择图片
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var qrcode = ""
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            if let imageData = image.pngData() {
                
                if let ciImage = CIImage(data: imageData) {
                    
                    if let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow]) {
                        
                        let features = detector.features(in: ciImage)
                        
                        for feature in features {
                            
                            if let qrcodeFeature = feature as? CIQRCodeFeature {
                                
                                if let msg = qrcodeFeature.messageString {
                                    
                                    qrcode = qrcode.isEmpty ? "\(msg)" : "\(qrcode);\(msg)"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        picker.dismiss(animated: true) {
            
            self.scanResultDeal(result: qrcode)
            
        }
        
    }
    
    /// 声音提醒
    private func playSound() {
        
        //建立的SystemSoundID对象
        let soundID: SystemSoundID = 1255
        
        //播放声音
        AudioServicesPlayAlertSound(soundID)
    }
    
    /// 处理扫描结果
    private func scanResultDeal(result:String){
        
        playSound()
        
        self._scannerLineAnimationTimer.invalidate()
        
        self._captureSession.stopRunning()
        
        self.dismiss(animated: true) {
            
            self.scanerCompletion?(result)
        }
    }
}

/// MARK: 颜色类扩展
extension UIColor {
    
    // 十六进制字符串转颜色构造函数, 默认透明度1.0
    convenience init?(hexString: String, alpha: Float = 1.0) {
        
        // 空白和换行字符集
        let set = CharacterSet.whitespacesAndNewlines
        
        // 移出空白和换行，转大写字母
        var hex = hexString.trimmingCharacters(in: set).uppercased()
        
        // 移出开始'#'字符
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        
        // 转10进制数据
        guard let hexVal = Int(hex, radix: 16) else {
            self.init()
            return nil
        }
        
        switch hex.count {
        case 6:
            self.init(hex6: hexVal, alpha: alpha)
        default:
            self.init()
            return nil
        }
    }
    
    // 十六进制字符串转颜色构造函数, 默认透明度1.0
    convenience init?(hexNumber: Int, alpha: Float = 1.0) {
        
        guard (0x000000 ... 0xFFFFFF) ~= hexNumber else {
            self.init()
            return nil
        }
        self.init(hex6: hexNumber, alpha: alpha)
    }
    
    private convenience init?(hex6: Int, alpha: Float) {
        
        self.init(red:   CGFloat( (hex6 & 0xFF0000) >> 16 ) / 255.0,
                  green: CGFloat( (hex6 & 0x00FF00) >> 8 ) / 255.0,
                  blue:  CGFloat( (hex6 & 0x0000FF) >> 0 ) / 255.0,
                  alpha: CGFloat(alpha))
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF
        let a = alpha
        
        self.init(red: CGFloat(r) / 0xFF,  green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: a)
        
    }
}
