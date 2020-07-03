//
//  ListingViewController.swift
//  ListingApp
//
//  Created by Austin Donovan on 6/5/20.
//  Copyright © 2020 Austin Donovan. All rights reserved.
//

import UIKit
import Firebase

class ListingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    let db = Firestore.firestore()
    var todos: [Todo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true

        // Do any additional setup after loading the view.
        loadTodos()
    }
    
    func loadTodos() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapShot, error) in
                
                self.todos = []
                
                if let e = error {
                    print("There was an error retrieving data from Firestore. \(e)")
                } else {
                    if let snapShotDocuments = querySnapShot?.documents {
                        for doc in snapShotDocuments {
                            let data = doc.data()
                            if let messageSender = data[K.FStore.senderField] as? String,
                                let messageBody = data[K.FStore.bodyField] as? String {
                                let newMessage = Todo(sender: messageSender, body: messageBody, completed: false)
                                self.todos.append(newMessage)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                    let indexPath = IndexPath(row: self.todos.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                            }
                        }
                    }
                }
        }
    }
    
    @IBAction func addToDoPressed(_ sender: UIButton) {
        if let todoBody = messageTextField.text, let todoSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: todoSender,
                K.FStore.bodyField: todoBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ])
            { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
}


extension ListingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = todos[indexPath.row].body
        return cell
    }
    
}
