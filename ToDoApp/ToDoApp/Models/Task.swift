//
//  Task.swift
//  ToDoApp
//
//  Created by Robert Quinones on 10/21/18.
//  Copyright © 2018 Robert Quiñones. All rights reserved.
//

import Foundation

class Task: NSObject, NSCoding {
    
    // Object Variables
    var name: String?
    var isCompleted: Bool?
    
    // UserDefaults Keys
    private let nameKey = "name"
    private let completedKey = "isCompleted"
    
    init(name: String) {
        self.name = name
        self.isCompleted = false
    }
    
    init(name: String, isCompleted: Bool) {
        self.name = name
        self.isCompleted = isCompleted
    }
    
    // Encode name and isCompleted
    func encode(with aCoder: NSCoder) {
        aCoder.encode( self.name, forKey: nameKey)
        aCoder.encode( self.isCompleted, forKey: completedKey)
    }
    
    // Decode name and isCompleted
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: nameKey) as? String,
            let isCompleted = aDecoder.decodeObject(forKey: completedKey) as? Bool
            else { return }
        
        // If successfully reads data from disk, set to object members
        self.name = name
        self.isCompleted = isCompleted
    }
}
