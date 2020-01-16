//
//  Record.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import Foundation

class Record: Codable {
    let name: String
    let fileUrl: String
    let date: Date
    var duration: Double?
    
    init(name: String, fileUrl: String, date: Date) {
        self.name = name
        self.fileUrl = fileUrl
        self.date = date
        self.duration = nil
    }
    
    static let recordKey = "recordKey"
    
    static func saveRecord(record: Record) {
        do {
            var allRecords = Record.fetchRecords()
            allRecords.insert(record, at: 0)
            let data = try JSONEncoder().encode(allRecords)
            UserDefaults.standard.set(data, forKey: Record.recordKey)
        } catch let err {
            print("Failed to save record: ", err)
        }
    }
    
    static func fetchRecords() -> [Record] {
        guard let data = UserDefaults.standard.data(forKey: Record.recordKey) else { return [] }
        do {
            return try JSONDecoder().decode([Record].self, from: data)
        } catch let err {
            print("Failed to fetch records: ", err)
            return []
        }
    }
    
    static func deleteRecord(at index: Int) {
        do {
            var allRecords = Record.fetchRecords()
            for record in allRecords {
                
                try FileManager.default.removeItem(at: FileManager.getDocumentsPath().appendingPathComponent(record.fileUrl))
            }
            allRecords.removeAll()
            let data = try JSONEncoder().encode(allRecords)
            UserDefaults.standard.set(data, forKey: Record.recordKey)
        } catch let err {
            print("Failed to delete record: ", err)
        }
    }
}
