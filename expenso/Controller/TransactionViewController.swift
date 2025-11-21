//
//  TransactionViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseFirestore
import Foundation
import UIKit

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    var txServices: TransactionServices?
    var userId: String? {
        didSet {
            guard let userId = userId else { return }
            txServices = TransactionServices(userId: userId)
        }
    }

    private var startDate: Date?
    private var endDate: Date?
    private var listener: ListenerRegistration?
    private var transactions: [TransactionModel]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private var lastMonthTotal: Double?
    private var oneBeforeLastMonthTotal: Double?

    // MARK: - UIViewController functions

    @IBOutlet var tableView: UITableView!
    @IBOutlet var monthYearTextField: UITextField!
    @IBOutlet var totalSpentLabel: UILabel!
    @IBOutlet var showDashboardButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Initialize start & end date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        startDate = DateComponents(
            calendar: calendar,
            year: dateComponents.year,
            month: dateComponents.month,
            day: 1,
        ).date
        endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate!)

        // Setup period picker
        setupMonthYearPicker()
    }

    override func viewWillAppear(_: Bool) {
        getTransactions()
    }

    override func viewWillDisappear(_: Bool) {
        disposeListener()
    }

    // MARK: - Transaction Services

    private func getTransactions() {
        if let txServices = txServices {
            listener = txServices.listenTransactions(
                startDate: startDate!,
                endDate: endDate!,
            ) { result in
                switch result {
                case let .success(txs):
                    self.transactions = txs

                    let totalSpent = (txs.map { e in e.amount }).reduce(0, +)
                    self.totalSpentLabel.text = totalSpent.asRupiah()
                    self.showDashboardButton.isEnabled = totalSpent > 0

                case let .failure(error):
                    self.showToast(message: error.localizedDescription)
                }
            }
        }
    }

    private func disposeListener() {
        listener?.remove()
        listener = nil
    }

    private func getTotalExpenses(monthsAgo diff: Int) async -> Double {
        var lastMonthTotal: Double = 0

        var month = startDate!.getXMonthAgo(x: diff).getMonth()
        if month <= 0 {
            month += 12
        }
        let year = startDate!.getXYearAgo(x: month > startDate!.getMonth() ? 1 : 0).getYear()

        do {
            if let txServices = txServices {
                lastMonthTotal = try await txServices.fetchTransactions(
                    year: year,
                    month: month
                ).map { tx in tx.amount }.reduce(0, +)
            }
        } catch {
            showToast(message: error.localizedDescription)
        }

        return lastMonthTotal
    }

    // MARK: - Table View

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return transactions?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell

        cell.categoryLabel.text = transactions?[indexPath.row].category
        cell.amountLabel.text = transactions?[indexPath.row].amount.asRupiah()
        cell.notesLabel.text = transactions?[indexPath.row].note
        cell.timeStampLabel.text = transactions?[indexPath.row].date.formattedShort()

        return cell
    }

    // MARK: - Navigation Bar

    @IBAction func onAddButtonTap(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addTransactionVC = storyboard.instantiateViewController(withIdentifier: "AddTransactionVC") as? AddTransactionViewController else { return }

        addTransactionVC.modalPresentationStyle = .pageSheet
        if let sheet = addTransactionVC.sheetPresentationController {
            sheet.detents = [
                UISheetPresentationController.Detent.custom { context in
                    context.maximumDetentValue * 0.65
                },
            ]
            sheet.prefersGrabberVisible = true
        }

        addTransactionVC.onAddTransaction = { tx in
            var modifiedTx = tx
            modifiedTx.userId = self.userId
            self.txServices?.addTransaction(modifiedTx) { result in
                if case let .failure(error) = result {
                    self.showToast(
                        message: error.localizedDescription,
                        backgroundColor: .red,
                    )
                }
            }
        }

        present(addTransactionVC, animated: true)
    }

    // MARK: - Picker View

    let picker = UIPickerView()
    let months = Calendar.current.monthSymbols
    let years = Array(2024 ... 2035)

    func setupMonthYearPicker() {
        monthYearTextField.inputView = picker
        monthYearTextField.tintColor = .clear
        picker.delegate = self
        picker.dataSource = self

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        let icon = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        icon.tintColor = .label
        icon.contentMode = .left
        icon.frame = container.bounds
        container.addSubview(icon)

        monthYearTextField.rightView = container
        monthYearTextField.rightViewMode = .always

        // Preselect picker month/year
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let m = dateComponents.month ?? 1
        let y = dateComponents.year ?? years.first!

        picker.selectRow(m - 1, inComponent: 0, animated: false)

        if let yearIndex = years.firstIndex(of: y) {
            picker.selectRow(yearIndex, inComponent: 1, animated: false)
        }

        monthYearTextField.text = "\(months[m - 1]) \(y)"

        // Tap outside to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tap.cancelsTouchesInView = false // important
        view.addGestureRecognizer(tap)
    }

    @objc func dismissPicker() {
        view.endEditing(true)
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? months.count : years.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? months[row] : "\(years[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
        let monthIndex = pickerView.selectedRow(inComponent: 0)
        let yearIndex = pickerView.selectedRow(inComponent: 1)

        let selectedMonth = months[monthIndex]
        let selectedYear = years[yearIndex]

        monthYearTextField.text = "\(selectedMonth) \(selectedYear)"

        // Set new start & end date
        startDate = DateComponents(
            calendar: Calendar.current,
            year: selectedYear,
            month: monthIndex + 1,
            day: 1,
        ).date
        endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate!)

        // Refresh table view data source
        disposeListener()
        getTransactions()
    }

    // MARK: - Go To Dashboard

    @IBAction func onShowDashboardTap(_: UIButton) {
        Task {
            lastMonthTotal = await getTotalExpenses(monthsAgo: 1)
            oneBeforeLastMonthTotal = await getTotalExpenses(monthsAgo: 2)
            performSegue(withIdentifier: "goToDashboard", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "goToDashboard" {
            let destinationVC = segue.destination as! DashboardViewController
            destinationVC.transactionList = transactions
            destinationVC.startDate = startDate
            destinationVC.lastMonthTotal = lastMonthTotal
            destinationVC.oneBeforeLastMonthTotal = oneBeforeLastMonthTotal
        }
    }
}
