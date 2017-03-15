//
//  FinalViewController.swift
//  Smoothy
//
//  Created by MIKI on 2016/08/27.
//  Copyright © 2016年 HackUmeko. All rights reserved.
//

import UIKit
import AVFoundation

class FinalViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ingreLabel: UILabel!
    
    @IBOutlet var smImage: UIImageView!
    
    var name: String!
    var ingre: String!
    var sm : String!
    //var sm: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        ingreLabel.text = ingre
        print(sm)
        if sm == "g" {
            smImage.image = UIImage(named: "greenSm.png")
        } else if sm == "r"{
            smImage.image = UIImage(named: "pinkSm.png")
        } else if sm == "y"{
            smImage.image = UIImage(named: "yellowSm.png")
        } else {
            smImage.image = UIImage(named: "aoziru.png")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func topModoru() {
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
