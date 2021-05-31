//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Realm
    
    var realm = try! Realm()
    var todoItems: Results<RealmItemModel>?
    
    var selectedCategory: RealmCategoryModel? {
        didSet {
            loadItems()
        }
    }
    
    //Core data
    
//    var itemArray = [Item]()
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    var selectedCategory: CategoryModel? {
//        didSet {
//            loadItems()
//        }
//    }
    
//    let defaults = UserDefaults.standard

//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        loadItems()
        tableView.separatorStyle = .none
       
    }

    
    override func viewWillAppear(_ animated: Bool) {
                
        if let colorHex = selectedCategory?.color {
            
            title = selectedCategory!.name
           
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navbar doesn't exist")}
            
            if let color = UIColor(hexString: colorHex) {

                navBar.backgroundColor = color
                searchBar.barTintColor = color
                navBar.barTintColor = color
                navBar.tintColor = ContrastColorOf(color, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
                
                
                
                searchBar.searchTextField.backgroundColor = UIColor.white
                
                
                if #available(iOS 13.0, *) {
                    let appearance = UINavigationBarAppearance()
                    appearance.backgroundColor = color
                    appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
                    appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
                    
                    navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
                    navigationController?.navigationBar.standardAppearance = appearance
                    navigationController?.navigationBar.compactAppearance = appearance
                    navigationController?.navigationBar.scrollEdgeAppearance = appearance
                }
            }
        }
    }
    
    //MARK: - Tableview datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.isDone ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No item added yet."
        }
        
        return cell
    }
    
    //MARK: - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("Error updating, \(error)")
            }
        }
        
        tableView.reloadData()

//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
//        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
//        saveItem()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    
    @IBAction func addNewItemPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
                        
//            let newItem = Item(context: self.context)
//            newItem.title = textField.text!
//            newItem.isDone = false
//            newItem.parentCategory = self.selectedCategory
//
//            self.itemArray.append(newItem)
//            self.saveItem()
            
            // Realm
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = RealmItemModel()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        }
                    
                } catch {
                    print("Error saving item, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulations methods
    
    // Core data
    
//    func saveItem() {
//        do {
//            try context.save()
//        } catch {
//            print("Error encoding, \(error)")
//        }
//        tableView.reloadData()
//    }
//
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching, \(error)")
//        }
//        tableView.reloadData()
//    }
    
    // Realm
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting, \(error)")
            }
        }
    }
}

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Realm
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
//        print(todoItems)
        tableView.reloadData()
        // Core data
        
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//
//        loadItems(with: request, predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
