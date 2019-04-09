//
//  CloudShare.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 4/8/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

// Making a CloudUploadable version of CKShare so that I can easily "save" the CKShare using the CloudContorller. It needs all the seemingly redundant properties to conform and make the CloudController code easier.
// I may consider reworking the functions in CloudController instead to be able to handle more types than just CloudUploadable, but this will do for now.
class CloudShare: CKShare, CloudUploadable {
    var ckRecord: CKRecord {
        get {
            return self
        }
        set {
            // Do nothing, doesn't apply for this and shouldn't be called
            print("Tried to set ckRecord of CloudUploadable (doesn't apply); check uses of CloudShare to find misuse")
        }
    }
    
    var isSynced: Bool = false
    
    func update(withRecord record: CKRecord) {
        print("Tried to update a CloudShare (subclass of CKRecord). Just set it to the desired value insetead. Method implemented only for compliance with CloudUploadable protocol.")
    }
    
    
}
