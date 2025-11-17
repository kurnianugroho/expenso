//
//  Extensions.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import Foundation

extension Double {
    func asRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Date {
    func formattedShort() -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: self)
    }
}

extension String {
    func digitsOnly() -> String {
        return filter { ("0" ... "9").contains($0) }
    }
}
