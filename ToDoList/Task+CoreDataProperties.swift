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

    @nonobjc public class func createfetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var taskDescription: String
    @NSManaged public var title: String
    @NSManaged public var orderIndex: Int32

}

extension Task : Identifiable {

}
