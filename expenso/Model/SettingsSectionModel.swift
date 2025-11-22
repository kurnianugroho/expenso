//
//  SettingsSectionModel.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 22/11/25.
//

import Foundation

struct SettingsSectionModel {
    let title: String
    let items: [String]
}

var settingsSectionList: [SettingsSectionModel] = [
    SettingsSectionModel(title: "Session", items: ["Sign Out"]),
]
