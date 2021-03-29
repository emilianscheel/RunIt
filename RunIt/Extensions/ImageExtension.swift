/**
*
*  ImageExtension.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/





import Foundation
import UIKit
import MapKit
import CoreImage

class RunBanner {
	
	private var renderer: UIGraphicsImageRenderer?
	private var areaSize: CGRect?
	var backgroundImage: UIImage?
	var textLayers: [TextLayer] = []
	
	init(whichPhoto: Image) {
		
		// get background image
		switch whichPhoto {
			case .fernsehturm:
				backgroundImage = UIImage(named: Image.fernsehturm.rawValue)
			case .fernsehturm2:
				backgroundImage = UIImage(named: Image.fernsehturm2.rawValue)
			case .chicago:
				backgroundImage = UIImage(named: Image.chicago.rawValue)
			case .chicago2:
				backgroundImage = UIImage(named: Image.chicago2.rawValue)
			case .goettingen:
				backgroundImage = UIImage(named: Image.goettingen.rawValue)
		}
	}
	
	init(whichPhoto: UIImage) {
		
		backgroundImage = whichPhoto
	}
	
	init(textLayers: [TextLayer]) {
		self.textLayers = textLayers
	}
	
	
	func delete(position: LayerPosition) {
		let newTextLayers = textLayers.filter { $0.position != position }
		textLayers = newTextLayers
	}
	
	func delete(position: [LayerPosition]) {
		var newTextLayers: [TextLayer] = []
		for l in position {
			newTextLayers = textLayers.filter { $0.position != l }
		}
		textLayers = newTextLayers
	}
	
	func hasLayers(position: [LayerPosition]) -> Bool {
		var count: Int = 0
		for i in self.textLayers {
			for l in position {
				if i.position == l {
					count = count +  1
				}
			}
		}
		if count>0 {return true}
		else {return false}
	}
	
	static func standard(for run: Run) -> UIImage {
		let distance = FormatDisplay.distance.from(run.distance)
		let duration = FormatDisplay.duration.from(run.duration)
		return RunBanner.standard(distance: distance, duration: duration)
	}
	
	static func standard(for target: Target) -> UIImage {
		let distance = FormatDisplay.distance.from(target.distance)
		let duration = FormatDisplay.duration.from(target.duration)
		return RunBanner.standard(distance: distance, duration: duration)
	}
	
	static func standard(distance: String, duration: String) -> UIImage {
			
		let textLayers = standardLayers(distance: distance, duration: duration)
			
		let runBanner = RunBanner(whichPhoto: .fernsehturm)
		runBanner.textLayers = textLayers
		
		return runBanner.get()
	}
	
	static func standardLayers(distance: String, duration: String) -> [RunBanner.TextLayer] {
			
		var textLayers: [RunBanner.TextLayer] = []
		textLayers.append(RunBanner.TextLayer(text: "Running", position: .center, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: distance, position: .bottomRightValue, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: "Distanz", position: .bottomRightTitle, colorStyle: .dark, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: duration, position: .bottomLeftValue, enabled: true))
		textLayers.append(RunBanner.TextLayer(text: "Zeit", position: .bottomLeftTitle, colorStyle: .dark, enabled: true))
			
		return textLayers
	}
	
	func get() -> UIImage {
		
		// set up size of it
		areaSize = CGRect(x: 0, y: 0, width: 886.0, height: 886.0)
		renderer = UIGraphicsImageRenderer(size: CGSize(width: areaSize!.width, height: areaSize!.height))
		
		
		let alleTexte = renderer!.image { ctx in
			
			for text in self.textLayers {
				
				if !text.enabled {
					continue
				}
				
				// create text
				var textSize: CGFloat?
				var fontFamily: String?
				var textColor: UIColor?
				var position: CGRect?
				let paragraphStyle = NSMutableParagraphStyle()
				
				switch text.position {
					case .bottomLeftValue:
						
						// BOTTOM LEFT VALUE
						paragraphStyle.alignment = .left
						textSize = 64
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 26, y: areaSize!.height-110, width: areaSize!.width, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .white
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .bottomLeftTitle:
						
						// BOTTOM LEFT TITLE
						paragraphStyle.alignment = .left
						textSize = 38
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 26, y: areaSize!.height-155, width: areaSize!.width, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .lightGray
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .topLeftValue:
						
						// TOP LEFT VALUE
						paragraphStyle.alignment = .left
						textSize = 64
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 26, y: 22, width: areaSize!.width, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .white
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .topLeftTitle:
						
						// TOP LEFT TITLE
						paragraphStyle.alignment = .left
						textSize = 38
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 26, y: 94, width: areaSize!.width-43, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .lightGray
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .topRightValue:
						
						// TOP RIGHT VALUE
						paragraphStyle.alignment = .right
						textSize = 64
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 0, y: 22, width: areaSize!.width-43, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .white
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .topRightTitle:
						
						// TOP RIGHT TITLE
						paragraphStyle.alignment = .right
						textSize = 38
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 0, y: 94, width: areaSize!.width-43, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .lightGray
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .bottomRightValue:
						
						// BOTTOM RIGHT VALUE
						paragraphStyle.alignment = .right
						textSize = 64
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 0, y: areaSize!.height-110, width: areaSize!.width-43, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .white
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .bottomRightTitle:
						
						// BOTTOM RIGHT TITLE
						paragraphStyle.alignment = .right
						textSize = 38
						fontFamily = "HelveticaNeue-CondensedBold"
						position = CGRect(x: 0, y: areaSize!.height-155, width: areaSize!.width-43, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .lightGray
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
					case .center:
						
						// CENTER
						paragraphStyle.alignment = .center
						textSize = 168
						fontFamily = "HelveticaNeue-CondensedBlack"
						position = CGRect(x: 0, y: 350, width: areaSize!.width, height: areaSize!.height)
						
						// BOTTOM LEFT VALUE - COLOR STYLE
						switch text.colorStyle {
							case .normal:
								textColor = .white
							case .dark:
								textColor = .darkGray
							case .light:
								textColor = .white
						}
				}
				
				let attrs = [NSAttributedString.Key.font: UIFont(name: fontFamily!, size: textSize!)!, NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: textColor!]
				text.text.draw(with: position!, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
			}
		}
		
		// begin drawing image
		UIGraphicsBeginImageContext(areaSize!.size)
		
		backgroundImage!.cropsToSquare().vignetteFilter().draw(in: areaSize!)
		
		alleTexte.draw(in: areaSize!, blendMode: .normal, alpha: 0.8)
		
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	
	
	enum Image: String {
		
		case fernsehturm =  "IMG_1"
		case fernsehturm2 = "IMG_2"
		case chicago = "IMG_3"
		case chicago2 = "IMG_4"
		case goettingen = "IMG_5"
	}
	
	enum LayerPosition: String {
		
		case bottomLeftValue = "Unten Links Groß"
		case bottomLeftTitle = "Unten Links Klein"
		
		case topLeftValue = "Oben Links Groß"
		case topLeftTitle = "Oben Links Klein"
		
		case topRightValue = "Oben Rechts Groß"
		case topRightTitle = "Oben Rechts Klein"
		
		case bottomRightValue = "Unten Rechts Groß"
		case bottomRightTitle = "Unten Rechts Klein"
		
		case center = "Mitte"
	}
	
	
	enum LayerColor {
		
		case normal
		case dark
		case light
	}
	
	
	static let positions: [RunBanner.LayerPosition] = [(.bottomLeftValue),
												(.bottomLeftTitle),
												(.bottomRightValue),
												(.bottomRightTitle),
												(.topLeftValue),
												(.topLeftTitle),
												(.topRightValue),
												(.topRightTitle),
												(.center)]
	
	static let backgroundImages: [UIImage] = [UIImage(named: "IMG_1")!,
											 UIImage(named: "IMG_2")!,
											 UIImage(named: "IMG_3")!,
											 UIImage(named: "IMG_4")!,
											 UIImage(named: "IMG_5")!]
	
	
	class TextLayer {
		
		var text: String
		var position: LayerPosition
		var colorStyle: LayerColor
		var enabled: Bool
		
		init(text: String, position: LayerPosition = .center, colorStyle: LayerColor = .normal, enabled: Bool = true) {
			self.text = text
			self.position = position
			self.colorStyle = colorStyle
			self.enabled = enabled
		}
		
		@available(iOS 13.0, *)
		func layerIcon() -> UIImage {
			switch position {
				case .bottomLeftTitle, .bottomLeftValue:
					return UIImage(systemName: "rectangle.inset.bottomleft.fill")!
					
				case .bottomRightTitle, .bottomRightValue:
					return UIImage(systemName: "rectangle.inset.bottomright.fill")!
					
				case .topRightTitle, .topRightValue:
					return UIImage(systemName: "rectangle.inset.topright.fill")!
					
				case .topLeftTitle, .topLeftValue:
					return UIImage(systemName: "rectangle.inset.topleft.fill")!
				case .center:
					return UIImage(systemName: "rectangle.center.inset.fill")!
			}
		}
	}
}

extension UIImage {
	
	func cropsToSquare() -> UIImage {
		let refWidth = CGFloat((self.cgImage!.width))
		let refHeight = CGFloat((self.cgImage!.height))
		let cropSize = refWidth > refHeight ? refHeight : refWidth
		
		let x = (refWidth - cropSize) / 2.0
		let y = (refHeight - cropSize) / 2.0
		
		let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
		let imageRef = self.cgImage?.cropping(to: cropRect)
		let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
		
		return cropped
	}
	
	func vignetteFilter() -> UIImage {
		let imageRef = self.cgImage
		let beginImage = CIImage(cgImage: imageRef!)
		
		let filter = CIFilter(name: "CIVignette")!
		filter.setValue(beginImage, forKey: kCIInputImageKey)
		filter.setValue(1, forKey: kCIInputIntensityKey)
		
		return UIImage(ciImage: filter.outputImage!)
	}
	
	func imageWithInsets(insetDimen: CGFloat) -> UIImage {
		return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
	}
	
	func imageWithInset(insets: UIEdgeInsets) -> UIImage {
	  UIGraphicsBeginImageContextWithOptions(
		CGSize(width: self.size.width + insets.left + insets.right,
			   height: self.size.height + insets.top + insets.bottom), false, self.scale)
		let origin = CGPoint(x: insets.left, y: insets.top)
		self.draw(at: origin)
		let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return imageWithInsets!
	}
}
