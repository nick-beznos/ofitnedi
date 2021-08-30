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

import UIKit
import Identifo

final class VerificationCodeInputVC: UIViewController, AlertableViewController {

    @IBOutlet private var verificationCodeField: UITextField!
    @IBOutlet private var continueButton: UIButton!
    
    var identifo: Identifo.Manager!
    var phone: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "unwindToInitialVC":
            let controller = segue.destination as! InitialVC
            controller.identifo = identifo
        default:
            break
        }
    }
    
    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        let verificationCode = verificationCodeField.text ?? ""

        let request = ContinueWithPhoneVerification(phone: phone, verificationCode: verificationCode)
        
        identifo.send(request) { result in
            do {
                let entity = try result.get()
                self.identifo.context.accessToken = entity.accessToken
                self.identifo.context.refreshToken = entity.refreshToken

                self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            } catch let error {
                self.showErrorMessage(error)
            }
        }
    }

}
