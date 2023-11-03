//
//  ViewController.swift
//  LoginApp
//
//  Created by Sviatoslav Samoilov on 18.07.2023.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var passwordImage: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccount: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    
    // MARK: - Properties
    var isLogin = true
    
    private let activeColor = UIColor(named: "MyColor") ?? UIColor.systemRed
    
    private let mockPassword = "6666"
    private let mockEmail = "god@gmail.com"
    
    private var email = ""
    private var password = ""
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateButtons()
        emailField.delegate = self
        passwordField.delegate = self
        emailField.becomeFirstResponder()
        
        dontHaveAccount.isHidden = !isLogin
        signupButton.isHidden = !isLogin
    }
    
    // MARK: - Actions
    @IBAction func loginAction(_ sender: UIButton) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        if isLogin {
            if KeychainManager.checkUser(with: email, password: password) {
                performSegue(withIdentifier: "goToHomePage", sender: sender)
                
                emailField.text = ""
                email = ""
                passwordField.text = ""
                password = ""
            } else if email == "" && password == "" {
                let alert = UIAlertController(title: "Enter email and password".localized,
                                              message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .destructive)
                alert.addAction(action)
                present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Wrong email or password".localized,
                                              message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .destructive)
                alert.addAction(action)
                present(alert, animated: true)
                
                emailField.text = ""
                passwordField.text = ""
            }
        } else {
            if KeychainManager.save(email: email, password: password) {
                performSegue(withIdentifier: "goToHomePage", sender: sender)
            } else {
                debugPrint("Error with saving email and password")
            }
        }
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        //        performSegue(withIdentifier: "goToSignup", sender: sender)
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
                as? ViewController else { return }
        viewController.isLogin = false
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: - Methods
    private func configurateButtons() {
        loginButton.layer.shadowColor = activeColor.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        loginButton.layer.shadowOpacity = 0.5
        loginButton.layer.shadowRadius = 5
        
        loginButton.setTitle(isLogin ? "Login".localized.uppercased() : "Register".localized.uppercased(), for: .normal)
    }
}


extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }

        switch textField {
        case emailField:
            let isValidEmail = check(email: text)
            
            if isValidEmail {
                email = text
                emailImage.tintColor = .systemGray5
                emailView.backgroundColor = .systemGray5
            } else {
                email = ""
                makeErrorField(textField: textField)
            }
        case passwordField:
            let isValidPassword = check(password: text)
            
            if isValidPassword {
                password = text
                passwordImage.tintColor = .systemGray5
                passwordView.backgroundColor = .systemGray5
            } else {
                password = ""
                makeErrorField(textField: textField)
            }
        default:
            return
        }
    }
    
    private func check(email: String) -> Bool {
        return (emailField.text ?? "").contains("@") && (emailField.text ?? "").contains(".")
    }
    
    private func check(password: String) -> Bool {
        return (passwordField.text ?? "").count >= 4
    }
    
    private func makeErrorField(textField: UITextField) {
        switch textField {
        case emailField:
            emailImage.tintColor = .systemRed
            emailView.backgroundColor = .systemRed
        case passwordField:
            passwordImage.tintColor = .systemRed
            passwordView.backgroundColor = .systemRed
        default:
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            if check(email: email) && check(password: password){
                loginAction(loginButton)
            } else if check(email: email) && !check(password: password) {
                passwordField.becomeFirstResponder()
            } else {
                makeErrorField(textField: emailField)
            }
        case passwordField:
            if check(password: password) && check(email: email) {
                loginAction(loginButton)
            } else if check(password: password) && !check(email: email) {
                emailField.becomeFirstResponder()
            } else {
                makeErrorField(textField: passwordField)
            }
        default:
            print("unknown text field")
        }
        return true
    }
}
