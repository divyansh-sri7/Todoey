import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{

    let realm = try! Realm()

    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        tableView.separatorStyle = .none
        //MARK: - navigation bar color
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    //MARK: - addButtonPressed
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField=UITextField()
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default){ action in
            let newCategory = Category()
            newCategory.color=UIColor.randomFlat().hexValue()
            newCategory.name=textField.text!
            self.saveData(category: newCategory)
            self.tableView.reloadData()
        }
        
        alert.addTextField{ alertTextField in
            alertTextField.placeholder="Create new Category"
            textField=alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    
    
    //MARK: - tableview data source methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categoryArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text=categoryArray?[indexPath.row].name ?? ""
        tableView.rowHeight=80.0
        cell.backgroundColor=UIColor(hexString: (categoryArray?[indexPath.row].color)!)
        cell.textLabel?.textColor=ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    
    //MARK: - tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC=segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - data manipulation
    
    func saveData(category : Category){
        do{
            try realm.write(){
                realm.add(category)
            }
        }catch{
            print("Error saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    //MARK: - delete category from swipe
    
    override func updateDataModel(at indexPath: IndexPath) {
        if let categoryForDeletetion = categoryArray?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(categoryForDeletetion)
                }
            }catch{
                print("Error deleting category \(error)")
            }
        }
    }
}
