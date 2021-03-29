/**
*
*  CreateBanner.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import AVFoundation
import MobileCoreServices












class CreateBannerImageCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
}

class CreateBannerAddCell: UICollectionViewCell {
		
	@IBOutlet weak var iconView: UIImageView!
}

class CreateBannerLayerCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
}










class CreateBannerController: UINavigationController {  }

class CreateBanner: UITableViewController {
	
	// Mitgegebene Parameter
	var createBannerType: CreateBannerType!
	var standardTextLayers: [RunBanner.TextLayer] = []
	
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var whatCollectionViewShow: WhatCollectionViewShows = .backgroundImages
	
	var runBanner: RunBanner?
	var textLayers: [RunBanner.TextLayer] = []
	var backgroundImages: [UIImage] = []
	
	// PICKER
	var imagePicker = UIImagePickerController()
	let layerPositionPicker = LayerPositionPicker()
	let layerValuesPicker = LayerValuePicker()

	
	
	
	
	// MARK: viedDidLoad
	
	override func viewDidLoad() {
		
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		
		backgroundImages = RunBanner.backgroundImages
		
		// create RunBanner
		runBanner = RunBanner(whichPhoto: .fernsehturm)
		
		// add textLayers to runBanner
		runBanner!.textLayers = textLayers
		
		// show created banner in imageView
		imageView.image = runBanner!.get()
	}
	
	
	
	
	
	
	
	
	
	
	
	


	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	

	
	
	
	
	
	
	
	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
		
	@IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
		let banner = runBanner!.get()
		
		let imageToShare = [ banner ]
		let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	
	@IBAction func addStandardTapped(_ sender: UIButton) {
		
		switch createBannerType {
			case .run:
				self.runBanner?.textLayers = standardTextLayers
			
			case .success:
				self.runBanner?.textLayers = standardTextLayers
				
			case .none:
				break
		}
		
		refresh()
	}
	
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		
		switch sender.selectedSegmentIndex {
			case 0:
				whatCollectionViewShow = .backgroundImages
				collectionView.reloadData()
				
			case 1:
				whatCollectionViewShow = .backgroundLayers
				collectionView.reloadData()
				
			default:
				break
		}
	}
	
	func refresh() {
		
		self.imageView.image = self.runBanner!.get()
		self.collectionView.reloadData()
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	enum WhatCollectionViewShows {
		case backgroundImages
		case backgroundLayers
	}
	
	enum CreateBannerType {
		case run
		case success
	}
	
	struct CollectionViewImageCell {
		var image: UIImage
		
		init(image: UIImage) {
			self.image = image
		}
	}
	
	struct CollectionViewLayerCell {
		var imageName: String
		var titlePosition: RunBanner.LayerPosition
		var valuePosition: RunBanner.LayerPosition
		var enabled: Bool = true
		
		init(imageName: String, enabled: Bool? = true, titlePosition: RunBanner.LayerPosition, valuePosition: RunBanner.LayerPosition) {
			self.imageName = imageName
			self.titlePosition = titlePosition
			self.valuePosition = valuePosition
		}
	}
}





























/*

	MARK: CREATE BANNER - COLLECTIONVIEW

	-numberOfItemsInSection
	-cellForItemAt
	-contextMenuForCell
	-didSelectItemAt

	-makeContextMenu

*/

