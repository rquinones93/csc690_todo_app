//
//  TasksUtility.swift
//  ToDoApp
//
//  Created by Robert Quinones on 10/23/18.
//  Copyright © 2018 Robert Quiñones. All rights reserved.
//

import Foundation

// Archive, Fetch, Save Tasks

class TaskUtility {
    
    private static let key = "tasks"
    
    // Archive
    private static func archive(_ tasks: [[Task]]) -> NSData {
        var returnData: NSData?
        
        do {
            returnData = try NSKeyedArchiver.archivedData(withRootObject: tasks, requiringSecureCoding: false) as NSData
            
        } catch {
            print(error.localizedDescription)
        }
        
        return returnData!
    }
    
    // Fetch - Returns the Unfinished or Finished Tasks arrays
    static func fetch() -> [[Task]]? {
        guard let unarchivedData = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
        
        var returnData: [[Task]]?
        
        do {
            returnData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedData) as? [[Task]]
            
        } catch {
            print(error.localizedDescription)
        }
        
        return returnData
    }
    
    // Save
    static func save(_ tasks: [[Task]]) {
        
        // Archive the Data
        let archivedTasks = archive(tasks)
        
        // Set up object for key - matches key in fetch method
        UserDefaults.standard.set(archivedTasks, forKey: key)
        
        // Write UserDefaults to disk immediately
        UserDefaults.standard.synchronize()
    }
    
}
