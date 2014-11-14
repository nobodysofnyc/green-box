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
    
    let time: Float
    
    required init(coder aDecoder: NSCoder) {
        self.time = 0.0
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, time: Float) {
        self.time = time
        super.init(frame: frame)
        addViews()
    }
    
    func updateForTime(time: Float) {
        let width = Float(frame.size.width)
        let diff: Float = (self.time - time) * ((width / 2) / self.time)
        leftView?.center = CGPoint(x: CGFloat((-width / 2.0) + diff),  y: center.y)
        rightView?.center = CGPoint(x: CGFloat((width + (width / 2.0)) - diff), y: center.y)
        
        let alpha = (self.time - time) / self.time
        leftView?.backgroundColor = leftView?.backgroundColor?.colorWithAlphaComponent(CGFloat(alpha))
        rightView?.backgroundColor = rightView?.backgroundColor?.colorWithAlphaComponent(CGFloat(alpha))
    }
    
    func reset() {
        rightView?.center = CGPoint(x: -bounds.size.width / 2.0, y: center.y)
        leftView?.center = CGPoint(x: frame.size.width + (bounds.size.width / 2.0), y: center.y)
    }
    
    
    func addViews() {
        let rect = bounds
        
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: 20.0))
        rightView?.backgroundColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.0)
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: 20.0))
        leftView?.backgroundColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.0)
        
        addSubview(rightView!)
        addSubview(leftView!)
    }

}
