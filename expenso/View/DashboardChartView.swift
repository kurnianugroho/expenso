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

    var grandTotal: Double {
        aggregates.reduce(0) { result, next in result + next.total }
    }

    var body: some View {
            ScrollView {
                VStack(spacing: 12) {

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.teal)

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

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Spending by Weeks")
                            .font(.callout)

                        Chart {
                            ForEach(weekly) { week in
                                BarMark(
                                    x: .value("Week", "\(week.startDate.formattedMonth())\n\(week.startDate.formattedDay())-\(week.endDate.formattedDay())"),
                                    y: .value("Total", week.total)
                                )
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

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

