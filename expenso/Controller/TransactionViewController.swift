//
//  TransactionViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseFirestore
import UIKit
import Foundation

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
    
    //MARK: - UIViewController functions
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthYearTextField: UITextField!
    @IBOutlet weak var totalSpentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Set navigation bar title's font
        if let savoyeFont = UIFont(name: "SavoyeLetPlain", size: 36) {
            navigationController?.navigationBar.titleTextAttributes = [
                .font: savoyeFont,
                .foregroundColor: UIColor.label,
            ]
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        getTransactions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeListener()
    }
    
    private func getTransactions() {
        if let txServices = txServices {
            listener = txServices.listenTransactions(
                startDate: startDate!,
                endDate: endDate!,
            ) { result in
                switch result {
                case let .success(txs):
                    self.transactions = txs
                    self.totalSpentLabel.text = (txs.map {e in return e.amount}).reduce(0, +).asRupiah()
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
    
    //MARK: - Navigation Bar
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
    
    //MARK: - Picker View
    let picker = UIPickerView()
    let months = Calendar.current.monthSymbols
    let years = Array(2024...2035)
    
    func setupMonthYearPicker() {
        monthYearTextField.inputView = picker
        monthYearTextField.tintColor = .clear
        picker.delegate = self
        picker.dataSource = self

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
        tap.cancelsTouchesInView = false  // important
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? months.count : years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? months[row] : "\(years[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
}
