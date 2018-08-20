//
//  CKRecord+Helpers.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/20/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    func encoded() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.requiresSecureCoding = true
        encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return data as Data
    }
}
