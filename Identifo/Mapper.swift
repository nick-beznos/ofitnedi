//
//  Identifo
//
//  Copyright (C) 2019 MadAppGang Pty Ltd.
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

final class Mapper {
    
    func data<T>(from entity: T) throws -> Data {
        guard let entity = entity as? Duality else {
            throw IdentifoError.undefinedMapper(context: IdentifoError.defaultContext(entity: T.self, file: #file, line: #line))
        }
        
        let data = try entity.dual()
        return data
    }
    
    func entity<T>(from data: Data) throws -> T {
        switch T.self {
        case is Void.Type:
            return () as! T
        case (let type as Duality.Type):
            let entity = try type.init(data) as! T
            return entity
        default:
            throw IdentifoError.undefinedMapper(context: IdentifoError.defaultContext(entity: T.self, file: #file, line: #line))
        }
    }
    
    func entity<T>(from response: Response) throws -> T {
        let data = try self.data(from: response)
        let entity: T = try self.entity(from: data)
        return entity
    }
    
    func empty(from response: Response) throws {
        _ = try self.data(from: response)
    }
    
}

extension Mapper {
    
    func data(from response: Response) throws -> Data {
        if let error = response.error {
            if (error as NSError).code == NSURLErrorCancelled {
                throw IdentifoError.cancelled
            } else {
                throw error
            }
        }
        
        guard let data = response.data, let meta = response.meta as? HTTPURLResponse else {
            throw IdentifoError.unexpectedResponse(context: IdentifoError.defaultContext(entity: Response.self, file: #file, line: #line))
        }
        
        if meta.statusCode < 400 {
            return data
        }
        
        if let error = try? entity(from: data) as IdentifoError {
            throw error
        } else if let error = IdentifoError(errorCode: meta.statusCode) {
            throw error
        } else {
            throw IdentifoError.unexpectedResponse(context: IdentifoError.defaultContext(entity: IdentifoError.self, file: #file, line: #line))
        }
    }
    
}
