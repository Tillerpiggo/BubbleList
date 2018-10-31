//
//  CKRecord+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    func encoded() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return data as Data
    }
}

extension CKRecord: CloudUploadable {
    var ckRecord: CKRecord {
        get {
            return self
        }
        set {
            // Do nothing...
            print("Tried to set ckRecord property of CKRecord (CloudUploadable extension). Handle appropriately.")
        }
    }
    
    func update(withRecord record: CKRecord) {
        print("Tried to update a ckRecord. Just set it to the desired value insetead. Method implemented only for compliance with CloudUploadable protocol.")
    }
}
