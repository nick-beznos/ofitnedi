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

public struct ContinueWithPhoneVerification: Request {
    
    public typealias Response = AuthResponse
    
    public var phone: String
    public var verificationCode: String
    
    public init(phone: String, verificationCode: String) {
        self.phone = phone
        self.verificationCode = verificationCode
    }
    
}

extension ContinueWithPhoneVerification: Duality {
    
    init(_ dual: Data) throws {
        throw IdentifoError.undefinedMapper(context: IdentifoError.defaultContext(entity: type(of: self), file: #file, line: #line))
    }
    
    func dual() throws -> Data {
        var json: [String: Any] = [:]
        
        json["phone_number"] = phone
        json["code"] = verificationCode
        json["scopes"] = ["offline"]

        let data = try Data(entityJSON: json)
        return data
    }
    
}
