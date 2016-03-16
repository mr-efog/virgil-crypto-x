//
//  VirgilCryptoSwiftTests.swift
//  VirgilCryptoSwiftTests
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

import UIKit
import XCTest

class VC002_CryptorSwiftTests: XCTestCase {
    
    var toEncrypt: NSData! = nil
    
    override func setUp() {
        super.setUp()
        
        let message = NSString(string: "Secret message which is necessary to be encrypted.")
        self.toEncrypt = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    override func tearDown() {
        self.toEncrypt = nil
        super.tearDown()
    }
    
    func test001_createCryptor() {
        let cryptor = VSSCryptor()
        XCTAssertNotNil(cryptor, "VCCryptor instance should be created.");
    }
    
    func test002_keyBasedEncryptDecrypt() {
        // Generate a new key pair
        let keyPair = VSSKeyPair()
        // Generate a public key id
        let recipientId = NSUUID().UUIDString
        // Encrypt:
        // Create a cryptor instance
        let cryptor = VSSCryptor()
        // Add a key recepient to enable key-based encryption
        do {
            try cryptor.addKeyRecipient(recipientId, publicKey: keyPair.publicKey(), error: ())
        }
        catch let error as NSError {
            print("Error adding key recipient: \(error.localizedDescription)")
            XCTFail()
        }
        // Encrypt the data
        var encryptedData = NSData()
        do {
            encryptedData = try cryptor.encryptData(self.toEncrypt, embedContentInfo: true, error: ())
        }
        catch let error as NSError {
            print("Error encrypting data: \(error.localizedDescription)")
            XCTFail()
        }
        XCTAssertTrue(encryptedData.length > 0, "The data encrypted with key-based encryption should have an actual content.");
    
        // Decrypt:
        // Create a completely new instance of the VCCryptor object
        let decryptor = VSSCryptor()
        // Decrypt data using key-based decryption
        var plainData = NSData()
        do {
            plainData = try decryptor.decryptData(encryptedData, recipientId: recipientId, privateKey: keyPair.privateKey(), keyPassword: nil, error: ())
        }
        catch let error as NSError {
            print("Error decrypting data: \(error.localizedDescription)")
            XCTFail()
        }
        XCTAssertEqual(plainData, self.toEncrypt, "Initial data and decrypted data should be equal.")
    }
    
    func test003_passwordBasedEncryptDecrypt() {
        // Encrypt:
        let password = "secret"
        // Create a cryptor instance
        let cryptor = VSSCryptor()
        // Add a password recepient to enable password-based encryption
        do {
            try cryptor.addPasswordRecipient(password, error: ())
        }
        catch let error as NSError {
            print("Error adding password recipient: \(error.localizedDescription)")
            XCTFail()
        }
        // Encrypt the data
        var encryptedData = NSData()
        do {
            encryptedData = try cryptor.encryptData(self.toEncrypt, embedContentInfo: false, error: ())
        }
        catch let error as NSError {
            print("Error encrypting data: \(error.localizedDescription)")
            XCTFail()
        }
        XCTAssertTrue(encryptedData.length > 0, "The data encrypted with password-based encryption should have an actual content.");
        
        var contentInfo = NSData()
        do {
            contentInfo = try cryptor.contentInfoWithError()
        }
        catch let error as NSError {
            print("Error getting content info from cryptor: \(error.localizedDescription)")
            XCTFail()
        }
        XCTAssertTrue(contentInfo.length > 0, "Content Info should contain necessary information.");
        // Decrypt:
        // Create a completely new instance of the VCCryptor object
        let decryptor = VSSCryptor()
        do {
            try decryptor.setContentInfo(contentInfo, error: ())
        }
        catch let error as NSError {
            print("Error setting content info to decryptor: \(error.localizedDescription)")
            XCTFail()
        }
        // Decrypt data using password-based decryption
        var plainData = NSData()
        do {
            plainData = try decryptor.decryptData(encryptedData, password: password, error: ())
        }
        catch let error as NSError {
            print("Error decrypting data: \(error.localizedDescription)")
            XCTFail()
        }
        XCTAssertEqual(plainData, self.toEncrypt, "Initial data and decrypted data should be equal.")
    }
    
}