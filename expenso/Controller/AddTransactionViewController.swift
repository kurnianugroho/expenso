//
//  AddTransactionViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import UIKit

class AddTransactionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var notesTextField: UITextField!
    @IBOutlet var timestampPicker: UIDatePicker!

    var onAddTransaction: ((TransactionModel) -> Void)?

    var categories: [String] = [
        "Food",
        "Transportation",
        "Utilities",
        "Entertainment",
        "Savings",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        amountTextField.delegate = self

        // Do any additional setup after loading the view.
        categoryButton.menu = UIMenu(
            children: categories.map { category in
                UIAction(title: category) { action in
                    self.categoryButton.setTitle(action.title, for: .normal)
                }
            },
        )
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == amountTextField else { return true }

        let nsString = (textField.text ?? "") as NSString
        let digitsOnly = nsString.replacingCharacters(in: range, with: string).digitsOnly()

        // Convert to number
        if let amount = Double(digitsOnly) {
            textField.text = amount.asRupiah()
        } else {
            textField.text = nil
        }

        // Returning false because we manually set text
        return false
    }

    @IBAction func onSubmitTap(_: Any) {
        var isDataMissing = amountTextField.text?.isEmpty ?? true
        var amount: Double = 0

        if !isDataMissing {
            if let amt = Double(amountTextField!.text!.digitsOnly()) {
                amount = amt
            } else {
                isDataMissing = true
            }
        }

        if isDataMissing {
            showToast(
                message: "Amount cannot be empty",
                backgroundColor: .red,
            )
        } else {
            let newTx = TransactionModel(
                amount: amount,
                category: categoryButton.currentTitle!,
                date: timestampPicker.date,
                note: notesTextField.text ?? "",
            )

            onAddTransaction?(newTx)
            dismiss(animated: true)
        }
    }
}
