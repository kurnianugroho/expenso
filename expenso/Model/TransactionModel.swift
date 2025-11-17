//
//  TransactionModel.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

struct TransactionModel {
    var id: String
    var amount: Double
    var category: String
    var date: Date
    var note: String?
    var createdAt: Date
    var updatedAt: Date

    var userId: String?

    init(id: String = UUID().uuidString,
         amount: Double,
         category: String,
         date: Date = Date(),
         note: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         userId: String? = nil)
    {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
    }

    // convert to Firestore dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "amount": amount,
            "category": category,
            "date": Timestamp(date: date),
            "note": note ?? "",
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
        ]
    }

    // build model from Firestore document
    static func from(document: DocumentSnapshot) -> TransactionModel? {
        guard let data = document.data() else { return nil }
        guard
            let id = data["id"] as? String,
            let amount = data["amount"] as? Double,
            let category = data["category"] as? String,
            let dateTS = data["date"] as? Timestamp,
            let createdTS = data["createdAt"] as? Timestamp,
            let updatedTS = data["updatedAt"] as? Timestamp
        else { return nil }

        let note = (data["note"] as? String)?.isEmpty == true ? nil : (data["note"] as? String)

        var tx = TransactionModel(
            id: id,
            amount: amount,
            category: category,
            date: dateTS.dateValue(),
            note: note,
            createdAt: createdTS.dateValue(),
            updatedAt: updatedTS.dateValue()
        )
        tx.userId = document.reference.parent.parent?.documentID
        return tx
    }
}
