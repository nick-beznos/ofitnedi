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

import UIKit
import Identifo

final class ProfileVC: UIViewController, AlertableViewController {

    @IBOutlet private var signOutButton: UIButton!
    
    var identifo: Identifo.Manager!
    
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
    
    @IBAction private func signOutButtonButtonPressed(_ sender: UIButton) {
        let request = SignOut(deviceToken: identifo.environment.deviceToken, refreshToken: identifo.environment.refreshToken)
        
        identifo.send(request) { result in
            do {
                try result.get()
                self.identifo.environment.accessToken = nil
                self.identifo.environment.refreshToken = nil
                
                self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            } catch let error {
                self.showErrorMessage(error)
            }
        }
    }

}
