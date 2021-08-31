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

struct LogOut {
}

extension LogOut: IdentifoRequest {
    
    public typealias IdentifoSuccess = EmptyIdentifoResponse
    public typealias IdentifoFailure = IdentifoError
    
    public func identifoURLPath(in context: Context) -> String {
        return "/auth/logout"
    }
    
    public func identifoMethod(in context: Context) -> String {
        return "POST"
    }
    
    public func identifoBody(in context: Context) -> Data? {
        var json: [String: Any] = [:]
        
        json["device_token"] = context.deviceToken
        json["refresh_token"] = context.refreshToken

        let data = try? Data(json: json)
        return data
    }
    
}
