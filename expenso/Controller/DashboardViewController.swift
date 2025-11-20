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
    var startDate: Date?

    private var hostingController: UIHostingController<DashboardChartView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the aggregate list
        var aggregates: [CategoryAggregateModel] = []
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

        // Initialize weekly expenses
        var weekly: [WeeklyExpenseModel] = []
        let weeksInMonth = weeksInMonth(of: startDate ?? Date())
        for dates in weeksInMonth {
            weekly.append(WeeklyExpenseModel(startDate: dates.start, endDate: dates.end, total: 0.0))
        }
        // Populate the weekly expenses
        transactionList?.forEach { tx in
            if let index = weeksInMonth.firstIndex(where: { week in
                tx.date >= week.start && tx.date <= week.end
            }) {
                weekly[index].total += tx.amount
            }
        }

        // Embedding SwiftUI Chart into UIKit
        let swiftUIView = DashboardChartView(aggregates: aggregates, weekly: weekly, startDate: startDate ?? Date())
        let host = UIHostingController(rootView: swiftUIView)
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
        hostingController = host
    }

    private func weeksInMonth(of date: Date) -> [(start: Date, end: Date)] {
        let calendar = Calendar.current

        // Start of month
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }

        var weeks: [(Date, Date)] = []

        var weekStart = monthInterval.start

        while weekStart < monthInterval.end {
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else { break }

            // Determine start & end of week considering start & end of month
            let start = max(weekInterval.start, monthInterval.start)
            let end = min(weekInterval.end, monthInterval.end)

            weeks.append((start, end))

            // Move to next week
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else { break }
            weekStart = nextWeek
        }

        return weeks
    }

    @IBAction func onExportTap(_: UIBarButtonItem) {
        savePDFToStorage()
    }

    private func exportViewToPDF() -> Data? {
        guard let host = hostingController else { return nil }
        let hostView = host.view!

        // Calculate the full content size (critical!)
        let targetSize = host.sizeThatFits(in: CGSize(
            width: hostView.bounds.width,
            height: .greatestFiniteMagnitude
        ))

        hostView.bounds = CGRect(origin: .zero, size: targetSize)
        hostView.layoutIfNeeded()

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: targetSize))

        let pdfData = renderer.pdfData { context in
            context.beginPage()
            hostView.layer.render(in: context.cgContext)
        }

        return pdfData
    }

    private func savePDFToStorage() {
        if let data = exportViewToPDF() {
            let url = FileManager.default
                .temporaryDirectory
                .appendingPathComponent("Charts.pdf")

            try? data.write(to: url)
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityVC, animated: true)
        }
    }
}
