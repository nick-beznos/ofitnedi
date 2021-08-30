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

final class InitialVC: UIViewController {

    var identifo: IdentifoManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        let bundleURL = bundle.url(forResource: "app_config", withExtension: "json")!
        let data = try! Data(contentsOf: bundleURL)
        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        
        let apiURLString = json["api_url"] as! String
        let clientID = json["identifo_cliend_id"] as! String
        let secretKey = json["identifo_secret_key"] as! String
        
        let url = URL(string: apiURLString)!
        let context = Identifo.Context(apiURL: url, clientID: clientID, secretKey: secretKey)
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        
        identifo = .init(context: context, session: session)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = identifo.context.accessToken {
            performSegue(withIdentifier: "toProfileNC", sender: self)
        } else {
            performSegue(withIdentifier: "toIntroNC", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toIntroNC":
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! IntroVC
            
            controller.identifo = identifo
        case "toProfileNC":
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! ProfileVC
            
            controller.identifo = identifo
        default:
            break
        }
    }
    
    @IBAction func unwindToInitialVC(_ sender: UIStoryboardSegue) {
        
    }
    
}
