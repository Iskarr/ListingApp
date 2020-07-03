//
//  RegisterViewController.swift
//  ListingApp
//
//  Created by Austin Donovan on 6/5/20.
//  Copyright © 2020 Austin Donovan. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    // Navigate to chatview controller.
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
            
        }
        
    }
}
