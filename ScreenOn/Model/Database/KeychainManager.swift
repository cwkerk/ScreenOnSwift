//
//  KeychainManager.swift
//  IREP-Security
//
//  Created by Chin Wee Kerk on 4/7/18.
//  Copyright © 2018 Chin Wee. All rights reserved.
//

import Foundation
import Security

class KeychainManager {
    
    static let shared = KeychainManager()
    
    private func prepareAttributes(forService service: String) -> Dictionary<String, Any> {
        var attributes = Dictionary<String, Any>()
        attributes[kSecClass as String] = kSecClassGenericPassword
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        attributes[kSecAttrService as String] = service.data(using: .utf8)!
        return attributes
    }
    
    @discardableResult func createKeyChain(forService service: String, forData data: Data) -> Bool {
        var attributes = self.prepareAttributes(forService: service)
        if SecItemCopyMatching(attributes as CFDictionary, nil) == noErr { // keychain exist
            SecItemDelete(attributes as CFDictionary)
            return self.createKeyChain(forService: service, forData: data)
        } else {
            attributes[kSecValueData as String] = data
            return SecItemAdd(attributes as CFDictionary, nil) == noErr
        }
    }
    
    func retrieveKeyChain(forService service: String) -> Data? {
        var attributes = self.prepareAttributes(forService: service)
        attributes[kSecReturnData as String] = kCFBooleanTrue
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(attributes as CFDictionary, &dataTypeRef)
        if status == errSecSuccess { // keychain exist
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    @discardableResult func updateKeyChain(forService service: String, toNewData data: Data) -> Bool {
        let attributes = self.prepareAttributes(forService: service)
        if SecItemCopyMatching(attributes as CFDictionary, nil) == noErr { // keychain exist
            let newAttributes = [kSecValueData: data]
            return SecItemUpdate(attributes as CFDictionary, newAttributes as CFDictionary) == errSecSuccess
        } else {
            return false
        }
    }
    
    @discardableResult func deleteKeyChain(forService service: String) -> Bool {
        let query = self.prepareAttributes(forService: service)
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess { // keychain exist
            return SecItemDelete(query as CFDictionary) == errSecSuccess
        } else {
            return false
        }
    }
    
}
