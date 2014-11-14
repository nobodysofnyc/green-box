//
//  ViewController.swift
//  GreenBox
//
//  Created by Mike Kavouras on 11/3/14.
//  Copyright (c) 2014 Mike Kavouras. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate, GKGameCenterControllerDelegate, UICollisionBehaviorDelegate {
    
    let greenSize = CGSize(width: 100, height: 100)
    let blueSize = CGSize(width: 70, height: 70)
    var greenBox = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
    var blueBox = UIView(frame: CGRect(x: 20.0, y: 20.0, width: 10.0, height: 10.0))
    
    let overlayView = UIView()
    
    var animator: UIDynamicAnimator?
    var attach: UIAttachmentBehavior?
    var gravity: UIGravityBehavior?
    var collision: UICollisionBehavior?
    
    var panGesture: UIPanGestureRecognizer?
    
    var timeLeft: Float = 10.0
    
    var timer: NSTimer?
    
    let timerView = TimerView(frame: UIScreen.mainScreen().bounds)
    
    var score = 0
    
    var paused = false
    
    var newGame = true
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUIElements()
        createNewGame()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        figureOutGameCenter()
    }
    
    func addUIElements() {
        overlayView.backgroundColor = UIColor.clearColor()
        overlayView.frame = view.bounds
        view.insertSubview(overlayView, belowSubview: newGameButton)
        view.insertSubview(timerView, atIndex: 0)
    }
    
    func createNewGame() {
        overlayView.hidden = true
        score = 0
        scoreLabel.text = "score: 0"
        newGameButton.hidden = true
        paused = true
        newGame = true
        
        view.backgroundColor = UIColor.whiteColor()
        
        resetViews()
        resetDynamics()
        resetTimer()
        createNewLevel()
    }
    
    func resetViews() {
        greenBox.removeFromSuperview()
        blueBox.removeFromSuperview()
        greenBox = UIView()
        blueBox = UIView()
        greenBox.backgroundColor = UIColor(red: 55/255.0, green: 227/255.0, blue: 85/255.0, alpha: 1.0)
        blueBox.backgroundColor = UIColor(red: 0/255.0, green: 111/255.0, blue: 255/255.0, alpha: 1.0)
        view.insertSubview(greenBox, belowSubview: overlayView)
        view.insertSubview(blueBox, belowSubview: overlayView)
    }
    
    func resetDynamics() {
        animator?.removeAllBehaviors()
        
        animator = UIDynamicAnimator(referenceView: view);
        animator?.delegate = self
        panGesture = UIPanGestureRecognizer(target: self, action: "panning:")
        
        gravity = UIGravityBehavior(items: [greenBox, blueBox])
        collision = UICollisionBehavior(items: [greenBox, blueBox])
        collision?.collisionDelegate = self
        collision?.translatesReferenceBoundsIntoBoundary = true
        
        blueBox.addGestureRecognizer(panGesture!)
    }
    
    func panning(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(view)
        var touchLocation = pan.locationInView(greenBox);
        
        if pan.state == .Began {
            if (newGame) {
                startTimer()
                newGame = false
                animator?.addBehavior(collision!)
            }
            if let animate = animator {
                var offset = UIOffsetMake(touchLocation.x - CGRectGetMidX(greenBox.bounds), touchLocation.y - CGRectGetMidY(greenBox.bounds))
                attach = UIAttachmentBehavior(item: greenBox, offsetFromCenter: offset, attachedToAnchor: location)
                if let att = attach {
                    animate.addBehavior(att)
                }
                animate.addBehavior(gravity!)
            }
            
        } else if pan.state == UIGestureRecognizerState.Changed {
            if let att = attach {
                att.anchorPoint = location
            }
            
        } else if pan.state == UIGestureRecognizerState.Ended {
            animator?.removeBehavior(attach!)
            
            var itemBehavior = UIDynamicItemBehavior(items: [greenBox, blueBox]);
            itemBehavior.addLinearVelocity(pan.velocityInView(view), forItem: greenBox);
            itemBehavior.addLinearVelocity(pan.velocityInView(view), forItem: blueBox);
            itemBehavior.angularResistance = 0;
            itemBehavior.elasticity = 0.2;
            animator?.addBehavior(itemBehavior);
        }
    }
    
    func createNewLevel() {
        let screenWidth = view.frame.size.width - greenSize.width
        let screenHeight = view.frame.size.height - greenSize.height
        
        let greenX = arc4random_uniform(UInt32(screenWidth))
        let greenY = arc4random_uniform(UInt32(screenHeight))
        greenBox.frame = CGRect(x: CGFloat(greenX), y: CGFloat(greenY), width: greenSize.width, height: greenSize.height)
        greenBox.transform = CGAffineTransformIdentity
        
        let blueX = arc4random_uniform(UInt32(screenWidth))
        let blueY = arc4random_uniform(UInt32(screenHeight))
        blueBox.frame = CGRect(x: CGFloat(blueX), y: CGFloat(blueY), width: blueSize.width, height: blueSize.height)
        blueBox.transform = CGAffineTransformIdentity

        while greenTouchingBlue() {
            let blueX = arc4random_uniform(UInt32(screenWidth))
            let blueY = arc4random_uniform(UInt32(screenHeight))
            blueBox.frame = CGRect(x: CGFloat(blueX), y: CGFloat(blueY), width: blueSize.width, height: blueSize.height)
        }
    }
    
    func figureOutGameCenter() {
        let player = GKLocalPlayer.localPlayer()
        println(player.authenticated)
        player.authenticateHandler = {
            (viewController: UIViewController!, error: NSError!) -> Void in
            if viewController != nil {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func goToNextLevel() {
        newGame = true
        
        resetViews()
        resetDynamics()
        createNewLevel()
        resetTimer()
    }
    
    // MARK: Score
    
    func upDatScore() {
        score++
        scoreLabel.text = "score: \(score)"
    }
    
    func postScore() {
        let scoreReporter = GKScore(leaderboardIdentifier: "GreenBoxLeaderboard")
        scoreReporter.value = 1
        scoreReporter.context = 0
        
        let scores = [scoreReporter]
        GKScore.reportScores(scores, withCompletionHandler: { (error: NSError!) -> Void in
            
        })
    }
    
    
    // MARK: Timer
    
    func startTimer() {
        println("start timer")
        paused = false
    }
    
    func stopTimer() {
        paused = true
        println("stop timer")
    }
    
    func endTimer() {
        timer?.invalidate()
    }
    
    func resetTimer() {
        endTimer()
        println("reset timer")
        timeLeft = 10.0
        timerLabel.text = "10.0"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    func timerFired() {
        if !paused {
            timeLeft -= 0.1;
            self.timerLabel.text = NSString(format: "%0.2f", timeLeft)
            if timeLeft <= 0 {
                gameOver();
            }
        }
    }
    
    func gameOver() {
        overlayView.hidden = false
        endTimer()
        postScore()
        view.backgroundColor = UIColor.redColor()
        newGameButton.hidden = false
    }
    
    
    @IBAction func newGameButtonTapped(sender: AnyObject) {
        createNewGame()
    }

    // MARK: Delegate - UIDynamicAnimator
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        let radians = atan2f(Float(blueBox.transform.b), Float(blueBox.transform.a))
        let degrees = radians * Float(180 / M_PI)
        let rotate = round(abs(degrees) % 90)
        println(rotate)
        println(degrees)
        if blueBox.center.y < greenBox.frame.origin.y {
            upDatScore()
            goToNextLevel()
        }
    }
    
    
    // MARK: Delegate - GKGameCenterViewController
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
    }
    
    // MARK: Delegate - UICollisionBehavoir
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        stopTimer()
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying) {
        startTimer()
    }
    
    func greenTouchingBlue() -> Bool {
        let blueFrame = blueBox.frame
        var broked = greenBox.frame.contains(blueFrame.origin)
        broked = broked || greenBox.frame.contains(CGPoint(x: blueFrame.origin.x, y: blueFrame.origin.y + blueFrame.size.height))
        broked = broked || greenBox.frame.contains(CGPoint(x: blueFrame.origin.x + blueFrame.size.width, y: blueFrame.origin.y + blueFrame.size.height))
        broked = broked || greenBox.frame.contains(CGPoint(x: blueFrame.origin.x + blueFrame.size.width, y: blueFrame.origin.y))
        return broked
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

