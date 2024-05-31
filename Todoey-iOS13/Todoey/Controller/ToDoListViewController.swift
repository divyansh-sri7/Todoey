//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    
    var toDoItems : Results<Item>?
    
    var selectedCategory : Category?{
        didSet{
            loadData()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadData()
        tableView.separatorStyle = .none
        
        
        //MARK: - navigation bar color
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(hexString: selectedCategory!.color)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor=UIColor.white
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        title=selectedCategory!.name
        searchBar.placeholder="Search"
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if let navBarColor=UIColor(hexString: selectedCategory!.color){
            if let navbar = navigationController?.navigationBar{
                navbar.barTintColor = navBarColor
                navbar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navbar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
        }
    }
    
    //MARK: - tableview data source methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return toDoItems?.count ?? 0
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text=toDoItems?[indexPath.row].title ?? ""
        cell.accessoryType = toDoItems?[indexPath.row].done==true ? .checkmark : .none
        
        
        cell.backgroundColor=UIColor(hexString: selectedCategory!.color)!.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(toDoItems!.count)))
        cell.textLabel?.textColor=ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        
        tableView.rowHeight=80.0
        return cell
        }
        
    
    //MARK: - tableview delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row]{
            do{
                try realm.write(){
                    item.done.toggle()
                }
            }catch{
                print("Error toggling done property \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - add button
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        
        var textField=UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write(){
                        let newItem=Item()
                        newItem.title=textField.text!
                        newItem.dateCreated=Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving data to database \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Create New Item"
            textField=alertTextField
        }
            alert.addAction(action)
            
            present(alert,animated: true,completion: nil)
        
    }
    
    //MARK: - save and load data
    
    
    func loadData()
    {
        
        toDoItems=selectedCategory?.items.sorted(byKeyPath: "dateCreated",ascending: false)
        tableView.reloadData()
    }
    
    //MARK: - delete category from swipe
    override func updateDataModel(at indexPath: IndexPath) {
        if let itemForDeletetion = toDoItems?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(itemForDeletetion)
                }
            }catch{
                print("Error deleting category \(error)")
            }
        }
    }
}

//MARK: - UISearchBarDelegate

extension ToDoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems=toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated",ascending: false)
        tableView.reloadData()
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
