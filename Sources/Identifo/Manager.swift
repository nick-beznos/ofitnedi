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
    
    public var context: Context
    public var session: Session
        
    public init(context: Context, session: Session = URLSession(configuration: .ephemeral)) {
        self.context = context
        self.session = session
    }
    
    @discardableResult
    public func send<T: IdentifoRequest>(_ request: T, completionHandler: @escaping (Result<T.IdentifoSuccess, Error>) -> Void) -> Task {
        let urlRequest = request.identifoRequest(in: context)
        
        return session.send(urlRequest) { response in
            do {
                if let error = response.error {
                    throw error
                }
                
                let data = response.data ?? Data()
                let meta = response.meta as? HTTPURLResponse
                
                guard let statusCode = meta?.statusCode, statusCode < 400 else {
                    let error = try T.IdentifoFailure(identifoBody: data, statusCode: meta?.statusCode ?? -1)
                    throw error
                }
                
                let networkResponse = try T.IdentifoSuccess(identifoBody: data)
                completionHandler(.success(networkResponse))
            } catch let error {
                completionHandler(.failure(error))
            }
        }
    }
}
