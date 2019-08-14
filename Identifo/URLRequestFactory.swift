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
        var path = ""
        
        switch request {
        case is SignInWithUsername:
            path = "/auth/login"
        case is SignUpWithUsername:
            path = "/auth/register"
        case is ContinueWithPhone:
            path = "/auth/request_phone_code"
        case is ContinueWithPhoneVerification:
            path = "/auth/phone_login"
        case is SignOut:
            path = "/me/logout"
        default:
            throw IdentifoError.undefinedRequestFactory(context: IdentifoError.defaultContext(entity: type(of: request), file: #file, line: #line))
        }
        
        return environment.apiURL(path: path, query: [:])
    }
    
}

extension Manager {
    
    private func makeHTTPHeaderFields(for request: AnyRequest) throws -> [String: String] {
        var header: [String: String] = [:]

        header["Content-Type"] = makeContentType(for: type(of: request))

        switch request {
        case is SignOut:
            if let token = environment.accessToken {
                header["Authorization"] = "Bearer \(token)"
            }

            fallthrough
        default:
            let data = try mapper.data(from: request)
            let digest = Data.makeHMACUsingSHA256(key: environment.secretKey, data: data)

            header["Digest"] = "SHA-256=" + digest.base64EncodedString()
            header["X-Identifo-ClientID"] = environment.clientID
        }
        
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
        default:
            return "POST"
        }
    }
    
}
