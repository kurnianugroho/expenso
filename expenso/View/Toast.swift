//
//  Toast.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import UIKit

extension UIViewController {
    func showToast(message: String, duration: Double = 2.0, backgroundColor: UIColor = .black) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = backgroundColor.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.alpha = 0
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true

        let padding: CGFloat = 16
        let maxWidth = view.frame.width - padding * 2
        let textSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))

        toastLabel.frame = CGRect(
            x: padding,
            y: view.frame.height - textSize.height - 120,
            width: maxWidth,
            height: textSize.height + 16
        )

        view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
