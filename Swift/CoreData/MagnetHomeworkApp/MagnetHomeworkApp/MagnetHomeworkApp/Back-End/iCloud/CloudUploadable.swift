//
//  CloudUploadable.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/23/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudUploadable {
    var ckRecord: CKRecord { get set }
    func update(withRecord record: CKRecord)
}
