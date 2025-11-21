//
//  WeeklyExpenseModel.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 19/11/25.
//

import Foundation

struct WeeklyExpenseModel: Identifiable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    var total: Double
}

extension WeeklyExpenseModel {
    var weekLabel: String {
        let calendar = Calendar.current

        let start = "\(startDate.formattedMonth())\n\(startDate.formattedDay())"
        let end = calendar.component(.day, from: startDate) == calendar.component(.day, from: endDate)
            ? ""
            : "-\(endDate.formattedDay())"
        return start + end
    }
}
