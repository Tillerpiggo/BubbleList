//
//  CloudUploadable.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/6/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudUploadable {
    var ckRecord: CKRecord? { get set }
}
