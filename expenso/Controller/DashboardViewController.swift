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
    var lastMonthTotal: Double?
    var oneBeforeLastMonthTotal: Double?

    private var hostingController: UIHostingController<DashboardChartView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let startDate = startDate,
              let lastMonthTotal = lastMonthTotal,
              let oneBeforeLastMonthTotal = oneBeforeLastMonthTotal
        else {
            return
        }

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
        let weeksInMonth = weeksInMonth(of: startDate)
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

        // Get transactions for last 3 months
        let trends: [MonthlyExpenseModel] = [
            MonthlyExpenseModel(index: 0, date: startDate.getXMonthAgo(x: 2), total: oneBeforeLastMonthTotal),
            MonthlyExpenseModel(index: 1, date: startDate.getXMonthAgo(x: 1), total: lastMonthTotal),
            MonthlyExpenseModel(index: 2, date: startDate, total: aggregates.map { agg in agg.total }.reduce(0, +)),
        ]

        // Embedding SwiftUI Chart into UIKit
        let swiftUIView = DashboardChartView(
            aggregates: aggregates,
            weekly: weekly,
            trends: trends,
            startDate: startDate,
            exportMode: false,
        )
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

        guard var weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            return []
        }

        var weeks: [(Date, Date)] = []

        while weekStart < monthInterval.end {
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else { break }

            // Determine start & end of week considering start & end of month
            let start = max(weekInterval.start, monthInterval.start)
            let end = min(weekInterval.end, monthInterval.end)

            weeks.append((start, end.addingTimeInterval(-1)))

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
        guard let startDate = startDate else { return nil }

        // Build a NON-scrollable version of the view
        let exportView = DashboardChartView(
            aggregates: hostingController?.rootView.aggregates ?? [],
            weekly: hostingController?.rootView.weekly ?? [],
            trends: hostingController?.rootView.trends ?? [],
            startDate: startDate,
            exportMode: true
        )

        let renderer = ImageRenderer(content: exportView)
        renderer.scale = UIScreen.main.scale

        var pdfData: Data?

        // renderer.render provides a (size, draw) pair we can use to create a PDF
        renderer.render { size, draw in
            // create PDF renderer with the SwiftUI-render size
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: size))

            pdfData = pdfRenderer.pdfData { ctx in
                ctx.beginPage()
                let cg = ctx.cgContext

                // Apply UIKit → CoreGraphics coordinate flip
                cg.translateBy(x: 0, y: size.height)
                cg.scaleBy(x: 1, y: -1)

                draw(cg)
            }
        }

        return pdfData
    }

    private func savePDFToStorage() {
        if let data = exportViewToPDF() {
            let url = FileManager.default
                .temporaryDirectory
                .appendingPathComponent("Expenso_\((startDate?.formattedMonthYear() ?? "").replacingOccurrences(of: " ", with: "_")).pdf")

            try? data.write(to: url)
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityVC, animated: true)
        }
    }
}
