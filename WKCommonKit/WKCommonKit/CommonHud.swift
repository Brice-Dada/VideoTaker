//
//  CommonHud.swift
//  WKCommonKit
//
//  Created by briceZhao on 2021/1/7.
//

import UIKit

class CommonHud: UIView {

    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        loadingView.layer.cornerRadius = 7.66
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)]
        addConstraints(viewConstraints)
        
        let spining = UIActivityIndicatorView()
        spining.color = .white
        spining.startAnimating()
        spining.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(loadingView)
        loadingView.addSubview(spining)
        loadingView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let loadingViewConstraints = [
            NSLayoutConstraint(item: spining , attribute: .centerX, relatedBy: .equal, toItem: loadingView , attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: spining , attribute: .top, relatedBy: .equal, toItem: loadingView , attribute: .top, multiplier: 1, constant: 14),
            NSLayoutConstraint(item: titleLabel , attribute: .centerX, relatedBy: .equal, toItem: loadingView , attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel , attribute: .top, relatedBy: .equal, toItem: spining , attribute: .bottom, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: titleLabel , attribute: .leading, relatedBy: .equal, toItem: loadingView , attribute: .leading, multiplier: 1, constant: 14),
            NSLayoutConstraint(item: loadingView , attribute: .bottom, relatedBy: .equal, toItem: titleLabel , attribute: .bottom, multiplier: 1, constant: 14)
        ]
        loadingView.addConstraints(loadingViewConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.white
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        return lb
    }()
    
    func show(text: String, parrent: UIView?) {
        self.titleLabel.text = text
        self.show(parrent: parrent)
    }
    
    func show(parrent: UIView?){
        let parrentView = parrent ?? UIApplication.shared.keyWindow!
        parrentView.addSubview(self)
    }
    
    func dismiss(){
        if nil != self.superview {
            self.removeFromSuperview()
        }
    }

    deinit {
        print("***deinit*** CommonHud deinit ***")
    }
}
