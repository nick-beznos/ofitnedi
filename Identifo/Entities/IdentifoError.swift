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

public struct IdentifoError: IdentifoFailure, LocalizedError {
    
    public var statusCode: Int
    
    public var message: String
    
    public var errorDescription: String? {
        return message
    }
    
    public init(message: String, statusCode: Int) {
        self.message = message
        self.statusCode = statusCode
    }
    
    public init(identifoBody: Data, statusCode: Int) throws {
        self.statusCode = statusCode
        
        let json = try identifoBody.entityJSON()
        
        if let description = json["detailed_message"] as? String {
            self.message = description
        } else if let string = String(data: identifoBody, encoding: .utf8) {
            self.message = string
        } else {
            self.message = "Unexpected Identifo error."
        }
    }
    
}

extension IdentifoError {
    
    public static func unexpectedResponse(entity: Any.Type, file: String, line: Int) -> IdentifoError {
        let file = (file as NSString).lastPathComponent
        let message = "Unexpected response for \(entity) (\(file), line: \(line))."
        return .init(message: message, statusCode: 8001)
    }
    
}
