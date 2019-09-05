//
//  CloudKitErrorHandler.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

// Based off of Apple's code: https://developer.apple.com/library/archive/samplecode/CloudKitShare/Listings/CloudShares_HandleCloudKitError_swift.html#//apple_ref/doc/uid/TP40017580-CloudShares_HandleCloudKitError_swift-DontLinkElementID_10

// This should be used by the Cloud Controller to handle any errors that occur

class ErrorHandler {
    enum CloudKitOperationType: String {
        case accountStatus = "AccountStatus"// Doing account check with CKContainer.accountStatus.
        case fetchRecords = "FetchRecords"  // Fetching data from the CloudKit server.
        case modifyRecords = "ModifyRecords"// Modifying records (.serverRecordChanged should be handled).
        case deleteRecords = "DeleteRecords"// Deleting records.
        case modifyZones = "ModifyZones"    // Modifying zones (.serverRecordChanged should be handled).
        case deleteZones = "DeleteZones"    // Deleting zones.
        case fetchZones = "FetchZones"      // Fetching zones.
        case modifySubscriptions = "ModifySubscriptions"    // Modifying subscriptions.
        case deleteSubscriptions = "DeleteSubscriptions"    // Deleting subscriptions.
        case fetchChanges = "FetchChanges"  // Fetching changes (.changeTokenExpired should be handled).
        case acceptShare = "AcceptShare"    // Doing CKAcceptSharesOperation.
    }
    
    // This function does all the work
    // If it returns nil, it means that there is no error or the error is ignorable
    // If it returns a CKError, there is an error. The calls should determine how to handle it.
    static func handleCloudKitError(_ error: Error?, operation: CloudKitOperationType, affectedObjects: [Any]? = nil) -> CKError? {
        // if the error nil, everything is fine, the operation completion() can continue
        guard let nsError = error as NSError? else { return nil }
        
        print("!ERROR!: \(operation.rawValue) operation error: \(nsError), userInfo: \(nsError.userInfo), localizedDescription: \(nsError.localizedDescription)")
        
        // Partial errors can occur when fetching or changing the database
        //
        // When modifying zones, records, and subscriptions, .serverRecordChanged may happen
        // if the other peer changed the item at the same time. In that case, retrieve the first
        // CKError object and return to callers.
        //
        // In the case of .fetchRecords and .fetchChanges, the specified items or zone may
        // just be deleted by the other peer and doesn't exist in the database
        // (.unknownItem or .zoneNotFound).
        //
        if let partialError = nsError.userInfo[CKPartialErrorsByItemIDKey] as? NSDictionary {
            
            let errors = affectedObjects?.map({ partialError[$0] }).filter({ $0 != nil })
            
            // If the error doesn't affect the affectedObjects, ignore it.
            // Only handle the first error.
            //
            guard let ckError = errors?.first as? CKError else { return nil }
            
            // Items not found. Silently ignore for the delete operation.
            //
            if operation == .deleteZones || operation == .deleteRecords || operation == .deleteSubscriptions {
                if ckError.code == .unknownItem {
                    return nil
                }
            }
            
            switch ckError.code {
            case .serverRecordChanged:
                print("Server record changed. Consider using serverRecord and ignore this error!")
            case .zoneNotFound:
                print("Zone not found. May have been deleted. Probably ignore!")
            case .unknownItem:
                print("Unknown item. May have been deleted. Probably ignore!")
            case .batchRequestFailed:
                print("Atomic failure!")
            default:
                print("!ERROR!: \(operation.rawValue) operation error: \(nsError)")
            }
            
            return ckError
        }
        
        // In the case of fetching changes:
        // .changeTokenExpired: return for callers to refetch with nil server token.
        // .zoneNotFound: return for callers to switch zone, as the current zone has been deleted.
        // .partialFailure: zoneNotFound will trigger a partial error as well.
        //
        if operation == .fetchChanges {
            if let ckError = error as? CKError {
                if ckError.code == .changeTokenExpired || ckError.code == .zoneNotFound {
                    return ckError
                }
            }
        }
        
        return error as? CKError
    }
}

