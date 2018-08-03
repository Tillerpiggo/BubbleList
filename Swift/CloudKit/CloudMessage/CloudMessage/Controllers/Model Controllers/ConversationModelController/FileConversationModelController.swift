//
//  FileConversationModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

// Saving to device stuff

extension ConversationModelController {
    // ON-DEVICE STORAGE:
    
    func saveToFile(_ conversations: [Conversation]) {
        let archiveURL = getArchiveURL()
        
        let encoder = PropertyListEncoder()
        let encodedConversations = try? encoder.encode(conversations)
        
        try? encodedConversations?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func loadFromFile() {
        let archiveURL = getArchiveURL()
        
        let decoder = PropertyListDecoder()
        guard let retrievedConversationData = try? Data(contentsOf: archiveURL),
            let decodedConversations = try? decoder.decode([Conversation].self, from: retrievedConversationData) else {
                print("On-device storage failed and could not be accessed")
                return
        }
        
        conversations = self.mergeConversations(decodedConversations, with: conversations)
    }
    
    // HELPER METHODS:
    
    private func getArchiveURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent(localCacheID).appendingPathExtension("plist")
        
        return archiveURL
    }
}