extension CreateBanner: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		 
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		if section == 0 {
			
			return 1
			
		} else if section == 1 && whatCollectionViewShow == .backgroundImages {
			
			return self.backgroundImages.count
			
		} else if section == 1 && whatCollectionViewShow == .backgroundLayers {
			
			return self.runBanner!.textLayers.count
		}
		
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if indexPath.section == 0 {
			
			let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
			switch cameraAuthorizationStatus {
				case .notDetermined: self.requestCameraPermission(); requestPhotosPermission()
				case .restricted, .denied: alertCameraAccessNeeded(); alertPhtosAccessNeeded()
				case .authorized: break
			}
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateBannerAddCell", for: indexPath) as! CreateBannerAddCell
			return cell
			
		} else if indexPath.section == 1 && whatCollectionViewShow == .backgroundImages {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateBannerImageCell", for: indexPath) as! CreateBannerImageCell
			
			let backgroundImage = self.backgroundImages[indexPath.row]
			cell.imageView.image = backgroundImage
			
			return cell
			
		} else if indexPath.section == 1 && whatCollectionViewShow == .backgroundLayers {
	
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateBannerLayerCell", for: indexPath) as! CreateBannerLayerCell
			
			let backgroundLayer = self.runBanner!.textLayers[indexPath.row]
			cell.label.text = backgroundLayer.text
			cell.imageView.image = backgroundLayer.layerIcon()
			
			return cell
			
		} else {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateBannerLayerCell", for: indexPath as IndexPath)
			return cell
		}
	}
	
	@available(iOS 13.0, *)
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
			return self.makeContextMenuFor(indexPath: indexPath, self.whatCollectionViewShow)
		})
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		
		if indexPath.section == 0 && whatCollectionViewShow == .backgroundImages {
			
			let alertController = UIAlertController(title: "Foto hinzufügen",
													message: "Von wo möchtest du dein Foto nehmen?",
													preferredStyle: .actionSheet)
			alertController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel))
			alertController.addAction(UIAlertAction(title: "Kamera", style: .default) { _ in
				self.presentCamera()
			})
			alertController.addAction(UIAlertAction(title: "Galerie", style: .default) { _ in
				self.choosePhoto()
			})
			
			present(alertController, animated: true)
			
		} else if indexPath.section == 0 && whatCollectionViewShow == .backgroundLayers {
			
			
			
			let alertController = UIAlertController(title: "Schrift hinzufügen",
													message: "Gebe die Daten ein.",
													preferredStyle: .alert)
			alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
				
				
				self.layerValuesPicker.data = self.standardTextLayers
				self.layerValuesPicker.textField = textField
				
				let picker = UIPickerView()
				picker.delegate = self.layerValuesPicker
				picker.dataSource = self.layerValuesPicker
				
				textField.inputView = picker
				textField.placeholder = "Text"
			})
			
			alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
				
				self.layerPositionPicker.data = RunBanner.positions
				self.layerPositionPicker.textField = textField
				
				let picker = UIPickerView()
				picker.delegate = self.layerPositionPicker
				picker.dataSource = self.layerPositionPicker
				
				textField.inputView = picker
				textField.placeholder = "Position"
			})
			
			
			alertController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel) { _ in })
			alertController.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
						
				self.textLayers.append(RunBanner.TextLayer(text: self.layerValuesPicker.textField!.text!, position: self.layerPositionPicker.value, enabled: true))
				self.runBanner!.textLayers = self.textLayers
			})
			
			present(alertController, animated: true)
			
			
		} else if indexPath.section == 1 && whatCollectionViewShow == .backgroundImages {
			
			// backgroundImages are shown in collectionView
			let backgroundImage = self.backgroundImages[indexPath.row]
			runBanner?.backgroundImage = backgroundImage
			self.imageView.image = runBanner?.get()
			
		} else if indexPath.section == 1 && whatCollectionViewShow == .backgroundLayers {
			
			self.runBanner?.textLayers[indexPath.row].enabled = !(self.runBanner!.textLayers[indexPath.row].enabled)
			self.imageView.image = runBanner?.get()
			self.collectionView.reloadData()
		}
	}
	
	@available(iOS 13.0, *)
	func makeContextMenuFor(indexPath: IndexPath, _ whatCollectionViewShows: WhatCollectionViewShows) -> UIMenu {
		
		var actions: [UIMenuElement] = []
		
		if indexPath.section == 0 {
			
			
		} else if indexPath.section == 1 && whatCollectionViewShow == .backgroundImages {
			
			// create and add „delete" action
			actions.append(UIAction(
				title: "Bild entfernen",
				image: UIImage(systemName: ""), attributes: .destructive) { _ in
				
				self.backgroundImages.remove(at: indexPath.row)
				self.collectionView.reloadData()
			})
			
			// create and add „cancel" action
			actions.append(UIAction(
				title: "Abbrechen",
				image: UIImage(systemName: ""), attributes: .destructive) { _ in })
			
		} else if indexPath.section == 1 && whatCollectionViewShow == .backgroundLayers {
			
			// Erstelle „Dark Style" Aktion
			let darkStyleAction = UIAction(
				title: "Dunkle Schrift",
				image: UIImage(systemName: "")) { _ in
				self.runBanner?.textLayers[indexPath.row].colorStyle = .dark
				self.imageView.image = self.runBanner?.get()
				self.collectionView.reloadData()
			}
			
			// create „Light Style" action
			let lightStyleAction = UIAction(
				title: "Helle Schrift",
				image: UIImage(systemName: "")) { _ in
				self.runBanner?.textLayers[indexPath.row].colorStyle = .light
				self.imageView.image = self.runBanner?.get()
				self.collectionView.reloadData()
			}
			
			// create „Normal Style" action
			let brightStyleAction = UIAction(
				title: "Normale Schrift",
				image: UIImage(systemName: "")) { _ in
				self.runBanner?.textLayers[indexPath.row].colorStyle = .normal
				self.imageView.image = self.runBanner?.get()
				self.collectionView.reloadData()
			}
			
			actions.append(UIMenu(title: "Stil bearbeiten", children: [darkStyleAction, lightStyleAction, brightStyleAction]))
			
			// create and add „delete" action
			actions.append(UIAction(
				title: "Bild entfernen",
				image: UIImage(systemName: ""), attributes: .destructive) { _ in
				
				self.runBanner?.textLayers.remove(at: indexPath.row)
				self.collectionView.reloadData()
			})
			
			// create and add „cancel" action
			actions.append(UIAction(
				title: "Abbrechen",
				image: UIImage(systemName: ""), attributes: .destructive) { _ in })
		}
		
		return UIMenu(title: "", image: UIImage(named: ""), identifier: .none, children: actions)
	}
}





























