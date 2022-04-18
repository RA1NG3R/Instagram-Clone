//
//  AuthManager.swift
//  Instagram
//
//  Created by Subodh Mahajan on 13/02/22.
//

import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
    
    public func registerNewUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Check if username and email is available
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) { canCreate in
            if canCreate {
                // Create account and insert it to DB
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        // Firebase auth could not create account
                        completion(false)
                        return
                    }
                    
                    // Insert into DB
                    DatabaseManager.shared.insertNewUser(with: email, username: username) { inserted in
                        if inserted {
                            completion(true)
                            return
                        }
                        else {
                            // Failed to insert in DB
                            completion(false)
                            return
                        }
                    }
                }
            }
            else {
                // Either username or email does not exist
                completion(false)
            }
            
        }
        
    }
    
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // email log in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
        else if let username = username {
            // username login
        }
    }
    
    /// Attempt to logout firebase user
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            print(error)
            completion(false)
            return
        }
    }
    
}
