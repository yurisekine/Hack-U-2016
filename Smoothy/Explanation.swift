//
//  Explanation.swift
//  Smoothy
//
//  Created by Himawari on 2016/09/09.
//  Copyright © 2016年 HackUmeko. All rights reserved.
//

import UIKit
import AVFoundation

//@IBOutlet var nameLabel: UILabel!

class Explanation: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func modoru() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
