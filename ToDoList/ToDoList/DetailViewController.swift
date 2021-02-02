//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Tomislav Jurić-Arambašić on 30.01.2021..
//

import UIKit

class DetailViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: TaskProtocol?
    var actionPicker: actions?
    var taskToShow: Task?
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskDescription: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTaskTapped))
        
        taskTitle.layer.borderWidth = 1
        taskTitle.layer.borderColor = UIColor.lightGray.cgColor
        taskTitle.layer.cornerRadius = 8.0
        taskTitle.layer.borderWidth = 2.0
        taskDescription!.layer.borderWidth = 1
        taskDescription!.layer.borderColor = UIColor.lightGray.cgColor
        taskDescription.layer.cornerRadius = 8.0
        taskDescription.layer.borderWidth = 2.0

        decideAction()
    }
    
    func decideAction() {
        
        switch actionPicker {
        case .add:
            self.navigationItem.title = "Add task 📝"
            
        case .readEdit:
            self.navigationItem.title = "Task: 👀"
            if let task = taskToShow {
                taskTitle.text = task.title
                taskDescription.text = task.taskDescription
            }
        default:
            print("Error occured!")
        }
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addTaskTapped() {
        switch actionPicker {
            case .add:
                if let title = taskTitle.text, let description = taskDescription.text {
                    if title.isEmpty || description.isEmpty {
                        let alert = UIAlertController(title: "Warning", message: "You must fill all the fields", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        present(alert, animated: true, completion: nil)
                    } 
                    else {
                        delegate?.createTask(string: title, string: description)
                        dismiss(animated: true, completion: nil)
                    }
                }
            case .readEdit:
                if let title = taskTitle.text, let description = taskDescription.text {
                    if title.isEmpty || description.isEmpty {
                        let alert = UIAlertController(title: "Warning", message: "You must fill all the fields", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        present(alert, animated: true, completion: nil)
                    }
                    else {
                        if let task = taskToShow {
                            delegate?.updateTask(task: task, title: title, taskDescription: description)
                            dismiss(animated: true, completion: nil)
                        }
                    }
                }
            default :
                print("Error adding new task!")
        }
    }
}
