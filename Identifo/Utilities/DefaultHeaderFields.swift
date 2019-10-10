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

public protocol DefaultHeaderFields {
    func identifoHeaderFields(in context: Context) -> [String: String]
}

extension DefaultHeaderFields where Self: IdentifoRequest {
    
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
    
}
