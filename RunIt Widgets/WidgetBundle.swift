/**
*
*  WidgetBundle.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import SwiftUI
import WidgetKit








@main
struct WidgetExamplesWidgetBundle: WidgetBundle {
	var body: some Widget {
		
		// Füge das „Letzte Läufe“-Widget zu den Widgets hinzu
		PastRunWidget()
		
		// Füge das „Erfolge“-Widget zu den Widgets hinzu
		SuccessWidget()
		
		// Füge das „Vergleichs“-Widget zu den Widgets hinzu
		CompareWidget()
	}
}
