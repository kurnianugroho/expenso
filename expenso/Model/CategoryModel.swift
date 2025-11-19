//
//  CategoryModel.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 18/11/25.
//

import Foundation
import UIKit

struct CategoryModel {
    var name: String
    var color: UIColor
}

var categoryList: [CategoryModel] = [
    CategoryModel(name: "Food", color: .systemBlue),
    CategoryModel(name: "Transportation", color: .systemRed),
    CategoryModel(name: "Utilities", color: .systemGreen),
    CategoryModel(name: "Entertainment", color: .systemOrange),
    CategoryModel(name: "Savings", color: .systemPurple),
]
