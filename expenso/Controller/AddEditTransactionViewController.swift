//
//  AddEditTransactionViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import UIKit

class AddEditTransactionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var notesTextField: UITextField!
    @IBOutlet var timestampPicker: UIDatePicker!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    var onAddTransaction: ((TransactionModel) -> Void)?
    var onEditTransaction: ((TransactionModel) -> Void)?
    var initialTransaction: TransactionModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        amountTextField.delegate = self
        amountTextField.addDoneButton()
        notesTextField.delegate = self

        // Do any additional setup after loading the view.
        categoryButton.menu = UIMenu(
            children: categoryList.map { category in
                UIAction(title: category.name) { action in
                    self.categoryButton.setTitle(action.title, for: .normal)
                }
            },
        )

        // Fill form with data for edit mode
        if let initialTransaction = initialTransaction {
            let categoryIndex = categoryList.firstIndex(where: { cat in cat.name == initialTransaction.category })
            if categoryIndex != nil {
                (categoryButton.menu?.children[categoryIndex!] as? UIAction)?.state = .on
                categoryButton.setTitle(initialTransaction.category, for: .normal)
            }
            amountTextField.text = initialTransaction.amount.asRupiah()
            notesTextField.text = initialTransaction.note
            timestampPicker.date = initialTransaction.date
            titleLabel.text = "Edit Expense"
            actionButton.setTitle("Save", for: .normal)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Show/hide back button based on device orientation
        let isPortrait = view.bounds.height > view.bounds.width
        backButton.isHidden = isPortrait
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
                id: initialTransaction?.id ?? UUID().uuidString,
                amount: amount,
                category: categoryButton.currentTitle!,
                date: timestampPicker.date,
                note: notesTextField.text ?? "",
                userId: initialTransaction?.userId,
            )

            if initialTransaction == nil {
                onAddTransaction?(newTx)
            } else {
                onEditTransaction?(newTx)
            }

            dismiss(animated: true)
        }
    }

    @IBAction func onBackTap(_: Any) {
        dismiss(animated: true)
    }
}
