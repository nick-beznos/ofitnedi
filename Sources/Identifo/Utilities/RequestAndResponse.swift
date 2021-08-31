//
//  IdentifoDemo
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

// MARK: IdentifoRequest

protocol IdentifoRequest {
    
    associatedtype IdentifoSuccess: Identifo.IdentifoSuccess
    associatedtype IdentifoFailure: Identifo.IdentifoFailure
    
    func identifoRequest(in context: Context) -> URLRequest
    
    func identifoURL(in context: Context) -> URL
    func identifoURLPath(in context: Context) -> String
    func identifoURLQuery(in context: Context) -> [String: String?]
    
    func identifoMethod(in context: Context) -> String
    func identifoHeaderFields(in context: Context) -> [String: String]
    func identifoBody(in context: Context) -> Data?
    
}

extension IdentifoRequest {
    
    public func identifoRequest(in context: Context) -> URLRequest {
        let url = identifoURL(in: context)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = identifoMethod(in: context)
        urlRequest.allHTTPHeaderFields = identifoHeaderFields(in: context)
        urlRequest.httpBody = identifoBody(in: context)
        
        return urlRequest
    }
    
    public func identifoURL(in context: Context) -> URL {
        let path = identifoURLPath(in: context)
        let query = identifoURLQuery(in: context)
        return context.apiURL(path: path, query: query)
    }
    
    public func identifoURLPath(in context: Context) -> String {
        return ""
    }
    
    public func identifoURLQuery(in context: Context) -> [String: String?] {
        return [:]
    }
    
    public func identifoMethod(in context: Context) -> String {
        return "GET"
    }
    
    public func identifoHeaderFields(in context: Context) -> [String: String] {
        var header: [String: String] = [:]
        
        header["X-Identifo-ClientID"] = context.clientID
        header["Content-Type"] = "application/json"
        
        let token: String?
        
        if self is RenewAccessToken {
            token = context.refreshToken
        } else {
            token = context.accessToken
        }
        
        if let token = token {
            header["Authorization"] = "Bearer \(token)"
        }
        
        let digest: Data
        
        switch self {
        case is CheckIfSignedIn, is RenewAccessToken:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let timestamp = formatter.string(from: Date())
            
            header["X-Identifo-Timestamp"] = timestamp
            
            let urlPath = identifoURLPath(in: context)
            let data = urlPath + timestamp
            digest = .makeHMACUsingSHA256(key: context.secretKey, data: data)
        default:
            let data = identifoBody(in: context) ?? "".data(using: .utf8)!
            digest = .makeHMACUsingSHA256(key: context.secretKey, data: data)
        }
        
        header["Digest"] = "SHA-256=" + digest.base64EncodedString()
        
        return header
    }
    
    public func identifoBody(in context: Context) -> Data? {
        return nil
    }
    
}

// MARK: IdentifoSuccess

public protocol IdentifoSuccess {
    
    init(identifoBody: Data) throws
    
}

// MARK: IdentifoFailure

public protocol IdentifoFailure: Error {
    
    init(identifoBody: Data, statusCode: Int) throws
    
}
