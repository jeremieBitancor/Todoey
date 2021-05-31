//
//  CategoryViewController.swift
//  Todoey
//
//  Created by jeremie bitancor on 4/2/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    //Core data
//    var categoryArray = [CategoryModel]()
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Realm
    var categoryArray: Results<RealmCategoryModel>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navbar doesn't exist")}
   
        navBar.backgroundColor = UIColor.white
        navBar.tintColor = UIColor.black
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            
            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            if let color = category.color {
                cell.backgroundColor = UIColor(hexString: color)
                cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
            }
            
        }
        
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }

    //MARK: - Data manipulation methods
    
//  Core data
    
//    func saveCategory() {
//        do {
//            try context.save()
//        } catch {
//            print("Error saving data, \(error)")
//        }
//        tableView.reloadData()
//    }
    
//    func loadCategory(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
//        do {
//            categoryArray = try context.fetch(request)
//        } catch {
//            print("Error fetching, \(error)")
//        }
//        tableView.reloadData()
//    }
    
    // Realm
    
    func save(category: RealmCategoryModel) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory() {
        categoryArray = realm.objects(RealmCategoryModel.self)
        tableView.reloadData()
    }
    
    // Delete
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting, \(error)")
            }
        }
    }

    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
//            Core data
//            let newCategory = CategoryModel(context: self.context)
//            newCategory.name = textfield.text!
//            self.categoryArray.append(newCategory)
//            self.saveCategory()
            
            // Realm
            let newCategory = RealmCategoryModel()
            newCategory.name = textfield.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter category"
            textfield = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

