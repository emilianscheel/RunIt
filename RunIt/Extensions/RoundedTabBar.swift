/**
*
*  RoundedTabBar.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import UIKit












class RoundedTabBar: UITabBar {

	private var shapeLayer: CALayer?
	
	private func addShape() {
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = createPath()
		shapeLayer.strokeColor = UIColor.opaqueSeparator.cgColor
		shapeLayer.fillColor = UIColor.secondarySystemGroupedBackground.cgColor
		shapeLayer.lineWidth = 0.5

		if let oldShapeLayer = self.shapeLayer {
			self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
		} else {
			self.layer.insertSublayer(shapeLayer, at: 0)
		}
		self.shapeLayer = shapeLayer
	}
	
	override func draw(_ rect: CGRect) {
		self.addShape()
	}
	
	func createPath() -> CGPath {
		let height: CGFloat = 37.0
		let path = UIBezierPath()
		let centerWidth = self.frame.width / 2
		path.move(to: CGPoint(x: 0, y: 0)) // start top left
		path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough

		path.addCurve(to: CGPoint(x: centerWidth, y: height),
		controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))

		path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
		controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))

		path.addLine(to: CGPoint(x: self.frame.width, y: 0))
		path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
		path.addLine(to: CGPoint(x: 0, y: self.frame.height))
		path.close()

		return path.cgPath
	}
	
	static func middleButton(for view: UIView) -> UIButton {

		let middleBtn = UIButton(frame: CGRect(x: (view.bounds.width / 2)-23, y: -18, width: 46, height: 46))
		middleBtn.backgroundColor = UIColor.systemBlue
		middleBtn.layer.cornerRadius = middleBtn.frame.size.height / 2
		middleBtn.setImage(UIImage(systemName: "plus"), for: .normal)
		middleBtn.tintColor = .white
		
		return middleBtn
	}
}
