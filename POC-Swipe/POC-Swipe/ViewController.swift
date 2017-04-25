//
//  ViewController.swift
//  POC-Swipe
//
//  Created by Lorenzo DI VITA on 02/04/2015.
//  Copyright (c) 2015 Lorenzo DI VITA. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DraggableViewDelegate
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var offers: [String]!
    var draggableViews: [DraggableView]!
    let MAX_BUFFER_SIZE = 2
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setUp()
        self.loadOffers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(self.draggableViews.count)
    }
    
    func setUp()
    {
        self.containerView.autoresizesSubviews = true
        self.offers = ["first", "second", "third", "fourth", "fifth"]
        self.draggableViews = [DraggableView]()
        self.leftButton.addTarget(self, action: Selector("cancelOffer"), for: UIControlEvents.touchUpInside)
        self.rightButton.addTarget(self, action: Selector("validateOffer"), for: UIControlEvents.touchUpInside)
    }
    
    func loadOffers()
    {
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for i in 0 ..< self.MAX_BUFFER_SIZE {
            self.addView(i)
        }
    }
    
    func instantiateOfferViewController(_ colorLabel: String) -> RandomColorViewController
    {
        var offerViewController = self.storyboard?.instantiateViewController(withIdentifier: "randomColorViewController") as! RandomColorViewController
        offerViewController.colorLabelText = colorLabel
        
        return offerViewController
    }
    
    func addView(_ index: Int)
    {
        // Draggable view
        var draggableView = DraggableView(frame: self.containerView.frame)
        draggableView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        draggableView.draggableViewDelegate = self
        
        self.draggableViews.append(draggableView)

        // Draggable view inside containerView
        if self.containerView.subviews.count > 0 {
            self.containerView.insertSubview(draggableView, belowSubview: self.containerView.subviews.last as! UIView)
        }
        
        else {
            self.containerView.addSubview(draggableView)
        }
        
        // Offer View Controller
        var offerViewController = self.instantiateOfferViewController(self.offers[index])
        var offerView = offerViewController.view
        offerView?.frame = self.containerView.frame
        
        // Offer View Controller inside childViewController stack
        self.addChildViewController(offerViewController)
        offerViewController.didMove(toParentViewController: self)
        
        // Offer View into draggable view
        draggableView.addSubview(offerView!)
    }
    
    func updateContainerView()
    {
        if self.offers.count > 0
        {
            self.offers.remove(at: 0)
            
            var draggableView = self.draggableViews.first
            draggableView!.removeFromSuperview()
            self.draggableViews.remove(at: 0)
            
            var childViewControllerToRemove = self.childViewControllers[0] as UIViewController
            childViewControllerToRemove.willMove(toParentViewController: self)
            childViewControllerToRemove.view.removeFromSuperview()
            childViewControllerToRemove.removeFromParentViewController()
        
            if self.offers.count >= self.MAX_BUFFER_SIZE {
                self.addView(self.MAX_BUFFER_SIZE - 1)
            }
        }
    }
    
    
    func validateOffer()
    {
        // Recover draggable view + Animation
        if let draggableView = self.draggableViews.first
        {
            var finishPoint = CGPoint(x: 2 * UIScreen.main.bounds.size.width, y: draggableView.center.y)
            UIView.animate(withDuration: 1, animations: {
                draggableView.center = finishPoint
                draggableView.transform = CGAffineTransform(rotationAngle: 1)
                }, completion: {
                    _ in
                        self.updateContainerView()
            })
        }
    }
    
    
    func cancelOffer()
    {
        // Recover draggable view + Animation
        if let draggableView = self.draggableViews.first
        {
            var finishPoint = CGPoint(x: -UIScreen.main.bounds.size.width, y: draggableView.center.y)
            UIView.animate(withDuration: 1, animations: {
                draggableView.center = finishPoint
                draggableView.transform = CGAffineTransform(rotationAngle: -1)
                }, completion: {
                    _ in
                        self.updateContainerView()
            })
        }
    }
    
    
    // MARK: DraggableViewDelegate methods
    
    func offerSwipedLeft() {
        self.updateContainerView()
    }
    
    func offerSwipedRight() {
        self.updateContainerView()
    }
}

