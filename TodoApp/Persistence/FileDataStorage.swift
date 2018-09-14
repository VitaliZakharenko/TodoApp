//
//  FileDataStorage.swift
//  TodoApp
//
//  Created by vitali on 8/30/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

fileprivate struct Const {
    static let directoryName = "TodoAppDataStorage"
}

class FileDataStorage {
    
    
    private let filename: String
    private var categories = [TaskCategory]()
    private var filePath: URL
    
    init(filename: String){
        self.filename = filename
        
        let fileManager = FileManager.default
        let documents =  fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryName = documents.appendingPathComponent(Const.directoryName)
        if(!fileManager.fileExists(atPath: directoryName.path)){
            do {
                
                try fileManager.createDirectory(at: directoryName, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                fatalError(error.localizedDescription)
            }
            
        }
        
        filePath = directoryName.appendingPathComponent(filename)
        
        if (!fileManager.fileExists(atPath: filePath.path)){
                fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        
        } else {
            loadFromFile()
        }
        
    }
    
    
    private func saveToFile(){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(categories)
            try data.write(to: filePath)
            
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func loadFromFile(){
        
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: filePath)
            categories = try decoder.decode([TaskCategory].self, from: data)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    
    }
    
    
}


extension FileDataStorage: DataStorage {
    
    func allCategories() -> [TaskCategory] {
        return categories
    }
    
    func add(category: TaskCategory) {
        categories.append(category)
        saveToFile()
    }
    
    func remove(category: TaskCategory) {
        if let index = categories.index(where: {$0.id == category.id}) {
            categories.remove(at: index)
            saveToFile()
        }
    }
    
    func update(category: TaskCategory) {
        if let index = categories.index(where: {$0.id == category.id}) {
            categories[index] = category
            saveToFile()
        }
    }
    
    
    
}
