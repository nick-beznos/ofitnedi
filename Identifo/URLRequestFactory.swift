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

extension Manager {
    
    func makeURLRequest(from request: AnyRequest) throws -> URLRequest {
        let url = try makeURL(for: request)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = makeHTTPMethod(for: type(of: request))
        urlRequest.allHTTPHeaderFields = try makeHTTPHeaderFields(for: request)
        urlRequest.httpBody = try mapper.data(from: request)
        
        return urlRequest
    }
    
}

extension Manager {
    
    private func makeURL(for request: AnyRequest) throws -> URL {
        let path = try makePath(for: request)
        return environment.apiURL(path: path, query: [:])
    }
    
    private func makePath(for request: AnyRequest) throws -> String {
        switch request {
        case is SignInWithUsername:
            return "/auth/login"
        case is SignUpWithUsername:
            return "/auth/register"
        case is ContinueWithPhone:
            return "/auth/request_phone_code"
        case is ContinueWithPhoneVerification:
            return "/auth/phone_login"
        case is CheckIfSignedIn:
            return "/me"
        case is RenewAccessToken:
            return "/auth/token"
        case is SignOut:
            return "/me/logout"
        default:
            throw IdentifoError.undefinedRequestFactory(context: IdentifoError.defaultContext(entity: type(of: request), file: #file, line: #line))
        }
    }
    
}

extension Manager {
    
    private func makeHTTPHeaderFields(for request: AnyRequest) throws -> [String: String] {
        var header: [String: String] = [:]
        
        header["X-Identifo-ClientID"] = environment.clientID
        header["Content-Type"] = makeContentType(for: type(of: request))

        let token: String?
        
        if request is RenewAccessToken {
            token = environment.refreshToken
        } else {
            token = environment.accessToken
        }
        
        if let token = token {
            header["Authorization"] = "Bearer \(token)"
        }
        
        let digest: Data
        
        switch request {
        case is CheckIfSignedIn, is RenewAccessToken:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let timestamp = formatter.string(from: Date())
            
            header["X-Identifo-Timestamp"] = timestamp

            let urlPath = try makePath(for: request)
            let data = urlPath + timestamp
            digest = .makeHMACUsingSHA256(key: environment.secretKey, data: data)
        default:
            let data = try mapper.data(from: request)
            digest = .makeHMACUsingSHA256(key: environment.secretKey, data: data)
        }

        header["Digest"] = "SHA-256=" + digest.base64EncodedString()
        
        return header
    }

    private func makeContentType(for requestType: AnyRequest.Type) -> String {
        switch requestType {
        default:
            return "application/json"
        }
    }
    
    private func makeHTTPMethod(for requestType: AnyRequest.Type) -> String {
        switch requestType {
        case is CheckIfSignedIn.Type:
            return "GET"
        default:
            return "POST"
        }
    }
    
}
