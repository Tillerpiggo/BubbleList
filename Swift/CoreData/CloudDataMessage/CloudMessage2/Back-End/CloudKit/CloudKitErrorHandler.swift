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
        case .assetNotAvailable:
            handleAssetNotAvailable()
        case .badContainer:
            handleBadContainer()
        case .badDatabase:
            handleBadDatabase()
        case .batchRequestFailed:
            handleBatchRequestFailed(error: error, retry: retry)
        case .changeTokenExpired:
            handleChangeTokenExpired()
        case .constraintViolation:
            handleConstraintViolation()
        case .incompatibleVersion:
            handleIncompatibleVersion()
        case .internalError:
            handleInternalError()
        case .invalidArguments:
            handleInvalidArguments()
        case .limitExceeded:
            handleLimitExceeded()
        case .managedAccountRestricted:
            handleManagedAccountRestricted()
        case .missingEntitlement:
            handleMissingEntitlement()
        case .networkFailure:
            handleNetworkFailure(error: error, retry: retry)
        case .networkUnavailable:
            handleNetworkUnavailable(error: error, retry: retry)
        case .notAuthenticated:
            handleNotAuthenticated(error: error, retry: retry)
        case .operationCancelled:
            handleOperationCancelled()
        case .partialFailure:
            handlePartialFailure(error: error, retry: retry)
        case .participantMayNeedVerification:
            handleParticipantMayNeedVerification()
        case .permissionFailure:
            handlePermissionFailure()
        case .quotaExceeded:
            handleQuotaExceeded()
        case .referenceViolation:
            handleReferenceViolation()
        case .requestRateLimited:
            handleRequestRateLimited(error: error, retry: retry)
        case .resultsTruncated: break // Deprecated
        case .serverRecordChanged:
            handleServerRecordChanged(error: error, retry: retry)
        case .serverRejectedRequest:
            handleServerRejectedRequest()
        case .serverResponseLost:
            handleServerResponseLost()
        case .serviceUnavailable:
            handleServiceUnavailable(error: error, retry: retry)
        case .tooManyParticipants:
            handleTooManyParticipants(error: error, retry: retry)
        case .unknownItem:
            handleUnknownItem()
        case .userDeletedZone:
            handleUserDeletedZone()
        case .zoneBusy:
            handleZoneBusy(error: error, retry: retry)
        case .zoneNotFound:
            handleZoneNotFound(error: error, retry: retry)
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
    
    func handleAssetNotAvailable() {
        print("There isn't any documentation on this error. Don't worry about it until you see it if you add assets.")
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
    
    func handleLimitExceeded() {
        print("This may have changed, but a max of 400 items (records or shares) per operation, and 2 MB per request (not counting asset sizes.")
        
        // TODO: split the operation in half and try both requests again. I doubt this will happen, but I need to do some sort of test with a large number of texts in ortder to test it.
    }
    
    func handleManagedAccountRestricted() {
        print("This means the current account can't access CloudKit. TODO: While this is listed as nonrecoverable, this should push the user to offline mode and notify them that they can't interact with the Cloud.")
    }
    
    func handleMissingEntitlement() {
        print("This error should only occur during the initial development of the app. It should never occur.")
    }
    
    func handleNetworkFailure(error: CKError, retry: @escaping () -> Void) {
        // Can be retried immediately, but should wait a bit (maybe 5 seconds)
        // TODO: Retry - if network unavailable, just make the app monitor for network reachability and wait until the network is available
        
        print("TODO: Handle this error when you start doing offline mode.")
    }
    
    func handleNetworkUnavailable(error: CKError, retry: @escaping () -> Void) {
        // Basically the same as handleNetworkFailure()
        print("See: handleNetworkFailure(error:retry:)")
    }
    
    func handleNotAuthenticated(error: CKError, retry: @escaping () -> Void) {
        print("TODO: the user is not signed in. Notify them to sign in or use offline without iCloud storage and without joining other classes.")
    }
    
    func handleOperationCancelled() {
        print("This basically isn't a problem. Either your app explicitly called cancel, or CloudKit's daemon unexpectedly quit.")
    }
    
    func handlePartialFailure(error: CKError, retry: @escaping () -> Void) {
        // TODO: User the userInfo dictionary with the CKPartialErrorsByItemIDKey to see per-item errors
        // Handle the per-item errors
    }
    
    func handleParticipantMayNeedVerification() {
        print("TODO: Add once shared databases are added. Call openURL() on the share URL to give users the built in UI to verify their information (connect with an email address/phone number)")
    }
    
    func handlePermissionFailure() {
        print("This error typically occurs in the public database in on of these circumstances: You have roles defined for record types, or your app is trying to accept a share that the current user was not invited to. Inform the users that they can't repeat whatever operation caused this error.")
    }
    
    func handleQuotaExceeded() {
        print("TODO: for someone's private database, tell them to manage their storage or upgrade. If it's a shared database, prompt the user to inform the owner to manage their storage or upgrade.")
    }
    
    func handleReferenceViolation() {
        print("This is caused when you save a record with a reference to a non-existent record. This could be caused by the referenced object being deleted by another client. You should probably then ensure the existence of references before saving or fetch changes and retry.")
    }
    
    func handleRequestRateLimited(error: CKError, retry: @escaping () -> Void) {
        // TODO: Check the value of the CKErrorRetryAfterKey in the userInfo dictionary of the error
        // Retry after that many seconds
    }
    
    func handleServerRecordChanged(error: CKError, retry: @escaping () -> Void) {
        // Use the following keys in userInfo to resolve the conflict:
        // CKRecordChangedErrorClientRecordKey: the record the client attempted to save
        // CKRecordChangedErrorServerRecordKey: The record that currently exists on the server
        // CKRecordChangedErrorAncestorRecordKey: The client record without any of the changes the client attempted to save
        
        // When there is a conflict, merge all changes onto the record under the CKRecordChangedErrorServerRecordKey and attempt a new save with that record.
    }
    
    func handleServerRejectedRequest() {
        print("The server rejected the request. Look into the error to debug it. Notify the user.")
    }
    
    func handleServerResponseLost() {
        print("Just notify the user that they are offline and monitor for server connection.")
    }
    
    func handleServiceUnavailable(error: CKError, retry: @escaping () -> Void) {
        print("TODO: Implement once working on offline stuff. Check the CKErrorRetryAfterKey in userInfo and retry after that much time.")
    }
    
    func handleTooManyParticipants(error: CKError, retry: @escaping () -> Void) {
        print("Remove participants and retry or tell user that they can't add any more people. Probably just stop people from joining a class once there are 100 people. No class should have this many people.")
    }
    
    func handleUnknownItem() {
        print("May happen when trying to fetch a nonexistent record or when trying to fetch an item in the shared zone that isn't shared. Add it if you encounter it while working on shared stuff.")
    }
    
    func handleUserDeletedZone() {
        print("Wipe the local cache of the particular zone's data and as the user for permission to reupload the data.")
    }
    
    func handleZoneBusy(error: CKError, retry: @escaping () -> Void) {
        // TODO: Retry after a few seconds, and possibly ramp up the delay time exponentially. Use the CKErrorRetryAfterKey
    }
    
    func handleZoneNotFound(error: CKError, retry: @escaping () -> Void) {
        // TODO: Recreate the zone and retry
    }
}
