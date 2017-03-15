//
//  ViewController.swift
//  Smoothy
//
//  Created by MIKI on 2016/08/27.
//  Copyright © 2016年 HackUmeko. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var players: [AVAudioPlayer]!
    //音楽が入っている配列
    let audioFiles = ["decision"]
    
    @IBAction func tapStart(){
        play(0)
    }
    
    @IBAction func tapSetumei(){
        play(0)
    }
    
    
    func play(n:Int){
        if n < players.count {
            players[n].play()
        }
    }
    
    func setup(){
        players = []
        for fname in audioFiles {
            let path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fname, ofType: "mp3")!)
            do {
                let player = try AVAudioPlayer(contentsOfURL:path)
                players.append(player)
            } catch let error as NSError {
                print("error has occurred: \(error)")
            }
        }
    }
    //最初の画面が表示されるたびに呼ばれる
    override func viewWillAppear(animated: Bool) {
        appDelegate.audioPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view, typically from a nib.
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

