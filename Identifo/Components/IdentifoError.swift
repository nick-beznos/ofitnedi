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

public enum IdentifoError: Error {
    
    case unauthorized
    case badGateway
    case notFound
    case timeout
    case cancelled
    
    case undefinedError(message: String)
    
    case unexpectedResponse(context: String)
    case undefinedMapper(context: String)
    case undefinedRequestFactory(context: String)
    
    init?(errorCode: Int) {
        switch errorCode {
        case 401:
            self = .unauthorized
        case 404:
            self = .notFound
        case 408:
            self = .timeout
        case 502:
            self = .badGateway
        default:
            return nil
        }
    }
    
    static func defaultContext(entity: Any.Type, file: String, line: Int) -> String {
        let file = (file as NSString).lastPathComponent
        return "\(entity) (\(file), line: \(line))"
    }
    
}

extension IdentifoError: Duality {
    
    init(_ dual: Data) throws {
        let json = try dual.entityJSON()

        let errorJSON = json["error"] as? [String: Any]
        
        guard let message = errorJSON?["detailed_message"] as? String else {
            throw IdentifoError.unexpectedResponse(context: IdentifoError.defaultContext(entity: type(of: self), file: #file, line: #line))
        }
        
        self = .undefinedError(message: message)
    }
    
    func dual() throws -> Data {
        throw IdentifoError.undefinedMapper(context: IdentifoError.defaultContext(entity: type(of: self), file: #file, line: #line))
    }
    
}
