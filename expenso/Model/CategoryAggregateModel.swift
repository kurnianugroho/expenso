//
//  CategoryAggregateModel.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 18/11/25.
//

import Foundation

struct CategoryAggregateModel: Identifiable {
    let id = UUID()
    let category: CategoryModel
    var total: Double
}
