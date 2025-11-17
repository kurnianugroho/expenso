//
//  TransactionTableViewCell.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var timeStampLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
