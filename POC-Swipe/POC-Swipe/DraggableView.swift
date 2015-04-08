//
//  DraggableView.swift
//  POC-Swipe
//
//  Created by Lorenzo DI VITA on 07/04/2015.
//  Copyright (c) 2015 Lorenzo DI VITA. All rights reserved.
//

import UIKit

protocol DraggableViewDelegate: class
{
    func offerSwipedLeft()
    func offerSwipedRight()
}

class DraggableView: UIView
{
    // MARK: Constants
    
    let ACTION_MARGIN = CGFloat(120) //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
    let ROTATION_MAX = CGFloat(1) //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
    let ROTATION_STRENGTH = CGFloat(320) //%%% strength of rotation. Higher = weaker rotation
    let ROTATION_ANGLE = CGFloat(M_PI / 8)
    let SCALE_STRENGTH  = CGFloat(4) //%%% how quickly the card shrinks. Higher = slower shrinking
    let SCALE_MAX = CGFloat(0.93) //%%% upper bar for how much the card shrinks. Higher = shrinks less
    
    
    // MARK: Properties
    
    weak var draggableViewDelegate: DraggableViewDelegate!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originalPoint: CGPoint!
    
    private var xFromCenter: CGFloat!
    private var yFromCenter: CGFloat!
    
    
    // MARK: UIView lifecycle methods
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("beingDragged:"))
        self.addGestureRecognizer(self.panGestureRecognizer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Custom methods
    
    func beingDragged(sender: UIPanGestureRecognizer)
    {
        self.xFromCenter = sender.translationInView(self).x //%%% positive for right swipe, negative for left
        self.yFromCenter = sender.translationInView(self).y //%%% positive for up, negative for down
        
        switch (sender.state)
        {
            //%%% just started swiping
            case UIGestureRecognizerState.Began:
                self.originalPoint = self.center
            
            //%%% in the middle of a swipe
            case UIGestureRecognizerState.Changed:
                //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
                var rotationStrength = min(self.xFromCenter / self.ROTATION_STRENGTH, self.ROTATION_MAX)
                
                //%%% degree change in radians
                var rotationAngle = self.ROTATION_ANGLE * rotationStrength
                
                //%%% amount the height changes when you move the card up to a certain point
                var fabsfValue = fabsf(Float(rotationStrength))
                var scale = max(CGFloat(1) - CGFloat(fabsfValue) / self.SCALE_STRENGTH, self.SCALE_MAX)
                
                //%%% move the object's center by center + gesture coordinate
                self.center = CGPointMake(self.originalPoint.x + self.xFromCenter, self.originalPoint.y + self.yFromCenter);
                
                //%%% rotate by certain amount
                var transform = CGAffineTransformMakeRotation(rotationAngle)

                //%%% scale by certain amount
                var scaleTransform = CGAffineTransformScale(transform, scale, scale)

                //%%% apply transformations
                self.transform = scaleTransform
//                [self updateOverlay:xFromCenter]
            
            //%%% let go of the card
            case UIGestureRecognizerState.Ended:
                self.afterSwipeAction()
            
            default:
                break
        }
    }
    
    func afterSwipeAction()
    {
        if (self.xFromCenter > ACTION_MARGIN) {
            self.rightAction()
        }
            
        else if (self.xFromCenter < -ACTION_MARGIN) {
            self.leftAction()
        }
        
        else
        {
            //%%% resets the card
            UIView.animateWithDuration(0.3, animations: {
                self.center = self.originalPoint
                self.transform = CGAffineTransformMakeRotation(0)
            })
        }
    }
    
    //%%% called when a swipe exceeds the ACTION_MARGIN to the right
    func rightAction()
    {
        var finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y)
        
        UIView.animateWithDuration(0.3, animations: {
                self.center = finishPoint
            }, completion: {
                    _ in
                        self.removeFromSuperview()
        })
        
        self.draggableViewDelegate.offerSwipedRight()
    }
    
    //%%% called when a swipe exceeds the ACTION_MARGIN to the right
    func leftAction()
    {
        var finishPoint = CGPointMake(-500, 2 * yFromCenter + self.originalPoint.y)
        
        UIView.animateWithDuration(0.3, animations: {
            self.center = finishPoint
            }, completion: {
                _ in
                    self.removeFromSuperview()
        })
        
        self.draggableViewDelegate.offerSwipedLeft()
    }
}