/*
	
	MARK: CREATE BANNER - CAMERA

	-requestCameraPermission
	-presentCamera
	-alertCameraAccesNeeded

	-imagePickerControll
	-imagePickerControllDidCancel

*/

extension CreateBanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func requestCameraPermission() {
		
		// request permission if its false
		AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
			guard accessGranted == true else { return }
			self.presentCamera()
		})
	}
	
	func requestPhotosPermission() {
		
		// request permission if its false
		AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
			guard accessGranted == true else { return }
			self.choosePhoto()
		})
	}
	
	func presentCamera() {
		
		// check whether the phone has a camera
		if !UIImagePickerController.isSourceTypeAvailable(.camera) {
			let alert = UIAlertController(title: "Keine Kamera", message: "Dieses Gerät besitzt anscheinend keine Kamera.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			self.present(alert, animated: true)
			return
		}
		
		// present camera
		let image = UIImagePickerController()
		image.delegate = self
		image.sourceType = .camera
		image.allowsEditing = true
		self.present(image, animated: true)
	}
	
	func choosePhoto() {
		
		// check whether the phone has a camera
		if !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
			let alert = UIAlertController(title: "Keine Berechtigung", message: "Bitte erlaube RunIt den Zugriff auf deine Fotos.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			self.present(alert, animated: true)
			return
		}
		
		// present camera
		let image = UIImagePickerController()
		image.delegate = self
		image.sourceType = .savedPhotosAlbum
		image.allowsEditing = true
		self.present(image, animated: true)
	}
	
	func alertCameraAccessNeeded() {
		
		// present „Permission is denied" alert
		let alert = UIAlertController(title: "Berechtigung benötigt", message: "Diese App benötigt die Berechtigung für die Kamera.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Freigeben", style: .default) { (_) -> Void in
			// open the app permission in Settings app
			self.requestCameraPermission()
		})
		self.present(alert, animated: true)
	}
	
	func alertPhtosAccessNeeded() {
		
		// present „Permission is denied" alert
		let alert = UIAlertController(title: "Berechtigung benötigt", message: "Diese App benötigt die Berechtigung für deine Fotos.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Freigeben", style: .default) { (_) -> Void in
			// open the app permission in Settings app
			self.requestCameraPermission()
		})
		self.present(alert, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		// get image from info
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			
			// successful
			self.runBanner?.backgroundImage = image
			self.imageView.image = runBanner?.get()
			self.backgroundImages.append(image)
			self.collectionView.reloadData()
			print("RUNIT: successful getting image as UIImage from info")
			
		} else {
			
			// an Error occured
			print("RUNIT: error by getting image as UIImage from info")
		}
		
		self.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}



























/*
	
	MARK: CREATE BANNER - STANDARD

	-runLayers
	-successLayers

*/


extension CreateBanner {
	
	static func runLayers(for run: Run) -> [RunBanner.TextLayer] {
		
		let formattedDuration = FormatDisplay.Banner.duration(seconds: run.duration)
		let formattedDistance = FormatDisplay.Banner.distance(metres: run.distance)
		let formattedDate = FormatDisplay.Banner.date(date: run.date)
		let formattedPace = FormatDisplay.Banner.pace(seconds: run.duration, metres: run.distance)
		
		var textLayers: [RunBanner.TextLayer] = []
		
		textLayers.append(RunBanner.TextLayer(text: "Zeit", position: .bottomLeftTitle, colorStyle: .dark, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: formattedDuration, position: .bottomLeftValue, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: "Distanz", position: .bottomRightTitle, colorStyle: .dark, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: formattedDistance, position: .bottomRightValue, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: "Datum", position: .topRightTitle, colorStyle: .dark, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: formattedDate, position: .topRightValue, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: "Pace min/km", position: .topLeftTitle, colorStyle: .dark, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: formattedPace, position: .topLeftValue, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: "Running", position: .center, enabled: true))
		
		return textLayers
	}
	
	static func successLayers(for values: [ObjectRowDatas]) -> [RunBanner.TextLayer] {
		
		print(values.count)
		
		var textLayers: [RunBanner.TextLayer] = []
		var Index: Int = 0
		
		for (index, value) in values.enumerated() {
			
			Index = 2*index + 1
			if Index < RunBanner.positions.count {
				textLayers.append(RunBanner.TextLayer(text: value.name, position: RunBanner.positions[Index-1], enabled: true))
				textLayers.append(RunBanner.TextLayer(text: value.value, position: RunBanner.positions[Index], colorStyle: .dark, enabled: true))
			}
		}
		
		textLayers.append(RunBanner.TextLayer(text: "Erfolge"))
		
		return textLayers
	}
}
