//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var messages: [Message] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        title = K.appName
        navigationItem.hidesBackButton = true
        loadMessages()
    }
    
    func loadMessages(){
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            self.messages = []
            if error != nil{
                print("there was an issue retrieving data form firestore:\(error!)")
            }else{
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        if let sender = doc[K.FStore.senderField] as? String, let body = doc[K.FStore.bodyField] as? String{
                            let newMessage = Message(sender: sender, body: body)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexpath = IndexPath(row: self.messages.count-1, section: 0)
                                self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
    }
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageSender = Auth.auth().currentUser?.email, let messageBody = messageTextfield.text{
            let messgaeDate = Date().timeIntervalSince1970
            db.collection(K.FStore.collectionName).addDocument(
                data: [K.FStore.senderField: messageSender,
                       K.FStore.bodyField: messageBody,
                       K.FStore.dateField: messgaeDate]) { (error) in
                        if error != nil{
                            print("ther was an issue saving data to firestore:\(error!)")
                        }else{
                            print("data saved successfully")
                            DispatchQueue.main.async {
                                self.messageTextfield.text = ""
                            }
                        }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden  = true
            cell.rightImageView.isHidden = false
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }else{
            cell.leftImageView.isHidden  = false
            cell.rightImageView.isHidden = true
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
    
    
}
