//
//  VideoPreviewView.swift
//  WKCommonKit
//
//  Created by briceZhao on 2021/1/7.
//

import UIKit
import AVFoundation

class VideoPreviewView: UIView {
    
    var videoUrl: URL?
    
    private lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    
    /// 显示器
    private lazy var playerLayer: AVPlayerLayer = {
        
        let layer = AVPlayerLayer(player: player)
        
        layer.frame = self.layer.bounds
        
        layer.videoGravity = .resizeAspect
        
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    /// 播放结束新播放
    @objc private func playToEndTime() {
        
        player.seek(to: .zero)
        
        player.play()
    }
    
    /// 开始播放视频
    func play() {
        
        guard let url = videoUrl else {
            
            print("video url has not been init")
            
            return
        }
        
        let playItem = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: playItem)
        
        player.play()
    }
    
    /// 暂停播放
    func pause() {
        
        player.pause()
    }
    
    func stop() {
        
        player.pause()
        
        player.replaceCurrentItem(with: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
