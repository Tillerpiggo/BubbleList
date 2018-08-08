//
//  FileController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/7/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

class FileController {
    let manager = FileManager.default
    
    func save(_ data: [NSCoding], to fileName: String) {
        NSKeyedArchiver.archiveRootObject(data, toFile: path(withExtension: fileName))
    }
    
    func load(from fileName: String) -> [Any]? {
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: path(withExtension: fileName)) {
            return [ourData]
        } else {
            return nil
        }
    }
    
    private func path(withExtension fileName: String) -> String {
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        return url.appendingPathComponent(fileName)!.appendingPathExtension("plist").path
    }
}
