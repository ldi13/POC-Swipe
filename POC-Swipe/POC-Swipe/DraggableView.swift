//
//  DraggableView.swift
//  ios-poc
//
//  Created by Lorenzo DI VITA on 14/07/2017.
//  Copyright (c) 2015 Lorenzo DI VITA. All rights reserved.
//

import UIKit

protocol DraggableViewDelegate: class {
	
	func onSwipedLeft()
	func onSwipedRight()
}

// *********************************************************************
// MARK: - Constants

private enum Constants {
	
	static let actionMargin = CGFloat(120) // Distance from center where the action applies. Higher = swipe further in order for the action to be called
	static let rotationMax = CGFloat(1) // Maximum rotation allowed in radians.  Higher = card can keep rotating longer
	static let rotationStrength = CGFloat(320) // Strength of rotation. Higher = weaker rotation
	static let rotationAngle = CGFloat(Double.pi / 8)
	static let scaleStrength  = CGFloat(4) // How quickly the card shrinks. Higher = slower shrinking
	static let scaleMax = CGFloat(0.93) // Upper bar for how much the card shrinks. Higher = shrinks less
}


class DraggableView: UIView {

	// *********************************************************************
	// MARK: - Properties

	weak var draggableViewDelegate: DraggableViewDelegate!
	
	var panGestureRecognizer: UIPanGestureRecognizer!
	var originalPoint: CGPoint!
	
	fileprivate var xFromCenter: CGFloat!
	fileprivate var yFromCenter: CGFloat!
	
	// *********************************************************************
	// MARK: Lifecycle methods
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(beingDragged(_:)))
		self.addGestureRecognizer(self.panGestureRecognizer)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// *********************************************************************
// MARK: Private methods

private extension DraggableView {
	
	@objc func beingDragged(_ sender: UIPanGestureRecognizer) {
		
		xFromCenter = sender.translation(in: self).x // positive for right swipe, negative for left
		yFromCenter = sender.translation(in: self).y // positive for up, negative for down
		
		switch sender.state {
			
		case .began:
			originalPoint = center

		case .changed:
			// Dictates rotation
			let rotationStrength = min(xFromCenter / Constants.rotationStrength, Constants.rotationMax)

			// Degree change in radians
			let rotationAngle = Constants.rotationAngle * rotationStrength

			// Amount the height changes when you move the card up to a certain point
			let fabsfValue = fabsf(Float(rotationStrength))
			let scale = max(CGFloat(1) - CGFloat(fabsfValue) / Constants.scaleStrength, Constants.scaleMax)

			// Move the object's center by center + gesture coordinate
			center = CGPoint(x: originalPoint.x + xFromCenter, y: originalPoint.y + yFromCenter);

			// Rotate by certain amount
			let transform = CGAffineTransform(rotationAngle: rotationAngle)

			// Scale by certain amount
			let scaleTransform = transform.scaledBy(x: scale, y: scale)

			// Apply transformations
			self.transform = scaleTransform

		case .ended:
			onDragEnded()

		default:
			break
		}
	}
	
	func onDragEnded() {
		
		switch true {
			
		case xFromCenter > Constants.actionMargin:
			performRightAction()
			
		case xFromCenter < -Constants.actionMargin:
			performLeftAction()
			
		default:
			UIView.animate(withDuration: 0.3) {
				self.center = self.originalPoint
				self.transform = CGAffineTransform(rotationAngle: 0)
			}
		}
	}

	func performRightAction() {
		
		let finishPoint = CGPoint(x: 2 * UIScreen.main.bounds.width, y: yFromCenter + originalPoint.y)
		
		UIView.animate(withDuration: 0.3, animations: {
			print(self.center)
			print(finishPoint)
			self.center = finishPoint
		}, completion: { _ in
			self.draggableViewDelegate.onSwipedRight()
		})
	}
	
	func performLeftAction() {
		
		let finishPoint = CGPoint(x: -UIScreen.main.bounds.width, y: yFromCenter + self.originalPoint.y)
		
		UIView.animate(withDuration: 0.3, animations: {
			self.center = finishPoint
		}, completion: { _ in
			self.draggableViewDelegate.onSwipedLeft()
		})
	}
}
