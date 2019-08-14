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

public final class Manager {
    
    public var environment: Environment
    public var session: Session
    
    let mapper = Mapper()
    
    public init(environment: Environment, session: Session = URLSession(configuration: .ephemeral)) {
        self.environment = environment
        self.session = session
    }
    
    public func send<T: Request>(_ request: T, completionHandler: @escaping (Result<T.Response>) -> Void) {
        do {
            let urlRequest = try makeURLRequest(from: request)
            session.send(urlRequest) { response in
                do {
                    let result: T.Response = try self.mapper.entity(from: response)
                    completionHandler(.success(result))
                } catch let error {
                    completionHandler(.failure(error))
                }
            }
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    
}