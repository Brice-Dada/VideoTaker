//
//  VideoDrawArcButton.swift
//  WKCommonKit
//
//  Created by briceZhao on 2021/1/7.
//

import UIKit

class VideoDrawArcButton: UIButton {

    
    /// 圆环背景色
    var processBgColor:UIColor = .lightGray
    
    /// 圆环进度条颜色
    var processColor:UIColor = .blue
    
    /// 圆环线条宽度
    var processWidth:CGFloat = 4
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        self.layer.cornerRadius = rect.width / 2
        
        self.layer.masksToBounds = true
        
        self.layer.addSublayer(processBackgroundLayer)
        
        self.layer.addSublayer(processLayer)
    }
    
    private var timer:Timer?
    
    func startWithDuration(duration:Double, complete:(()->())?) {
        
        if timer != nil {
            
            timer?.invalidate()
            
            timer = nil
        }
        
        let timeInterval = 0.1
        
        let percent = timeInterval / duration
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (t) in
            
            if self.processLayer.strokeEnd >= 1 {

                t.invalidate()
                
                complete?()
                
                self.restProcess()

                return
            }

            self.processLayer.strokeEnd += CGFloat(percent)
        })
        
    }
    
    func stop() {
        
        timer?.invalidate()
        
        timer = nil
        
        self.restProcess()
    }
    
    /// 重置进度
    func restProcess() {
        
        CATransaction.begin()
        
        CATransaction.setDisableActions(true)
        
        self.processLayer.strokeEnd = 0
        
        CATransaction.commit()
    }
    
    private lazy var layerCenter:CGPoint = {
        
        let bounds = self.bounds
        
        return CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
    }()
    
    private lazy var processLayer: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        
        layer.fillColor = nil
        
        layer.lineJoin = .round
        
        layer.strokeColor = processColor.cgColor
        
        layer.lineWidth = processWidth
        
        layer.path = UIBezierPath(arcCenter: layerCenter, radius: layerCenter.x - processWidth / 2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true).cgPath
        
        layer.strokeStart = 0
        
        layer.strokeEnd = 0
        
        return layer
        
    }()
    
    private lazy var processBackgroundLayer: CAShapeLayer = {
       
        let layer = CAShapeLayer()
        
        layer.fillColor = nil
        
        layer.lineJoin = .round
        
        layer.strokeColor = processBgColor.cgColor
        
        layer.lineWidth = processWidth
        
        layer.path = UIBezierPath(arcCenter: layerCenter, radius: layerCenter.x - processWidth / 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true).cgPath
        
        layer.strokeStart = 0
        
        layer.strokeEnd = 1
        
        return layer
        
    }()

}
