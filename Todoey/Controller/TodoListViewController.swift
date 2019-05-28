//
//  ViewController.swift
//  Todoey
//
//  Created by DJ Satoda on 4/30/19.
//  Copyright © 2019 DJ Satoda. All rights reserved.
//
// Notes: overarching lesson - associate a property not with a cell but with our data. Check mark should be associated with the task, not the cell

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Path to where data is being saved in app
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        
//        let newItem = Item()
//        newItem.title = "Find Mike"
//        itemArray.append(newItem)
//
//        let newItem2 = Item()
//        newItem2.title = "Buy Eggos"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.title = "Destroy Demogorgon"
//        itemArray.append(newItem3)
        
        loadItems()
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
    }
    
    //MARK: - Tableview Datasource methods
    // These tell tableview what cells should display and how many rows
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        
        // below if-else block can be refactored with ternary operator >>> cell.accessoryType = item.done == true ? .checkmark : .none
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    // MARK: - Tableview Delegate Methods
    // These get fired whenever we click on any cell in tableview
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // can be refactored to: itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        if itemArray[indexPath.row].done == false {
            itemArray[indexPath.row].done = true
        } else {
            itemArray[indexPath.row].done = false
        }

        // Delete when selected
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
//
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    

    // MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen when user clicks add item in UI alert
            
            // Within parantheses = gives access to AppDelegate as an object, rather than a class (which allows us to access its properties)
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveItems()
            
        }
        
        // Adds text field to alert view controller
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item" // sample text in field
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    
    }
    
    
    //MARK: - Model Manuipulation Methods
    
    func saveItems() {
        // Inside this method, we need to be able to commit our contents to permanent storage inside our persistent container
        
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        
        // updates tableview for new rows
        self.tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        // in plain english, request is of type NSFetchRequest which should fetch an array of Items, and if when we call this function  and we don't provide a parameter for the request, then use default value of Item.fetchRequest()
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
    

    
}

//MARK: - Search Bar Methods
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Notice that this property asks for plural sortDescriptors (e.g. an array of sortDescriptors). We are only providing one; that's okay
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)

    }
    
    // gets triggered anytime text in searchbar changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if no text in searchbar
        if searchBar.text!.count == 0 {
            loadItems()
            
            // Object that manages/prioritizes execution of work items to threads. Main is where you should be updating UI elements
            DispatchQueue.main.async {
                // Search bar should no longer be selected
                searchBar.resignFirstResponder()
            }
            
            
            
        }
    }
}
