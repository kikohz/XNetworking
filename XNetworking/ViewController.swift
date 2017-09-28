//
//  ViewController.swift
//  XNetworking
//
//  Created by wangxi1-ps on 2017/9/13.
//  Copyright © 2017年 x. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startTest(_ sender: Any) {
        let api = TestApi.init()
        api.startWithCompletionBlock { (response) in
            if response.error != nil {
                self.textView.text = response.error?.localizedDescription
                return
            }
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                self.textView.text = "Data: \(String(describing: response.result.value))"
            }
        }
        
    }
    
}

