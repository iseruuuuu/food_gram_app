//
//  HomeWidgetSampleBundle.swift
//  HomeWidgetSample
//

import WidgetKit
import SwiftUI

@main
struct HomeWidgetSampleBundle: WidgetBundle {
    var body: some Widget {
        //シンプルなWidgetだけを表示できればいいため
        HomeWidgetSample()
//        HomeWidgetSampleControl()
//        HomeWidgetSampleLiveActivity()
    }
}
