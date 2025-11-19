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

    var grandTotal: Double {
        aggregates.reduce(0) { result, next in result + next.total }
    }

    var body: some View {
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
                            if agg.total > 0 { SectorMark(
                                angle: .value("Amount", agg.total),
                                innerRadius: .ratio(0.5),
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
                                    Rectangle()
                                        .frame(width: 6, height: 1)
                                        .hidden()
                                    Text(String(format: "%.2f%%", agg.total * 100 / grandTotal))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
}
