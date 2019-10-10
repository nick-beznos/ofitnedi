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
import CommonCrypto

extension Data {
    
    init(json: Any) throws {
        self = try JSONSerialization.data(withJSONObject: json, options: .sortedKeys)
    }
    
    func entityJSON() throws -> [String: Any] {
        let json = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        
        if let json = json as? [String: Any] {
            return json
        } else {
            throw IdentifoError.unexpectedResponse(entity: [String: Any].self, file: #file, line: #line)
        }
    }
    
}

extension Data {
    
    static func makeHMACUsingSHA256(key: String, data: Data) -> Data {
        let data = String(bytes: data, encoding: .utf8) ?? ""
        return makeHMACUsingSHA256(key: key, data: data)
    }
    
    static func makeHMACUsingSHA256(key: String, data: String) -> Data {
        var bytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, data, data.count, &bytes)
        
        return Data(bytes)
    }
    
}
