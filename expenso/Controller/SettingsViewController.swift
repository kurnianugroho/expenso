//
//  SettingsViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 22/11/25.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var brandLabel: UIStackView!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: brandLabel.topAnchor),
        ])
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source

    func numberOfSections(in _: UITableView) -> Int {
        settingsSectionList.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        settingsSectionList[section].title
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsSectionList[section].items.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        cell.textLabel?.text = settingsSectionList[indexPath.section].items[indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if settingsSectionList[indexPath.section].items[indexPath.row] == "Sign Out" {
            let result = AuthServices().signOut()
            switch result {
            case .success:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")

                // Replace the root VC
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window
                {
                    window.rootViewController = loginVC
                    window.makeKeyAndVisible()

                    UIView.transition(
                        with: window,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: nil,
                        completion: nil,
                    )
                }
            case let .failure(error):
                showToast(message: error.localizedDescription, backgroundColor: .red)
            }
        }
    }
}
