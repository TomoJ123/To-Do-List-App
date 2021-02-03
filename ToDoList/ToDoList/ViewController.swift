//
//  ViewController.swift
//  ToDoList
//
//  Created by Tomislav Jurić-Arambašić on 30.01.2021..
//

import UIKit

protocol TaskProtocol {
    func createTask(string title: String, string description: String )
    func updateTask(task: Task, title: String, taskDescription: String)
}

enum actions {
    case add
    case readEdit
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterForSearchBar(searchBar.text!)
  }
}

class ViewController: UITableViewController, TaskProtocol  {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var allTasks = [Task]()
    var filteredTasks: [Task] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButton))
        navigationItem.leftBarButtonItem = editButtonItem
        getAllTasks()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search tasks"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    func getAllTasks() {
        let request = Task.createfetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        do {
            allTasks = try appDelegate.persistentContainer.viewContext.fetch(request)
            self.tableView.reloadData()
        }
        catch {
            print("Failed to load all your tasks!")
        }
    }
    
    func createTask(string title: String, string description: String ) {
        let newTask = Task(context: appDelegate.persistentContainer.viewContext)
        newTask.title = title
        newTask.taskDescription = description
        newTask.orderIndex = Int32(allTasks.count)
        allTasks.append(newTask)
        
        ReorderBase()
        appDelegate.saveContext()
        tableView.reloadData()
    }
    
    func updateTask(task: Task, title: String, taskDescription: String) {
        if task.title != title || task.taskDescription != taskDescription {
            task.title = title
            task.taskDescription = taskDescription
            appDelegate.saveContext()
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
           return filteredTasks.count
         }
         return allTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task: Task
        
        if isFiltering {
            task = filteredTasks[indexPath.row]
        } else {
            task = allTasks[indexPath.row]
        }
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.taskDescription
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            let navController = UINavigationController(rootViewController: vc)
            vc.delegate = self
            vc.actionPicker = .readEdit
            if isFiltering {
                vc.taskToShow = filteredTasks[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                vc.taskToShow = allTasks[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            }
            present(navController, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task: Task
            if isFiltering {
                task = filteredTasks[indexPath.row]
                filteredTasks.remove(at: indexPath.row)
                guard let taskToDelete = allTasks.firstIndex(of: task) else { return }
                allTasks.remove(at: taskToDelete)
            } else {
                task = allTasks[indexPath.row]
                allTasks.remove(at: indexPath.row)
            }
            appDelegate.persistentContainer.viewContext.delete(task)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            ReorderBase()
            
            appDelegate.saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.allTasks[sourceIndexPath.row]
        allTasks.remove(at: sourceIndexPath.row)
        allTasks.insert(movedObject, at: destinationIndexPath.row)
        
        ReorderBase()
        
        appDelegate.saveContext()
    }
    
    func ReorderBase() {
        for (index, item) in allTasks.enumerated() {
            item.orderIndex = Int32(index)
        }
    }
    
    @objc func addTaskButton() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            let navController = UINavigationController(rootViewController: vc)
            vc.delegate = self
            vc.actionPicker = actions.add
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func filterForSearchBar(_ searchText: String) {
      filteredTasks = allTasks.filter { (task: Task) -> Bool in
        return task.title.lowercased().contains(searchText.lowercased())
      }
      tableView.reloadData()
    }
}

