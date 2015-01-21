//
//  BaseDataModel.swift
//  PAWall
//
//  Created by D on 1/14/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation


class BaseDataModel : NSObject {
    
    
    class func pwProtectionSpace() -> (NSURLProtectionSpace) {
        let url:NSURL = NSURL(string: PWHost)!
        
        
        let protSpace =
        NSURLProtectionSpace(
            host: url.host!,
            port: 80,
            `protocol`: url.scheme?,
            realm: nil,
            authenticationMethod: nil)
        
        println("prot space: \(protSpace)")
        return protSpace
    }
    
    class func storeCredential(phoneNumber: String, uuid: String)  -> () {
        let protSpace = pwProtectionSpace()
        
        if let credentials: NSDictionary = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(protSpace) {
            
            //remove all credentials
            for credentialKey in credentials {
                let credential = (credentials.objectForKey(credentialKey.key) as NSURLCredential)
                NSURLCredentialStorage.sharedCredentialStorage().removeCredential(credential, forProtectionSpace: protSpace)
            }
        }
        //store new credential
        let credential = NSURLCredential(user: phoneNumber, password: uuid, persistence: NSURLCredentialPersistence.Permanent)
        NSURLCredentialStorage.sharedCredentialStorage().setCredential(credential, forProtectionSpace: protSpace)
        
    }
    
    
    class func getStoredCredential() -> (NSURLCredential?)  {
        //check if credentials are already stored, then show it in the tune in fields
        
        if let credentials: NSDictionary? = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(pwProtectionSpace()) {
            return credentials?.objectEnumerator().nextObject() as NSURLCredential?
        }
        return nil
    }
    
}