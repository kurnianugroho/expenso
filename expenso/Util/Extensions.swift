//
//  Extensions.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import Foundation
import UIKit

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

extension UITextField {
    func addDoneButton() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))

        toolbar.setItems([flexible, done], animated: false)
        self.inputAccessoryView = toolbar
    }

    @objc private func donePressed() {
        self.resignFirstResponder()
    }
}

