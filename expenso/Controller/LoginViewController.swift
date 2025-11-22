//
//  LoginViewController.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseAuth
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    // MARK: - Text Field Delegate

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            performLogin()
            textField.resignFirstResponder()
        }

        return true
    }

    // MARK: - Button Callbacks

    @IBAction func onSignupTap(_: Any) {
        let isDataMissing = emailTextField.text == nil ||
            emailTextField.text!.isEmpty ||
            passwordTextField.text == nil ||
            passwordTextField.text!.isEmpty

        if isDataMissing {
            showToast(
                message: "Please input email and password",
                backgroundColor: .red
            )
        } else {
            AuthServices().signUp(
                email: emailTextField.text!,
                password: passwordTextField.text!,
            ) { result in
                self.handleSignResult(result)
            }
        }
    }

    @IBAction func onLoginTap(_: UIButton) {
        performLogin()
    }

    func performLogin() {
        let isDataMissing = emailTextField.text == nil ||
            emailTextField.text!.isEmpty ||
            passwordTextField.text == nil ||
            passwordTextField.text!.isEmpty

        if isDataMissing {
            showToast(
                message: "Please input email and password",
                backgroundColor: .red
            )
        } else {
            AuthServices().signIn(
                email: emailTextField.text!,
                password: passwordTextField.text!,
            ) { result in
                self.handleSignResult(result)
            }
        }
    }

    fileprivate func handleSignResult(_ result: Result<User, any Error>) {
        switch result {
        case let .success(user):
            switchToHomeScreen(userId: user.uid)
        case let .failure(error):
            let err = error as NSError

            if let code = AuthErrorCode(rawValue: err.code) {
                switch code {
                case .invalidEmail:
                    print("Invalid email format")
                case .userNotFound:
                    print("User not found")
                case .wrongPassword:
                    print("Wrong password")
                case .userDisabled:
                    print("User disabled")
                case .tooManyRequests:
                    print("Too many requests — try again later")
                case .networkError:
                    print("Network error — check your connection")
                default:
                    print("Auth error: \(error.localizedDescription) (\(code))")
                }
            } else {
                // Not a Firebase Auth error code we recognize
                print("Unknown error: \(error.localizedDescription) (code: \(err.code))")
            }

            showToast(
                message: "Sign up error: \(error.localizedDescription)",
                backgroundColor: .red
            )
        }
    }

    func switchToHomeScreen(userId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else { return }

        // Optionally choose default selected tab
        tabBar.selectedIndex = 0 // 0 = Expenses, 1 = Settings

        if let navs = tabBar.viewControllers as? [UINavigationController] {
            if let expensesNav = navs.first,
               let expensesVC = expensesNav.viewControllers.first as? TransactionViewController
            {
                expensesVC.userId = userId
            }
        }

        // Replace window rootViewController
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate,
           let window = sceneDelegate.window
        {
            window.rootViewController = tabBar
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } else {
            // Fallback: present full screen
            tabBar.modalPresentationStyle = .fullScreen
            present(tabBar, animated: true)
        }
    }
}
