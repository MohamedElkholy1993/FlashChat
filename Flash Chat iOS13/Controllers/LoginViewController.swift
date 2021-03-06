//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let self = self else { return }
              if error != nil{
                  let alertController = UIAlertController(title: "Warning", message: error?.localizedDescription, preferredStyle: .alert)
                  let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                  alertController.addAction(cancel)
                  self.present(alertController, animated: true, completion: nil)
              }else{
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
              }
            }
        }
        
    }
    
}
