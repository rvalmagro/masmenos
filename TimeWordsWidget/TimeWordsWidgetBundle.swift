//
//  TimeWordsWidgetBundle.swift
//  TimeWordsWidget
//
//  Created by Ricardo Vázquez on 16/6/25.
//

import WidgetKit
import SwiftUI
/*
@main
struct TimeWordsWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimeWordsWidget()
        TimeWordsWidgetControl()
        TimeWordsWidgetLiveActivity()
    }
}
*/
@main
struct TimeWordsWidgetBundle: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    TimeWordsWidget()
    // aquí podrías añadir también tu Live Activity si la tienes
  }
}
