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

class ViewController: UITableViewController, TaskProtocol , UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var allTasks = [Task]()
    lazy var filteredTasks = allTasks
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        searchBar.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButton))
        navigationItem.leftBarButtonItem = editButtonItem
        getAllTasks()
    }
    
    func getAllTasks() {
        let request = Task.createfetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        do {
            allTasks = try appDelegate.persistentContainer.viewContext.fetch(request)
            
            self.tableView.reloadData()
            filteredTasks = allTasks
        }
        catch {
            print("Failed to load all your tasks!")
        }
    }
    
    func createTask(string title: String, string description: String ) {
        let newTask = Task(context: appDelegate.persistentContainer.viewContext)
        newTask.title = title
        newTask.taskDescription = description
        newTask.orderIndex = Int32(filteredTasks.count)
        
        allTasks.append(newTask)
        filteredTasks.append(newTask)
        
        ReorderBase()

        appDelegate.saveContext()
        tableView.reloadData()
    }
    
    func updateTask(task: Task, title: String, taskDescription: String) {
        task.title = title
        task.taskDescription = taskDescription
        appDelegate.saveContext()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = filteredTasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.taskDescription
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            let navController = UINavigationController(rootViewController: vc)
            vc.delegate = self
            vc.actionPicker = .readEdit
            vc.taskToShow = filteredTasks[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            present(navController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = filteredTasks[indexPath.row]
            appDelegate.persistentContainer.viewContext.delete(task)
            filteredTasks.remove(at: indexPath.row)
            guard let taskToDelete = allTasks.firstIndex(of: task) else { return }
            allTasks.remove(at: taskToDelete)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            ReorderBase()
            
            appDelegate.saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.allTasks[sourceIndexPath.row]
        allTasks.remove(at: sourceIndexPath.row)
        allTasks.insert(movedObject, at: destinationIndexPath.row)
        filteredTasks = allTasks
        
        ReorderBase()
        
        appDelegate.saveContext()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTasks = []
        
        if searchBar.text == "" {
            filteredTasks = allTasks
        }
        else {
            for task in allTasks {
                if task.title.lowercased().contains(searchText.lowercased()) || task.taskDescription.lowercased().contains(searchText.lowercased()) {
                    filteredTasks.append(task)
                }
            }
        }
        self.tableView.reloadData()
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        editButtonItem.isEnabled = false
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
        filteredTasks = allTasks
        editButtonItem.isEnabled = true
        searchBar.setShowsCancelButton(false, animated: true)
        self.tableView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
  
   
}

