/**
*
*  CreateBanner.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import UIKit

















/*

	MARK: OBJECT CLASS

	-Objects
	-ObjectRowKind

	-ObjectRow
	-ObjectRowTitle
	-ObjectRowBadge
	-ObjectRowNote
	-ObjectRowDatas

*/

struct Object {
	var name : String!
	var objects : [ObjectRow]!
	var kind: ObjectRowKind!
	
	init(name: String, objects: [ObjectRow], _ kind: ObjectRowKind) {
		self.name = name
		self.objects = objects
		self.kind = kind
	}
}

enum ObjectRowKind {
	case title
	case badge
	case data
	case notes
	case chartMonth
	case chartDuration
	case chartDistance
}

class ObjectRow: Identifiable {  }

class ObjectRowTitle: ObjectRow {
	var distance: Double!
	var date: Date!
	
	init(distance: Double, date: Date) {
		self.distance = distance
		self.date = date
	}
}

class ObjectRowBadge: ObjectRow {
	var target: Target!
	var index: IndexPath!
	
	init(_ target: Target, indexPath: IndexPath) {
		self.target = target
		self.index = indexPath
	}
}

class ObjectRowNote: ObjectRow {
	var text: String!
	
	init(text: String) {
		self.text = text
	}
}

class ObjectRowData: ObjectRow {
	var name: String!
	var value: String!
	var icon: String!
	
	init(name: String, value: String, iconName: String = "") {
		self.name = name
		self.value = value
		self.icon = iconName
	}
}
