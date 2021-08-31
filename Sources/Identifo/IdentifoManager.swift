//
//  Identifo
//
//  Copyright (C) 2019 MadAppGang Pty Ltd
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public final class IdentifoManager {
    
    public var context: Context
    public var session: Session
        
    public init(context: Context, session: Session = URLSession(configuration: .ephemeral)) {
        self.context = context
        self.session = session
    }
     
    @discardableResult
    public func registerWith(username: String, password: String, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task {
        send(RegisterWithUsername(username: username, password: password)) { [weak self] result in
            guard let self = self else { return }
            self.handleAuthResult(result: result, completion: completion)
        }
    }
    
    @discardableResult
    public func loginWith(username: String, password: String, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task {
        send(LogInWithUsername(username: username, password: password)) { [weak self] result in
            guard let self = self else { return }
            self.handleAuthResult(result: result, completion: completion)
        }
    }
    
    @discardableResult
    public func requestPhoneCode(phoneNumber: String, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task {
        send(RequestPhoneCode(phone: phoneNumber)) { result in
            switch result {
            case .success(let responce):
                completion(.success(responce))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func loginWith(phoneNumber: String, verificationCode: String, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task {
        send(PhoneLogin(phone: phoneNumber, verificationCode: verificationCode)) { [weak self] result in
            guard let self = self else { return }
            self.handleAuthResult(result: result, completion: completion)
        }
    }
    
    @discardableResult
    public func federatedLogin(provider: FederatedProvider, authorizationCode: String, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task {
        send(FederatedLogin(provider: provider, authorizationCode: authorizationCode)) { [weak self] result in
            guard let self = self else { return }
            self.handleAuthResult(result: result, completion: completion)
        }
    }
    
    @discardableResult
    public func deanonymizeUser(completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task {
        // TODO: Update if needed
        send(CheckIfSignedIn()) { result in
            switch result {
            case .success(let emptyResponce):
                completion(.success(emptyResponce))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func resetPassword(email: String, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task  {
        // TODO: Test
        send(ResetPassword(email: email)) { result in
            switch result {
            case .success(let responce):
                completion(.success(responce))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func renewAccessToken(completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task  {
        send(RenewAccessToken()) { result in
            switch result {
            case .success(let responce):
                completion(.success(responce))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func logout(completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) -> Task  {
        send(LogOut()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.removeTokens()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - Private funcs
extension IdentifoManager {
    private func send<T: IdentifoRequest>(_ request: T, completionHandler: @escaping (Result<T.IdentifoSuccess, Error>) -> Void) -> Task {
        let urlRequest = request.identifoRequest(in: context)
        
        return session.send(urlRequest) { response in
            do {
                if let error = response.error {
                    throw error
                }
                
                let data = response.data ?? Data()
                let meta = response.meta as? HTTPURLResponse
                
                guard let statusCode = meta?.statusCode, statusCode < 400 else {
                    let error = try T.IdentifoFailure(identifoBody: data, statusCode: meta?.statusCode ?? -1)
                    throw error
                }
                
                let networkResponse = try T.IdentifoSuccess(identifoBody: data)
                DispatchQueue.main.async {
                    completionHandler(.success(networkResponse))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    private func handleAuthResult(result: Result<AuthInfo, Error>, completion: @escaping (Result<IdentifoSuccess, Error>) -> Void) {
        switch result {
        case .success(let data):
            self.saveTokens(from: data)
            completion(.success(data))
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private func saveTokens(from info: AuthInfo) {
        self.context.accessToken = info.accessToken
        self.context.refreshToken = info.refreshToken
    }
    
    private func removeTokens() {
        self.context.accessToken = nil
        self.context.refreshToken = nil
    }
}
