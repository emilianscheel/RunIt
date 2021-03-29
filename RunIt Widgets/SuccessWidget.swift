/**
*
*  SuccessWidget.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import WidgetKit
import SwiftUI
import CoreData










struct SuccessWidgetProvider: TimelineProvider {
	
	func placeholder(in context: Context) -> SuccessWidgetEntry {
		SuccessWidgetEntry(date: Date())
	}

	func getSnapshot(in context: Context, completion: @escaping (SuccessWidgetEntry) -> Void) {
		let entry = SuccessWidgetEntry(date: Date())
		completion(entry)
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<SuccessWidgetEntry>) -> Void) {
		var entries: [SuccessWidgetEntry] = []

		let entry = SuccessWidgetEntry(date: Date())
		entries.append(entry)

		let timeline = Timeline(entries: entries, policy: .atEnd)
		completion(timeline)
	}
}






struct SuccessWidgetEntry: TimelineEntry {
	let date: Date
}



struct SuccessWidgetEntryView: View {
	
	var entry: SuccessWidgetEntry
	@Environment(\.widgetFamily) var family
	
	var body: some View {

		VStack(alignment: .leading) {
			
			HStack(alignment: .top) {
				Text("Erfolge")
					.foregroundColor(Color(UIColor.label))
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 5)
					.font(.caption)
				
				if family == .systemMedium || family == .systemLarge {
					Button("Zur App gehen") {
						WidgetCenter.shared.reloadAllTimelines()
					}
					.font(.caption)
					.foregroundColor(Color(UIColor.systemBlue))
				}
			}
			
			HStack(alignment: .top) {
				
				let value = FormatDisplay.duration.from(SuccessStack.totalDuration)
				GridSectionView(title: "Gesamtzeit", value: value, family: family, chartviewDuration: ChartViewDuration())
				
				if family != .systemSmall {
					
					let value = FormatDisplay.distance.from(SuccessStack.totalDistance)
					GridSectionView(title: "Gesamtdistanz", value: value, family: family, chartviewDistance: ChartViewDistance())
				}
			}
			
			HStack(alignment: .top) {
				
				VStack {
					
					let value = SuccessStack.averagePace.cropTo(sequences: 2)
					GridSectionView(title: "⌀ Pace min/km", value: value, family: family)
					
					if family != .systemSmall && family != .systemMedium {
						
						let value = FormatDisplay.duration.from(SuccessStack.averageDuration)
						GridSectionView(title: "⌀ Zeit", value: value, family: family)
							//.frame(maxHeight: 60)
					}
				}
				
				if family != .systemSmall {
					
					VStack {
						
						let value = FormatDisplay.distance.from(SuccessStack.averageDistance)
						GridSectionView(title: "⌀ Distanz", value: value, family: family)
							//.frame(maxHeight: 60)
						
						if family != .systemSmall && family != .systemMedium {
							
							let value = FormatDisplay.steps.from(SuccessStack.averageSteps)
							GridSectionView(title: "⌀ Schritte", value: value, family: family)
						}
					}
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.cornerRadius(10.0)
		.padding(10)
	}
}












struct SuccessWidget: Widget {
	let kind: String = "SuccessWidget"
	
	var body: some WidgetConfiguration {
		
		StaticConfiguration(kind: kind, provider: SuccessWidgetProvider()) { entry in
			SuccessWidgetEntryView(entry: entry)
				.background(Color.init(UIColor.systemBackground))
		}
		.configurationDisplayName("Erfolge")
		.description("Zeigt dir Statistiken zu deinen Läufen direkt auf dem Home-Screen. Sodass du sie immer im Blick hast.")
	}
}




struct SuccessWidgetPreview: PreviewProvider {
	static var previews: some View {
		
		SuccessWidgetEntryView(entry: SuccessWidgetEntry(date: Date()))
			.previewContext(WidgetPreviewContext(family: .systemLarge))
	}
}

