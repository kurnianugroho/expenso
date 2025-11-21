//
//  MonthlyExpenseModel.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 20/11/25.
//

import Foundation

struct MonthlyExpenseModel: Identifiable {
    let id = UUID()
    let index: Int
    let date: Date
    var total: Double
}
