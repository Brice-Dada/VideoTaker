//
//  ViewController.swift
//  WKCommonKit
//
//  Created by briceZhao on 2021/1/7.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    /// 原生端和js端交互桥接对象
    private var webviewBridge: WKWebViewJavascriptBridge!
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupUI()
        
        setupWebViewBridge()
    }

    private func setupUI() {
        let conf = WKWebViewConfiguration()
        
        let web = WKWebView(frame: view.bounds, configuration: conf)
        guard let filePath = Bundle.main.path(forResource: "video", ofType: "html") else { return }
        // TODO: 包内文件的地址URL如何获取
        let url = URL(fileURLWithPath: filePath)
        let req = URLRequest(url: url)
        web.load(req)
        view.addSubview(web)
        webView = web
        
        webviewBridge = WKWebViewJavascriptBridge(for: webView)
        webviewBridge.setWebViewDelegate(self)
    }
    
    private func setupWebViewBridge() {
        
        webviewBridge?.registerHandler("takeVideo") { (data, responseCallback) in
            
            let tmpPath = NSTemporaryDirectory().appending("_tmp.mp4")
            
            let url = URL(fileURLWithPath: tmpPath, isDirectory: false)
            
            let vc = VideoTakerViewController(videoSaveUrl: url, maxRecordTime: 15.0) {
                
                ///上传文件
            }
            
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    
    
}
