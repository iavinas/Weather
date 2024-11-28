//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Avinash Kumar on 28/11/24.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        WeatherWidgetControl()
        WeatherWidgetLiveActivity()
    }
}
