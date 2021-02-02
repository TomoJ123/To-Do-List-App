//
//  Task+CoreDataProperties.swift
//  ToDoList
//
//  Created by Tomislav Jurić-Arambašić on 31.01.2021..
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String
    @NSManaged public var taskDescription: String

}

extension Task : Identifiable {

}
