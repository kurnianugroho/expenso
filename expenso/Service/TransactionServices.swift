//
//  TransactionServices.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseFirestore
import Foundation

class TransactionServices {
    var userId: String
    private let db = Firestore.firestore()

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Helpers

    private func userTransactionsCollection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("transactions")
    }

    // MARK: - Create / Update

    func addTransaction(_ tx: TransactionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        var newTx = tx
        newTx.createdAt = Date()
        newTx.updatedAt = Date()
        let data = newTx.toDictionary()
        userTransactionsCollection(userId: userId).document(newTx.id).setData(data) { error in
            if let e = error { completion(.failure(e)) } else { completion(.success(())) }
        }
    }

    func updateTransaction(_ tx: TransactionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        var updated = tx
        updated.updatedAt = Date()
        let data = updated.toDictionary()
        userTransactionsCollection(userId: userId).document(tx.id).updateData(data) { error in
            if let e = error { completion(.failure(e)) } else { completion(.success(())) }
        }
    }

    // MARK: - Delete

    func deleteTransaction(_ txId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        userTransactionsCollection(userId: userId).document(txId).delete { error in
            if let e = error { completion(.failure(e)) } else { completion(.success(())) }
        }
    }

    // MARK: - Real-time listener

    // Returns ListenerRegistration so caller can remove listener on deinit
    func listenTransactions(onChange: @escaping (Result<[TransactionModel], Error>) -> Void) -> ListenerRegistration? {
        let listener = userTransactionsCollection(userId: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let e = error {
                    onChange(.failure(e)); return
                }
                let txs = snapshot?.documents.compactMap { TransactionModel.from(document: $0) } ?? []
                onChange(.success(txs))
            }
        return listener
    }

    // MARK: - Query by month (example)

    func fetchTransactions(year: Int, month: Int, completion: @escaping (Result<[TransactionModel], Error>) -> Void) {
        let calendar = Calendar.current
        var comps = DateComponents(); comps.year = year; comps.month = month; comps.day = 1
        guard let start = calendar.date(from: comps) else { completion(.success([])); return }
        var add = DateComponents(); add.month = 1
        let end = calendar.date(byAdding: add, to: start)!

        let col = userTransactionsCollection(userId: userId)
        col.whereField("date", isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField("date", isLessThan: Timestamp(date: end))
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let e = error { completion(.failure(e)); return }
                let txs = snapshot?.documents.compactMap { TransactionModel.from(document: $0) } ?? []
                completion(.success(txs))
            }
    }
}
