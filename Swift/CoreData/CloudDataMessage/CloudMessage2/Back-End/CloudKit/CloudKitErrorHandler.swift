//
//  CloudKitErrorHandler.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/23/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitErrorHandler {
    func handleError(_ error: CKError?, retry: @escaping () -> Void) {
        guard let error = error, let errorCode = CKError.Code(rawValue: error.errorCode) else {
            print("Could not find corresponding error code for error")
            return
        }
        
        print("ERROR: \(error), \(error.userInfo), \(error.localizedDescription)")
        
        switch errorCode {
        case .alreadyShared:
            handleAlreadyShared(error: error)
        case .assetFileModified:
            handleAssetFileModified()
        case .assetFileNotFound:
            handleAssetFileNotFound(error: error, retry: retry)
        case .badContainer:
            handleBadContainer()
        case .badDatabase:
            handleBadDatabase()
        case .batchRequestFailed:
            handleBatchRequestFailed(error: error, retry: retry)
        case .changeTokenExpired: break
        case .constraintViolation: break
        case .incompatibleVersion: break
        case .internalError: break
        case .invalidArguments: break
        case .limitExceeded: break
        case .managedAccountRestricted: break
        case .missingEntitlement: break
        case .networkFailure: break
        case .networkUnavailable: break
        case .notAuthenticated: break
        case .operationCancelled: break
        case .partialFailure: break
        case .participantMayNeedVerification: break
        case .permissionFailure: break
        case .quotaExceeded: break
        case .referenceViolation: break
        case .requestRateLimited: break
        case .serverRecordChanged: break
        case .serverRejectedRequest: break
        case .serverResponseLost: break
        case .serviceUnavailable: break
        case .tooManyParticipants: break
        case .unknownItem: break
        case .userDeletedZone: break
        case .zoneBusy: break
        case .zoneNotFound: break
        default: break
        }
    }
    
    func handleAlreadyShared(error: CKError) {
        print("TODO: Come back to this once you add shares and shared databases")
    }
    
    func handleAssetFileModified() {
        print("This error shouldn't happen. \"Consider copying assets before handing them to CloudKit to upload, or perform synchronization inside of your app to prevent it from modifying assets until they have been successfully uploaded.\"")
    }
    
    func handleAssetFileNotFound(error: CKError, retry: @escaping () -> Void) {
        print("Add this in later because assets will not be used in the Magnet MVP. However, if it is decided to add photo/video/large text documents:\n#1: If fetching records, retry\n#2: If saving records, this means that the asset on the record was removed before CloudKit was able to upload this asset to the server. Make sure that your assets exist until CKModifyRecordsOperation.completionBlock() is called.")
    }
    
    func handleBadContainer() {
        print("This error should only happen during the initial development of an app.")
    }
    
    func handleBadDatabase() {
        print("This error means that the operation was submitted to the wrong database. Make sure you are not submitting a sharing operation to the public database or a zone create operation in the shared database.")
    }
    
    func handleBatchRequestFailed(error: CKError, retry: @escaping () -> Void) {
        // TODO:
        // Loop through all per-item errors under the CKPartialErrorsByItemIDKey
        // If it isn't another CKErrorBatchRequestFailed error, handle the error
        // After everything is handled, retry the entire operation
    }
    
    func handleChangeTokenExpired() {
        // TODO:
        // Toss out local cache
        // Set change token to nil
        // Re-fetch changes
    }
    
    func handleConstraintViolation() {
        print("An error indicating that a unique field constraint was violated. Address once any field constraints are added.")
    }
    
    func handleIncompatibleVersion() {
        print("TODO: Alert user to upgrade to the newest version of the app. I guess you can give them the option to keep using the app, just tell them that the cloud won't work.")
    }
    
    func handleInternalError() {
        print("This is a nonrecoverable error. File a bug report to Apple.")
    }
    
    func handleInvalidArguments() {
        print("This means that you are creating a CloudKit operation (to save, fetch changes, etc.) without proper arguments. Make sure that you safeguard against invalid arguments or change the code to not use invalid arguments.")
    }
}
