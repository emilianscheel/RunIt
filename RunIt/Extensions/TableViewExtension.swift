

import Foundation
import UIKit

extension UITableView {

	func addMessage(_ message: String) {
		
		let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
		messageLabel.text = message
		messageLabel.textColor = .label
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		messageLabel.font = UIFont(name: "Avenir-Medium", size: 15)
		messageLabel.sizeToFit()
		
		self.backgroundView = messageLabel
		self.separatorStyle = .none
	}

	func restore() {
		self.backgroundView = nil
		self.separatorStyle = .singleLine
	}
}
