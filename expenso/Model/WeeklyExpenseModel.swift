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
