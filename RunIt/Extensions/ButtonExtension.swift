/**
 *
 *  FormatDisplay.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */

import Foundation
import UIKit

extension UIButton {
	
	func withCorners(cornerRadius: CGFloat = 12.0, masksToBounds: Bool = true, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0), shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 20) {
		self.layer.cornerRadius = cornerRadius
		self.layer.masksToBounds = masksToBounds
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = shadowOffset
		self.layer.shadowOpacity = shadowOpacity
		self.layer.shadowRadius = shadowRadius
	}
}
