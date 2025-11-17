//
//  AuthServices.swift
//  expenso
//
//  Created by Kurnia Adi Nugroho on 16/11/25.
//

import FirebaseAuth

class AuthServices {
    // MARK: - Sign Up

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void,
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String,
                completion: @escaping (Result<User, Error>) -> Void)
    {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    // MARK: - Sign Out

    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Current User

    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
