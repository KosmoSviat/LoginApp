//
//  KeychainManager.swift
//  LoginApp
//
//  Created by Sviatoslav Samoilov on 18.07.2023.
//

import Foundation
import Security

final class KeychainManager {
    private static let service = "Login"
    
    static func save(email: String, password: String) -> Bool {
        let passwordData = password.data(using: .utf8)
        
        let query: [NSString: AnyObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: email as AnyObject,
            kSecAttrService: service as AnyObject,
            kSecValueData: passwordData as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    static func checkUser(with email: String, password: String) -> Bool {
        let query: [NSString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: email,
            kSecAttrService: service,
            kSecReturnData: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            let savedPassword = String(data: data, encoding: .utf8)
            return password == savedPassword
        } else {
            debugPrint("Error for getting password from Keychain")
            return false
        }
    }
}
