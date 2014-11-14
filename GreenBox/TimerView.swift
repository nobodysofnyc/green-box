//
//  TimerView.swift
//  GreenBox
//
//  Created by Mike Kavouras on 11/13/14.
//  Copyright (c) 2014 Mike Kavouras. All rights reserved.
//

import UIKit

class TimerView: UIView {
    
    var leftView: UIView?
    
    var rightView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateForTime() {
        
    }
    
    func addViews() {
        let rect = frame
        
        rightView = UIView(frame: rect)
        rightView?.backgroundColor = UIColor.darkGrayColor()
        rightView?.center = CGPoint(x: -frame.size.width / 2.0, y: center.y)
        
        leftView = UIView(frame: rect)
        leftView?.backgroundColor = UIColor.lightGrayColor()
        leftView?.center = CGPoint(x: frame.size.width, y: center.y)
        
        addSubview(rightView!)
//        addSubview(leftView!)
    }

}
