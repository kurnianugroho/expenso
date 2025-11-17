//
//  TransactionViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseFirestore
import UIKit

class TransactionViewController: UITableViewController {
    @IBAction func onAddButtonTap(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addTransactionVC = storyboard.instantiateViewController(withIdentifier: "AddTransactionVC") as? AddTransactionViewController else { return }

        addTransactionVC.modalPresentationStyle = .pageSheet
        if let sheet = addTransactionVC.sheetPresentationController {
            sheet.detents = [
                UISheetPresentationController.Detent.custom { context in
                    context.maximumDetentValue * 0.6
                },
                .large(),
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

    var txServices: TransactionServices?
    var userId: String? {
        didSet {
            guard let userId = userId else { return }
            txServices = TransactionServices(userId: userId)
        }
    }

    private var listener: ListenerRegistration?
    private var transactions: [TransactionModel]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savoyeFont = UIFont(name: "SavoyeLetPlain", size: 36) {
            navigationController?.navigationBar.titleTextAttributes = [
                .font: savoyeFont,
                .foregroundColor: UIColor.black,
            ]
        }

        if let txServices = txServices {
            listener = txServices.listenTransactions { result in
                switch result {
                case let .success(txs):
                    self.transactions = txs
                case let .failure(error):
                    self.showToast(message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return transactions?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell

        cell.categoryLabel.text = transactions?[indexPath.row].category
        cell.amountLabel.text = transactions?[indexPath.row].amount.asRupiah()
        cell.notesLabel.text = transactions?[indexPath.row].note
        cell.timeStampLabel.text = transactions?[indexPath.row].date.formattedShort()

        return cell
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             // Delete the row from the data source
             tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
             // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
