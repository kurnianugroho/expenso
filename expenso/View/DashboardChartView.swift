//
//  DashboardChartView.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 18/11/25.
//

import Charts
import SwiftUI

struct DashboardChartView: View {
    var aggregates: [CategoryAggregateModel]
    var weekly: [WeeklyExpenseModel]
    var startDate: Date

    var grandTotal: Double {
        aggregates.reduce(0) { result, next in result + next.total }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("In \(startDate.formattedMonthYear()), you spent \(grandTotal.asRupiah())")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                DotDivider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Spending by Category")
                        .font(.callout)

                    HStack(spacing: 24) {
                        Chart {
                            ForEach(aggregates) { agg in
                                if agg.total > 0 {
                                    SectorMark(
                                        angle: .value("Amount", agg.total),
                                        innerRadius: .ratio(0.5)
                                    )
                                    .foregroundStyle(Color(uiColor: agg.category.color))
                                }
                            }
                        }
                        .chartLegend(position: .bottom, alignment: .center)
                        .frame(width: 180, height: 180)

                        VStack(alignment: .leading) {
                            ForEach(aggregates) { agg in
                                if agg.total > 0 {
                                    HStack {
                                        Rectangle()
                                            .fill(Color(uiColor: agg.category.color))
                                            .frame(width: 14, height: 14)

                                        Text(agg.category.name)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)

                                        Spacer()

                                        Text(String(format: "%.2f%%",
                                                    agg.total * 100 / grandTotal))
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                DotDivider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Spending by Weeks")
                        .font(.callout)

                    Chart {
                        ForEach(weekly) { week in
                            BarMark(
                                x: .value("Week", "\(week.startDate.formattedMonth())\n\(week.startDate.formattedDay())-\(week.endDate.formattedDay())"),
                                y: .value("Total", week.total)
                            )
                            .foregroundStyle(Color("TextHighlight"))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let number = value.as(Double.self) {
                                    Text(number.formatted(.number.notation(.compactName)))
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let text = value.as(String.self) {
                                    Text(text)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    .frame(height: 180)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DotDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                p.move(to: .zero)
                p.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(
                Color.gray.opacity(0.5),
                style: StrokeStyle(lineWidth: 1, dash: [4, 4], dashPhase: 0)
            )
        }
        .frame(height: 1)
        .padding(.vertical, 1)
    }
}
