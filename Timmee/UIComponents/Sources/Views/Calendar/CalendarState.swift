//
//  CalendarState.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

final class CalendarState {
    // Выбранная дана
    var selectedDate: Date?
    // Дата для отображения месяца
    var currentDate: Date
    // Минимальная дата, которую можно выбрать
    var minimumDate: Date
    
    init(currentDate: Date, minimumDate: Date, selectedDate: Date? = nil) {
        self.currentDate = currentDate
        self.minimumDate = minimumDate
        self.selectedDate = selectedDate
    }
}
