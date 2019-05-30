//
//  CalendarState.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public enum CalendarSection: Int {
    case days, months, years
}

final class CalendarState {
    // Выбранная дана
    var selectedDate: Date?
    // Дата для отображения месяца
    var currentDate: Date?
    // Минимальная дата, которую можно выбрать
    var minimumDate: Date?
    // Выбранная секция (Выбор дня, выбор месяца, выбор года)
    var section: CalendarSection = .days
}
