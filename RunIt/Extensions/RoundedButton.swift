
/**
 *
 *  RoundedButton.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */






import UIKit




@IBDesignable
class RoundedButton: UIButton {

	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet {
			applyCornerRadius()
		}
	}
	
	func applyCornerRadius() {
		self.layer.cornerRadius = cornerRadius
		self.layer.masksToBounds = true
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.applyCornerRadius()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		applyCornerRadius()
	}
}
