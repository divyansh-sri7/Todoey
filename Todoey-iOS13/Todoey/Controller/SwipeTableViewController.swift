//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Divyansh Srivastava on 13/07/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController,SwipeTableViewCellDelegate {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "")
        { action, indexPath in
            self.updateDataModel(at: indexPath)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash.fill")
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! SwipeTableViewCell
        cell.delegate=self
        tableView.rowHeight=80.0
        return cell
    }
    
    func updateDataModel(at indexPath : IndexPath){
        //update our data model
    }
}
