/**
*
*  CountDown.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit














class CountDown: UIViewController {
	
	@IBOutlet weak var countDown: UILabel!
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var addTenSeconds: UIButton!
	var counter = 10;
	var timer = Timer()
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// hide tab bar from tabBarController
		self.tabBarController?.tabBar.isHidden = true
		
		// add siri shortcut for starting a new run
		let activity = NSUserActivity(activityType: "run.it.new.run")
		activity.title = "Starte einen neuen Lauf"
		activity.isEligibleForSearch = true
		activity.isEligibleForPrediction = true
		self.userActivity = activity
		self.userActivity?.becomeCurrent()
		
		
		// set up shadows and border radius
		self.startButton.withCorners(cornerRadius: 12.0)
		
		self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(CountDown.updateLabel)), userInfo: nil, repeats: true)
	}
	
	
	
	
	
	
	
	@IBAction func startButtonTapped(_ sender: UIButton) {
		timer.invalidate()
		presentNewRunController()
	}
	
	@IBAction func addTenSecondsTapped(_ sender: UIButton) {
		counter = counter + 10
		countDown.text = String(counter) + "s"
	}
	
	@objc func updateLabel() {
		counter = counter - 1
		countDown.text = String(counter) + "s"
		
		if counter == 0 {
			timer.invalidate()
			presentNewRunController()
		}
	}
	
	func presentNewRunController() {
		self.performSegue(withIdentifier: .newRun, sender: nil)
	}
}























/*

	MARK: COUNT DOWN - NAVIGATION

	-segueIdentifier

*/

extension CountDown: SegueHandlerType {
	enum SegueIdentifier: String {
		case newRun = "NewRunViewController"
	}
}
