//
//  DashboardViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 18/11/25.
//

import SwiftUI
import UIKit

class DashboardViewController: UIViewController {
    var transactionList: [TransactionModel]?

    private var hostingController: UIHostingController<DashboardChartView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation bar title's font
        if let savoyeFont = UIFont(name: "SavoyeLetPlain", size: 36) {
            navigationController?.navigationBar.titleTextAttributes = [
                .font: savoyeFont,
                .foregroundColor: UIColor.label,
            ]
        }

        // Calculate category aggregates
        var aggregates: [CategoryAggregateModel] = []
        // Initialize the aggregate list
        for category in categoryList {
            aggregates.append(CategoryAggregateModel(category: category, total: 0.0))
        }
        // Populate the aggregate list
        transactionList?.forEach { tx in
            if let index = categoryList.firstIndex(where: { category in
                category.name == tx.category
            }) {
                aggregates[index].total += tx.amount
            }
        }

        // Embedding SwiftUI Chart into UIKit
        let swiftUIView = DashboardChartView(aggregates: aggregates)
        let host = UIHostingController(rootView: swiftUIView)
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        host.didMove(toParent: self)
        hostingController = host
    }
}
