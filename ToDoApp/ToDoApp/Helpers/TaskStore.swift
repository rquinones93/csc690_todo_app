//
//  TaskStore.swift
//  ToDoApp
//
//  Created by Robert Quinones on 10/21/18.
//  Copyright © 2018 Robert Quiñones. All rights reserved.
//

import Foundation

class TaskStore {
    // Array to hold finished and unfinished tasks
    var tasks = [
        [Task](), // Unfinished
        [Task]()  // Finished
    ]
    
    // Add Tasks to either Unfinished or Finished Array
    func addTask(_ task: Task, at index: Int, isCompleted: Bool = false) {
        // Determines which subsection to add to
        let taskSection = isCompleted ? 1 : 0
        
        tasks[ taskSection ].insert(task, at: index)
    }
    
    // Remove Task from Specific Index - Returning value can be potentially discardable
    @discardableResult func removeTask(at index: Int, isCompleted: Bool = false) -> Task {
        // Determines which subsection to add to
        let taskSection = isCompleted ? 1 : 0
        
        
        
        // Returns Task then removes it from array
        return tasks[ taskSection ].remove(at: index)
    }
    
    // Update Task Description
    func updateTask(_ task: Task, at index: Int, with name: String, isCompleted: Bool = false) {
        // Determines which subsection to add to
        let taskSection = isCompleted ? 1 : 0
        
        tasks[ taskSection ][ index ].name = name
    }
}
