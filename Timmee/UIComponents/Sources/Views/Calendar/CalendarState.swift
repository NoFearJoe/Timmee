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
    // Максимальная дата, которую можно выбрать
    var maximumDate: Date?
    
    init(currentDate: Date, minimumDate: Date, maximumDate: Date?, selectedDate: Date? = nil) {
        self.currentDate = currentDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
    }
}
