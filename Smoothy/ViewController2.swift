//
//  ViewController2.swift
//  Smoothy
//
//  Created by MIKI on 2016/08/27.
//  Copyright © 2016年 HackUmeko. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController2: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var iconCollection: [UIImageView]!
    //季節   0-3　spring,summer,fall,winter
    //味　   4-7　sweet,bitter,fresh,mild
    //気分  8-11　happy,unhappy,tired,nervous
    //効能 12-15　diet,beauty,eye,heart
    
    //アイコンのXY
    @IBOutlet var xCollection: [NSLayoutConstraint]!
    @IBOutlet var yCollection: [NSLayoutConstraint]!
    
    
    @IBOutlet var checkLabel: UILabel!
    @IBOutlet var shakeLabel: UILabel!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var topImage: UIImageView!
    @IBOutlet var pahuImage: UIImageView!
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var topImage2: UIImageView!
    
    //スムージー候補が見つからない場合は味で提案するスムージーを変更する
    let multiSmoothie1 : String = "いちごのスムージー"//甘い
    let multiSmoothie2 : String = "青汁"//苦い
    let multiSmoothie3 : String = "野菜とグレープフルーツのスムージー"//さっぱり
    let multiSmoothie4 : String = "小松菜のまろやかスムージー"//まろやか
    
    //材料をいれておく配列
    var ingredients :[String] = []
    
    //シェイクした回数を数える変数
    var shake = 0
    var players:[AVAudioPlayer]!
    //音楽が入っている配列
    let audioFiles = ["mix","close","in","out"]
    
    //蓋閉めたか
    var top = false
    
    //ミキサーに入ったかどうかを確認する配列
    var want:[Bool]=[false,false,false,false, false,false,false,false, false,false,false,false, false,false,false,false]
    
    
    //checkメソッドで使った変数
    var isIn = false
    //iconCheckメソッドで使った変数
    var iconisIn = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //オープニングの曲を止める
        appDelegate.audioPlayer.stop()
        appDelegate.audioPlayer.currentTime = 0.0
        
        
        //初期状態で季節アイコン以外を非表示にする
        for i in 4...15 {
            iconCollection[i].hidden = true
        }
        pahuImage.hidden = true
        topImage2.hidden = true
        
        
        //音楽のセットアップ
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pan1(sender: UIPanGestureRecognizer) {
        
        //移動量を取得する。
        let move:CGPoint = sender.translationInView(view)
        
        let i = sender.view!.tag
        
        //ラベルの位置の制約に移動量を加算する。
        xCollection[i].constant += move.x
        yCollection[i].constant += move.y
        
        //画面表示を更新する。
        view.layoutIfNeeded()
        
        let x =  (sender.view!.center.x)
        let y =  (sender.view!.center.y)
        
        if(check(x,y:y) == true){
            print("In")
            want[i] = true
            play(2)
        }else{
            print("Out")
            want[i] = false
        }
        
        //移動量を0にする。
        sender.setTranslation(CGPointZero, inView:view)
        
        checkArray(want)
        
    }
    
    //ミキサーに物が入ったか判別するメソッド
    func check(x:CGFloat,y:CGFloat) -> Bool{
        if((x >= 45 && x <= 190) && (y >= 240 && y <= 420)){
            isIn = true
        }else{
            isIn = false
        }
        return isIn
    }
    
    
    //配列の要素が16こtrueだったら
    func checkArray(fruit:[Bool]){
        
        var flag = true
        for i in 0 ..< 16 {
            if(fruit[i] == false){
                flag = false
            }
        }
        
        if(flag == true){
            NSLog("全部入ったんよ")
            checkLabel.text = "ふたをタップしてください！"
            print(fruit)
        }else{
            checkLabel.text = "ふたをタップしてスマホを振ってね！！"
            print(fruit)
        }
        
    }
    
    //振って次の画面に行く
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if(top == true){
            //蓋が閉まっているとき、振っている回数をカウント
            if (event?.subtype == UIEventSubtype.MotionShake && event?.type == UIEventType.Motion){
                play(0)
                shake = shake + 1
                print(shake)
                shakeLabel.text = "shake shake!!"
                //バイブ
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            if(shake >= 4){
                
                self.performSegueWithIdentifier("next", sender: self)
                
                // prepareForSegue(UIStoryboardSegue, sender: nil)
                
                print("次の画面にいきまーす")
                players[0].stop()
                
            }
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        players[0].stop()
        var finalViewController = segue.destinationViewController as! FinalViewController
        if segue.identifier == "next" && top == true{
            print(ingredients[0])
            finalViewController.name = ingredients[0]
            finalViewController.ingre = ingredients[1]
            finalViewController.sm = ingredients[2]
        }else if segue.identifier == "next" && top != true{
            ingredients = getIngredients(multiSmoothie2)
            finalViewController.name = ingredients[0]
            finalViewController.ingre = ingredients[1]
            finalViewController.sm = ingredients[2]
        }
    }
    
    //音楽を流すメソッド
    func play(n:Int) {
        if n < players.count {
            players[n].play()
        }
    }
    //音楽のセットアップ
    func setup() {
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
    
    
    //アイコンがラベル以外の場所にあるか判別する
    func iconCheck(x:CGFloat,y:CGFloat)-> Bool {
        if((x >= 0 && x <= 375) && (y >= 0 && y <= 85)) {
            iconisIn = true         //ラベルに入っている->非表示にする
        } else {
            iconisIn = false        //ラベルに入っていない->表示する
        }
        return iconisIn
    }
    
    
    
    @IBAction func tabButton(sender: UIButton) {
        
        for i in 0...15 {
            let x =  (iconCollection[i].center.x)
            let y =  (iconCollection[i].center.y)
            iconCheck(x, y: y)
            if iconisIn == true {
                iconCollection[i].hidden = true
            }
            for j in sender.tag...sender.tag+3 {
                iconCollection[j].hidden = false
            }
        }
        
        if sender.tag == 0 {
            iconLabel.backgroundColor = UIColor(red: 214/255.0, green: 196/255.0, blue: 177/255.0, alpha: 1.0)
            
        } else if sender.tag == 4 {
            iconLabel.backgroundColor = UIColor(red: 201/255.0, green: 177/255.0, blue: 151/255.0, alpha: 1.0)
        } else if sender.tag == 8 {
            iconLabel.backgroundColor = UIColor(red: 187/255.0, green: 157/255.0, blue: 125/255.0, alpha: 1.0)
        } else if sender.tag == 12 {
            iconLabel.backgroundColor = UIColor(red: 140/255.0, green: 118/255.0, blue: 94/255.0, alpha: 1.0)
        } else {
            
        }
        
        
    }
    
    @IBAction func topOpen(){
        pahuImage.hidden = true
        topImage.hidden = false
        topImage2.hidden = true
        top = false
        checkLabel.text = "ふたをタップしてスマホを振ってね"
    }
    
    
    //蓋をしめた時のメソッド
    @IBAction func topClose(){
        pahuImage.hidden = false
        topImage.hidden = true
        topImage2.hidden = false
        top = true
        checkLabel.text = "変更したいときはふたをタップしてね"
        
        //求めているスムージーの特徴からスムージーを探す
        let sm = searchSmoothie(want)
        print("want:"+sm)
        //var ingredients :[String] = []
        if sm != "" {
            //もしスムージーが存在するならば材料を表示
            ingredients = getIngredients(sm)
        }else{//スムージーが見つからないならば、あらかじめ用意したものを表示する
            if want[4] == true {
                print(multiSmoothie1)
                print(getIngredients(multiSmoothie1))
                ingredients = getIngredients(multiSmoothie1)
            }else if want[6] == true {
                print(multiSmoothie3)
                print(getIngredients(multiSmoothie3))
                ingredients = getIngredients(multiSmoothie3)
            }else if want[7] == true {
                print(multiSmoothie4)
                print(getIngredients(multiSmoothie4))
                ingredients = getIngredients(multiSmoothie4)
            }else{//どれにも当てはまらないならばもれなく青汁を表示する
                print(multiSmoothie2)
                print(getIngredients(multiSmoothie2))
                ingredients = getIngredients(multiSmoothie2)
            }
        }
        
    }
    
    func searchSmoothie(want: [Bool]) -> String {
        
        //スムージーの特徴の登録
        //[0スムージー名,1春,2夏,3秋,4冬、5甘、6苦、7さっぱり、8まろやか、9喜、10悲、11疲、12緊張、13ダイエット効果、14美肌効果、15目にいい、16疲労回復]
        
        //グレープフルーツとパイナップルのスムージー：夏さっぱり疲れ疲労
        let smoothie1 : [Any] = ["グレープフルーツとパイナップルのスムージー",
                                 false,true,false,false,
                                 false,false,true,false,
                                 false,false,false,true,
                                 false,false,false,true]
        //ぶどうとみかんのスムージー：夏秋甘さっぱり疲れダイエット美肌疲労
        let smoothie2 : [Any] = ["ぶどうとみかんのスムージー",
                                 false,true,true,false,
                                 true,false,true,false,
                                 false,false,false,true,
                                 true,true,false,true]
        //トマトとりんごのスムージー：春夏秋冬甘さっぱりまろやか疲れ緊張疲労
        let smoothie3 : [Any] = ["トマトとりんごのスムージー",
                                 true,true,true,true,
                                 true,false,true,true,
                                 false,false,true,true,
                                 false,false,false,true]
        //バナナと小松菜のスムージー:春夏秋冬甘苦まろやか疲れ緊張ダイエット美肌疲労
        let smoothie4 : [Any] = ["バナナと小松菜のスムージー",
                                 true,true,true,true,
                                 true,true,false,true,
                                 false,false,true,true,
                                 true,true,false,true]
        //さっぱりみかんスムージー：春夏秋冬さっぱり疲れ美肌疲労
        let smoothie5 : [Any] = ["さっぱりみかんスムージー",
                                 true,true,true,true,
                                 false,false,true,false,
                                 false,false,false,true,
                                 false,true,false,true]
        //まろやかみかんスムージー：春夏秋冬甘まろやか疲れ緊張疲労回復
        let smoothie6 : [Any] = ["まろやかみかんスムージー",
                                 true,true,true,true,
                                 true,false,false,true,
                                 false,false,true,true,
                                 false,false,false,true]
        //さっぱりレモンスムージー：夏さっぱり疲れ疲労回復
        let smoothie7 : [Any] = ["さっぱりレモンスムージー",
                                 false,false,true,false,
                                 false,false,true,false,
                                 false,false,false,false,
                                 false,false,false,true]
        //まろやかレモンスムージー：春夏秋冬甘まろやか疲れ緊張美肌疲労回復
        let smoothie8 : [Any] = ["まろやかレモンスムージー",
                                 true,true,true,true,
                                 true,false,false,true,
                                 false,false,true,true,
                                 false,true,false,true]
        //ルビーグレープフルーツスムージー：夏さっぱり疲れ疲労
        let smoothie9 : [Any] = ["ルビーグレープフルーツスムージー",
                                 false,true,false,false,
                                 false,false,true,false,
                                 false,false,false,true,
                                 false,false,false,true]
        //グレープフルーツスムージー：夏さっぱり疲れ美肌疲労
        let smoothie10 : [Any] = ["グレープフルーツスムージー",
                                  false,true,false,false,
                                  false,false,true,false,
                                  false,false,false,true,
                                  false,true,false,true]
        //さっぱりキウイスムージー：春夏秋冬さっぱりダイエット
        let smoothie11 : [Any] = ["さっぱりキウイスムージー",
                                  true,true,true,true,
                                  false,false,true,false,
                                  false,false,false,false,
                                  true,false,false,false]
        //まろやかキウイスムージー：春夏秋冬甘いまろやか緊張ダイエット美肌
        let smoothie12 : [Any] = ["まろやかキウイスムージー",
                                  true,true,true,true,
                                  true,false,false,true,
                                  false,false,true,false,
                                  true,true,false,false]
        //ゴールドキウイといちごのスムージー：春夏秋冬さっぱりダイエット
        let smoothie13 : [Any] = ["ゴールドキウイといちごのスムージー",
                                  true,true,true,true,
                                  false,false,true,false,
                                  false,false,false,false,
                                  true,false,false,false]
        //まろやかゴールドキウイスムージー：春夏秋冬まろやかダイエット
        let smoothie14 : [Any] = ["まろやかゴールドキウイスムージー",
                                  true,true,true,true,
                                  false,false,false,true,
                                  false,false,false,false,
                                  true,false,false,false]
        //ブルーベリーとオレンジのスムージー：夏秋甘いさっぱり疲れダイエット美肌目
        let smoothie15 : [Any] = ["ブルーベリーとオレンジのスムージー",
                                  false,true,true,false,
                                  true,false,true,false,
                                  false,false,false,true,
                                  true,true,true,false]
        //ブルーベリーとマンゴーのスムージー：夏秋甘いまろやか疲れ緊張ダイエット目疲労
        let smoothie16 : [Any] = ["ブルーベリーとマンゴーのスムージー",
                                  false,true,true,false,
                                  true,false,false,true,
                                  false,false,true,true,
                                  true,false,true,true]
        //かぼちゃのホットスムージースープ：秋冬甘いまろやか喜び悲しい緊張
        let smoothie17 : [Any] = ["かぼちゃのホットスムージースープ",
                                  false,false,true,true,
                                  true,false,false,true,
                                  true,true,true,false,
                                  false,false,false,false]
        //かぼちゃのスムージー：秋冬甘いまろやか喜び緊張疲労
        let smoothie18 : [Any] = ["かぼちゃのスムージー",
                                  false,false,true,true,
                                  true,false,false,true,
                                  true,false,false,true,
                                  false,false,false,true]
        //さつまいものホットスムージースープ：秋冬甘いまろやか喜び悲しい緊張
        let smoothie19 : [Any] = ["さつまいものホットスムージースープ",
                                  false,false,true,true,
                                  true,false,false,true,
                                  true,true,true,false,
                                  false,false,false,false]
        //さつまいものスムージー：秋冬甘いまろやか喜び疲れ緊張疲労
        let smoothie20 : [Any] = ["さつまいものスムージー",
                                  false,false,true,true,
                                  true,false,false,true,
                                  true,false,true,true,
                                  false,false,false,true]
        //しょうがのホットスムージー：冬甘い喜び悲しい疲れ
        let smoothie21 : [Any] = ["しょうがのホットスムージー",
                                  false,false,false,true,
                                  true,false,false,false,
                                  true,true,true,false,
                                  false,false,false,false]
        //しょうがのスムージー：冬甘い喜び疲れ
        let smoothie22 : [Any] = ["しょうがのスムージー",
                                  false,false,false,true,
                                  true,false,false,false,
                                  true,false,true,false,
                                  false,false,false,false]
        //さっぱりいちごスムージー：春夏秋冬甘いさっぱり美肌
        let smoothie23 : [Any] = ["さっぱりいちごスムージー",
                                  true,true,true,true,
                                  true,false,true,false,
                                  false,false,false,false,
                                  false,true,false,false]
        //まろやかいちごスムージー：春夏秋冬甘いまったり美肌目
        let smoothie24 : [Any] = ["まろやかいちごスムージー",
                                  true,true,true,true,
                                  true,false,false,true,
                                  false,false,false,false,
                                  false,true,true,false]
        //オレンジとパイナップルのスムージー：夏甘いさっぱり疲れ美肌疲労
        let smoothie25 : [Any] = ["オレンジとパイナップルのスムージー",
                                  false,true,false,false,
                                  true,false,true,false,
                                  false,false,false,true,
                                  false,true,false,true]
        //オレンジとチンゲンサイのスムージー：夏甘いまろやか疲れ緊張疲労
        let smoothie26 : [Any] = ["オレンジとチンゲンサイのスムージー",
                                  false,true,false,false,
                                  true,false,false,true,
                                  false,false,true,true,
                                  false,false,false,true]
        //キャベツとキウイのスムージー：春夏秋冬甘いさっぱりダイエット美肌
        let smoothie27 : [Any] = ["キャベツとキウイのスムージー",
                                  true,true,true,true,
                                  true,false,true,false,
                                  false,false,false,false,
                                  true,true,false,false]
        //キャベツとパイナップルのスムージー；春夏秋冬甘いさっぱり疲れ美肌疲労回復
        let smoothie28 : [Any] = ["キャベツとパイナップルのスムージー",
                                  true,true,true,true,
                                  true,false,true,false,
                                  false,false,true,false,
                                  false,true,false,true]
        //さっぱり赤パプリカスムージー：春夏秋冬さっぱり疲れ美肌疲労
        let smoothie29 : [Any] = ["さっぱり赤パプリカスムージー",
                                  true,true,true,true,
                                  false,false,true,false,
                                  false,false,true,false,
                                  false,true,false,true]
        //まろやか赤パプリカスムージー：春夏秋冬まろやか疲れ美肌疲労
        let smoothie30 : [Any] = ["まろやか赤パプリカスムージー",
                                  true,true,true,true,
                                  false,false,false,true,
                                  false,false,true,true,
                                  false,true,false,true]
        //さっぱりアボカドスムージー：春夏秋冬さっぱり疲れ美肌疲労
        let smoothie31 : [Any] = ["さっぱりアボカドスムージー",
                                  true,true,true,true,
                                  false,false,true,false,
                                  false,false,true,false,
                                  false,true,false,true]
        //まろやかアボカドスムージー：春夏秋冬まろやか疲れ美肌疲労
        let smoothie32 : [Any] = ["まろやかアボカドスムージー",
                                  true,true,true,true,
                                  false,false,true,false,
                                  false,false,true,false,
                                  false,true,false,true]
        //水菜とりんごのスムージー：春夏秋冬苦いさっぱり疲れ美肌疲労
        let smoothie33 : [Any] = ["水菜とりんごのスムージー",
                                  true,true,true,true,
                                  false,true,true,false,
                                  false,false,true,false,
                                  false,true,false,true]
        //水菜とみかんのスムージー：春夏秋冬苦いまろやか疲れ美肌疲労
        let smoothie34 : [Any] = ["水菜とみかんのスムージー",
                                  true,true,true,true,
                                  false,true,false,true,
                                  false,false,true,false,
                                  false,true,false,true]
        //さっぱりメロンスムージー：夏甘いさっぱりダイエット美肌
        let smoothie35 : [Any] = ["さっぱりメロンスムージー",
                                  false,true,false,false,
                                  true,false,true,false,
                                  false,false,false,false,
                                  true,false,false,false]
        //まろやかメロンスムージー：夏甘いまろやか美肌
        let smoothie36 : [Any] = ["まろやかメロンスムージー",
                                  false,true,false,false,
                                  true,false,false,true,
                                  false,false,false,false,
                                  false,true,false,false]
        //さっぱりバナナスムージー：春夏秋冬甘いさっぱり疲れ美肌疲労
        let smoothie37 : [Any] = ["さっぱりバナナスムージー",
                                  true,true,true,true,
                                  true,false,true,false,
                                  false,false,true,false,
                                  false,true,false,true]
        //まろやかバナナスムージー：春夏秋冬甘いまろやか疲れ緊張美肌疲労
        let smoothie38 : [Any] = ["まろやかバナナスムージー",
                                  true,true,true,true,
                                  true,false,true,false,
                                  false,false,true,true,
                                  false,true,false,true]
        //さっぱりすいかのスムージー：夏甘いさっぱり美肌
        let smoothie39 : [Any] = ["さっぱりすいかのスムージー",
                                  false,true,false,false,
                                  true,false,true,false,
                                  false,false,false,false,
                                  false,true,false,false]
        //まろやかすいかのスムージー：夏甘いまろやか疲れ美肌疲労
        let smoothie40 : [Any] = ["まろやかすいかのスムージー",
                                  false,true,false,false,
                                  true,false,false,true,
                                  false,false,true,false,
                                  false,true,false,true]
        //サラダほうれんそうのスムージー：春夏秋冬苦いまろやか疲れ疲労
        let smoothie41 : [Any] = ["サラダほうれんそうのスムージー",
                                  true,true,true,true,
                                  false,true,false,true,
                                  false,false,true,false,
                                  false,false,false,true]
        
        var smoothie : [String] = []//スムージーの候補を保持しておく配列
        
        //完全一致したらそのまま返す
        //部分一致したら候補にいれる
        if getSmoothie(smoothie1, want: want)==0 {
            return smoothie1[0] as! String
        } else if getSmoothie(smoothie1, want: want)==1 {
            smoothie.append(smoothie1[0] as! String)
        }
        if getSmoothie(smoothie2, want: want)==0 {
            return smoothie2[0] as! String
        } else if getSmoothie(smoothie2, want: want)==1 {
            smoothie.append(smoothie2[0] as! String)
        }
        if getSmoothie(smoothie3, want: want)==0 {
            return smoothie3[0] as! String
        } else if getSmoothie(smoothie3, want: want)==1 {
            smoothie.append(smoothie3[0] as! String)
        }
        if getSmoothie(smoothie4, want: want)==0 {
            return smoothie4[0] as! String
        } else if getSmoothie(smoothie4, want: want)==1 {
            smoothie.append(smoothie4[0] as! String)
        }
        if getSmoothie(smoothie5, want: want)==0 {
            return smoothie5[0] as! String
        } else if getSmoothie(smoothie5, want: want)==1 {
            smoothie.append(smoothie5[0] as! String)
        }
        if getSmoothie(smoothie6, want: want)==0 {
            return smoothie6[0] as! String
        } else if getSmoothie(smoothie6, want: want)==1 {
            smoothie.append(smoothie6[0] as! String)
        }
        if getSmoothie(smoothie7, want: want)==0 {
            return smoothie7[0] as! String
        } else if getSmoothie(smoothie7, want: want)==1 {
            smoothie.append(smoothie7[0] as! String)
        }
        if getSmoothie(smoothie8, want: want)==0 {
            return smoothie8[0] as! String
        } else if getSmoothie(smoothie8, want: want)==1 {
            smoothie.append(smoothie8[0] as! String)
        }
        if getSmoothie(smoothie9, want: want)==0 {
            return smoothie9[0] as! String
        } else if getSmoothie(smoothie9, want: want)==1 {
            smoothie.append(smoothie9[0] as! String)
        }
        if getSmoothie(smoothie10, want: want)==0 {
            return smoothie10[0] as! String
        } else if getSmoothie(smoothie10, want: want)==1 {
            smoothie.append(smoothie10[0] as! String)
        }
        if getSmoothie(smoothie11, want: want)==0 {
            return smoothie11[0] as! String
        } else if getSmoothie(smoothie11, want: want)==1 {
            smoothie.append(smoothie11[0] as! String)
        }
        if getSmoothie(smoothie12, want: want)==0 {
            return smoothie12[0] as! String
        } else if getSmoothie(smoothie12, want: want)==1 {
            smoothie.append(smoothie12[0] as! String)
        }
        if getSmoothie(smoothie13, want: want)==0 {
            return smoothie13[0] as! String
        } else if getSmoothie(smoothie13, want: want)==1 {
            smoothie.append(smoothie13[0] as! String)
        }
        if getSmoothie(smoothie14, want: want)==0 {
            return smoothie14[0] as! String
        } else if getSmoothie(smoothie14, want: want)==1 {
            smoothie.append(smoothie14[0] as! String)
        }
        if getSmoothie(smoothie15, want: want)==0 {
            return smoothie15[0] as! String
        } else if getSmoothie(smoothie15, want: want)==1 {
            smoothie.append(smoothie15[0] as! String)
        }
        if getSmoothie(smoothie16, want: want)==0 {
            return smoothie16[0] as! String
        } else if getSmoothie(smoothie16, want: want)==1 {
            smoothie.append(smoothie16[0] as! String)
        }
        if getSmoothie(smoothie17, want: want)==0 {
            return smoothie17[0] as! String
        } else if getSmoothie(smoothie17, want: want)==1 {
            smoothie.append(smoothie17[0] as! String)
        }
        if getSmoothie(smoothie18, want: want)==0 {
            return smoothie18[0] as! String
        } else if getSmoothie(smoothie18, want: want)==1 {
            smoothie.append(smoothie18[0] as! String)
        }
        if getSmoothie(smoothie19, want: want)==0 {
            return smoothie19[0] as! String
        } else if getSmoothie(smoothie19, want: want)==1 {
            smoothie.append(smoothie19[0] as! String)
        }
        if getSmoothie(smoothie20, want: want)==0 {
            return smoothie20[0] as! String
        } else if getSmoothie(smoothie20, want: want)==1 {
            smoothie.append(smoothie20[0] as! String)
        }
        if getSmoothie(smoothie21, want: want)==0 {
            return smoothie21[0] as! String
        } else if getSmoothie(smoothie21, want: want)==1 {
            smoothie.append(smoothie21[0] as! String)
        }
        if getSmoothie(smoothie22, want: want)==0 {
            return smoothie22[0] as! String
        } else if getSmoothie(smoothie22, want: want)==1 {
            smoothie.append(smoothie22[0] as! String)
        }
        if getSmoothie(smoothie23, want: want)==0 {
            return smoothie23[0] as! String
        } else if getSmoothie(smoothie23, want: want)==1 {
            smoothie.append(smoothie23[0] as! String)
        }
        if getSmoothie(smoothie24, want: want)==0 {
            return smoothie24[0] as! String
        } else if getSmoothie(smoothie24, want: want)==1 {
            smoothie.append(smoothie24[0] as! String)
        }
        if getSmoothie(smoothie25, want: want)==0 {
            return smoothie25[0] as! String
        } else if getSmoothie(smoothie25, want: want)==1 {
            smoothie.append(smoothie25[0] as! String)
        }
        if getSmoothie(smoothie26, want: want)==0 {
            return smoothie26[0] as! String
        } else if getSmoothie(smoothie26, want: want)==1 {
            smoothie.append(smoothie26[0] as! String)
        }
        if getSmoothie(smoothie27, want: want)==0 {
            return smoothie27[0] as! String
        } else if getSmoothie(smoothie27, want: want)==1 {
            smoothie.append(smoothie27[0] as! String)
        }
        if getSmoothie(smoothie28, want: want)==0 {
            return smoothie28[0] as! String
        } else if getSmoothie(smoothie28, want: want)==1 {
            smoothie.append(smoothie28[0] as! String)
        }
        if getSmoothie(smoothie29, want: want)==0 {
            return smoothie29[0] as! String
        } else if getSmoothie(smoothie29, want: want)==1 {
            smoothie.append(smoothie29[0] as! String)
        }
        if getSmoothie(smoothie30, want: want)==0 {
            return smoothie30[0] as! String
        } else if getSmoothie(smoothie30, want: want)==1 {
            smoothie.append(smoothie30[0] as! String)
        }
        if getSmoothie(smoothie31, want: want)==0 {
            return smoothie31[0] as! String
        } else if getSmoothie(smoothie31, want: want)==1 {
            smoothie.append(smoothie31[0] as! String)
        }
        if getSmoothie(smoothie32, want: want)==0 {
            return smoothie32[0] as! String
        } else if getSmoothie(smoothie32, want: want)==1 {
            smoothie.append(smoothie32[0] as! String)
        }
        if getSmoothie(smoothie33, want: want)==0 {
            return smoothie33[0] as! String
        } else if getSmoothie(smoothie33, want: want)==1 {
            smoothie.append(smoothie33[0] as! String)
        }
        if getSmoothie(smoothie34, want: want)==0 {
            return smoothie34[0] as! String
        } else if getSmoothie(smoothie34, want: want)==1 {
            smoothie.append(smoothie34[0] as! String)
        }
        if getSmoothie(smoothie35, want: want)==0 {
            return smoothie35[0] as! String
        } else if getSmoothie(smoothie35, want: want)==1 {
            smoothie.append(smoothie35[0] as! String)
        }
        if getSmoothie(smoothie36, want: want)==0 {
            return smoothie36[0] as! String
        } else if getSmoothie(smoothie36, want: want)==1 {
            smoothie.append(smoothie36[0] as! String)
        }
        if getSmoothie(smoothie37, want: want)==0 {
            return smoothie37[0] as! String
        } else if getSmoothie(smoothie37, want: want)==1 {
            smoothie.append(smoothie37[0] as! String)
        }
        if getSmoothie(smoothie38, want: want)==0 {
            return smoothie38[0] as! String
        } else if getSmoothie(smoothie38, want: want)==1 {
            smoothie.append(smoothie38[0] as! String)
        }
        if getSmoothie(smoothie39, want: want)==0 {
            return smoothie39[0] as! String
        } else if getSmoothie(smoothie39, want: want)==1 {
            smoothie.append(smoothie39[0] as! String)
        }
        if getSmoothie(smoothie40, want: want)==0 {
            return smoothie40[0] as! String
        } else if getSmoothie(smoothie40, want: want)==1 {
            smoothie.append(smoothie40[0] as! String)
        }
        if getSmoothie(smoothie41, want: want)==0 {
            return smoothie41[0] as! String
        } else if getSmoothie(smoothie41, want: want)==1 {
            smoothie.append(smoothie41[0] as! String)
        }
        
        //スムージー候補が複数の場合はランダムで一つ選んでそれを返す
        var rand : Int = 0
        if smoothie.count > 0 {
            rand = Int(arc4random_uniform(UInt32(smoothie.count)))
            //print("選ばれしものは"+smoothie[rand])
            return smoothie[rand]
        }
        
        //スムージー候補がない場合は空を返す
        return ""
        
    }
    //配列から検索をする
    //@return 0:完全一致　1:部分一致　2:一致しない
    func getSmoothie(smoothie : [Any], want : [Bool]) -> Int{
        var flg : Bool = true
        if allFalse(want) == true{
            return 2
        }else if matchSmoothie(smoothie, want: want) == true {
            return 0
        }else {
            for num in 0...15 {
                if want[num] == true {
                    if smoothie[num+1] as! Bool == false {
                        flg = false
                    }
                }
            }
            if flg == true {
                return 1
            }
        }
        return 2
    }
    
    //完全一致するかどうかを判定するメソッド
    //@return true:完全一致　false:完全一致しない
    func matchSmoothie(smoothie : [Any], want : [Bool]) ->Bool{
        for index in 1...smoothie.count-1{
            if smoothie[index] as! Bool != want[index-1] {
                return false
            }
        }
        return true
    }
    
    //全てがfalseかどうか
    //@return true:全てfalse false:falseではない
    func allFalse(want : [Bool]) ->Bool{
        for index in 0 ... want.count-1{
            if want[index] == true{
                return false
            }
        }
        return true;
    }
    
    //材料のはいった配列を渡す
    //材料がなければないと渡す
    func getIngredients(smooth : String) -> [String]{
        
        let multiSmoothie1 : [String] = ["いちごのスムージー",
                                         "いちご...5粒\nヨーグルト...大さじ3\n牛乳...120ml\n砂糖...小さじ2",
                                         "r"]
        let multiSmoothie2 : [String] = ["青汁",
                                         "小松菜...1株\nオリゴ糖...大さじ1\n酢...大さじ1",
                                         "s"]
        let multiSmoothie3 : [String] = ["野菜とグレープフルーツのスムージー",
                                         "にんじん...1/2本\nアボカド...1/2コ\nグレープフルーツ...1/2コ\nパイナップル...1/4コ\nレモン汁...小さじ1",
                                         "g"]
        let multiSmoothie4 : [String] = ["小松菜のまろやかスムージー",
                                         "小松菜...100g\nバナナ...1/2本\nレモン汁...小さじ1\n豆乳...400g\nはちみつ...大さじ1",
                                         "g"]
        
        //[スムージー名,ベース、バランス、水分、プラスα]
        let smoothie1 : [String] = ["グレープフルーツとパイナップルのスムージー",
                                    "グレープフルーツ...1/2コ\nパイナップル...100g\n水...1/4カップ\nはちみつ...小さじ2",
                                    "y"]
        let smoothie2 : [String] = ["ぶどうとみかんのスムージー",
                                    "ぶどう...(大)10粒\nみかん...1コ\nヨーグルトドリンク...1/4カップ\nレモン汁...小さじ1/2",
                                    "r"]
        let smoothie3 : [String] = ["トマトとりんごのスムージー",
                                    "トマト...1コ\nりんご...1/4コ\n水...1/4カップ\nレモン汁...小さじ1/2\nはちみつ...小さじ1",
                                    "r"]
        let smoothie4 : [String] = ["バナナと小松菜のスムージー",
                                    "バナナ...1本\n小松菜...1/6ワ\n牛乳...1/2カップ\nはちみつ...小さじ1",
                                    "g"]
        let smoothie5 : [String] = ["さっぱりみかんスムージー",
                                    "みかん...1コ\nミニトマト...8コ\nライム...1/4コ\n水...1/4カップ\nはちみつ...小さじ1",
                                    "r"]
        let smoothie6 : [String] = ["まろやかみかんスムージー",
                                    "みかん...1コ\nマンゴー...1/2コ\n黄パプリカ...1/4コ\n牛乳...1/4カップ\nはちみつ...小さじ1",
                                    "y"]
        let smoothie7 : [String] = ["さっぱりレモンスムージー",
                                    "レモン...1/2コ\nパイナップル...100g\nきゅうり...1/3本\n水...1/4カップ\nはちみつ...小さじ2",
                                    "g"]
        let smoothie8 : [String] = ["まろやかレモンスムージー",
                                    "レモン...1/2コ\nオレンジ...1コ\nバナナ...1/2本\n水...1/4カップ\nはちみつ...小さじ1",
                                    "y"]
        let smoothie9 : [String] = ["ルビーグレープフルーツスムージー",
                                    "ルビーグレープフルーツ...1/2コ\nりんご...1/4コ\n水...1/4カップ\nはちみつ...小さじ2",
                                    "r"]
        let smoothie10 : [String] = ["グレープフルーツスムージー",
                                     "グレープフルーツ...1/2コ\nサラダほうれんそう...1/2ワ\nヨーグルトドリンク...1/4カップ\nはちみつ...小さじ2",
                                     "g"]
        let smoothie11 : [String] = ["さっぱりキウイスムージー",
                                     "キウイ...1コ\nりんご...1/3コ\nヨーグルトドリンク...1/2カップ",
                                     "g"]
        let smoothie12 : [String] = ["まろやかキウイスムージー",
                                     "キウイ...1コ\nアボカド...1/4コ\nチンゲンサイ...1/4株\nヨーグルトドリンク...1/2カップ\nレモン汁...小さじ1/2\nはちみつ...小さじ1",
                                     "g"]
        let smoothie13 : [String] = ["ゴールドキウイといちごのスムージー",
                                     "ゴールドキウイ...1コ\nいちご...5コ\nヨーグルトドリンク...1/2カップ",
                                     "r"]
        let smoothie14 : [String] = ["まろやかゴールドキウイスムージー",
                                     "ゴールドキウイ...1コ\nセロリ...1/4本\nヨーグルトドリンク1/2カップ\nすりごま(白)...小さじ1\nはちみつ...小さじ1/2",
                                     "y"]
        let smoothie15 : [String] = ["ブルーベリーとオレンジのスムージー",
                                     "ブルーベリー...50g\nオレンジ...1コ\nセロリ...1/4本\nヨーグルトドリンク...1/2カップ\nレモン汁...小さじ1\nはちみつ...小さじ1",
                                     "r"]
        let smoothie16 : [String] = ["ブルーベリーとマンゴーのスムージー",
                                     "ブルーベリー...50g\nマンゴー...1コ\nヨーグルトドリンク...1.2カップ",
                                     "y"]
        let smoothie17 : [String] = ["かぼちゃのホットスムージースープ",
                                     "かぼちゃ...70g\nたまねぎ...1/8コ\n豆乳...1/2カップ\nコンソメ...小さじ1/2",
                                     "y"]
        let smoothie18 : [String] = ["かぼちゃのスムージー",
                                     "かぼちゃ...70g\nみかん...1コ\n水...1/4カップ\nローストアーモンド...3粒\nはちみつ小さじ1/2",
                                     "y"]
        let smoothie19 : [String] = ["さつまいものホットスムージースープ",
                                     "さつまいも...70g\n牛乳...3/4カップ\nコンソメ...小さじ2/3\n一味唐辛子...少々",
                                     "y"]
        let smoothie20 : [String] = ["さつまいものスムージー",
                                     "さつまいも...50g\nりんご...1/4コ\n水...1/2カップ\nきな粉...小さじ1\nはちみつ...小さじ1/2",
                                     "y"]
        let smoothie21 : [String] = ["しょうがのホットスムージー",
                                     "しょうが...1/4かけ\nみかん...1コ\n水...1/4カップ\nはちみつ...小さじ1",
                                     "y"]
        let smoothie22 : [String] = ["しょうがのスムージー",
                                     "しょうが...1/4かけ\nりんご...1/4コ\nにんじん...1/5本\n水...1/2カップ\nレモン汁...小さじ1\nはちみつ...小さじ1",
                                     "y"]
        let smoothie23 : [String] = ["さっぱりいちごスムージー",
                                     "いちご...7コ\nミニトマト...7コ\nヨーグルトドリンク...1/4カップ",
                                     "r"]
        let smoothie24 : [String] = ["まろやかいちごスムージー",
                                     "いちご...7コ\nブルーベリー...30g\n牛乳...1/4カップ",
                                     "r"]
        let smoothie25 : [String] = ["オレンジとパイナップルのスムージー",
                                     "オレンジ...1コ\nパイナップル...50g\nレモン...1/4コ\nヨーグルトドリンク...1/4カップ",
                                     "y"]
        let smoothie26 : [String] = ["オレンジとチンゲンサイのスムージー",
                                     "オレンジ...1コ\nチンゲンサイ...1/2株\n牛乳...1/4カップ\nレモン汁...小さじ1/2\nはちみつ...小さじ1",
                                     "g"]
        let smoothie27 : [String] = ["キャベツとキウイのスムージー",
                                     "キャベツ(中)...1枚\nキウイ...1コ\nヨーグルトドリンク...1/2カップ\nはちみつ...小さじ1",
                                     "g"]
        let smoothie28 : [String] = ["キャベツとパイナップルのスムージー",
                                     "キャベツ(中)...1枚\nパイナップル...100g\n牛乳...1/2カップ\nレモン汁...小さじ1\nはちみつ...小さじ2",
                                     "g"]
        let smoothie29 : [String] = ["さっぱり赤パプリカスムージー",
                                     "赤パプリカ...1/4コ\nルビーグレープフルーツ...1/2コ\nヨーグルトドリンク...1/4カップ\nはちみつ...小さじ2",
                                     "r"]
        let smoothie30 : [String] = ["まろやか赤パプリカスムージー",
                                     "赤パプリカ...1/4コ\nりんご...1/3コ\n牛乳...1/2カップ\nレモン汁...小さじ1\nはちみつ...小さじ2",
                                     "r"]
        let smoothie31 : [String] = ["さっぱりアボカドスムージー",
                                     "アボカド...1/2コ\nグレープフルーツ...1/2コ\nセロリ...1/4本\n水...1/2カップ\nはちみつ...大さじ1",
                                     "g"]
        let smoothie32 : [String] = ["まろやかアボカドスムージー",
                                     "アボカド...1/4コ\nパイナップル...100g\nヨーグルトドリンク...1/2カップ\nレモン汁...小さじ1/2\nはちみつ...小さじ1",
                                     "g"]
        let smoothie33 : [String] = ["水菜とりんごのスムージー",
                                     "水菜...1/6ワ\nりんご...1/3コ\n水...1/2カップ\n青じそ...2枚\nレモン汁...小さじ1\nはちみつ...小さじ2",
                                     "g"]
        let smoothie34 : [String] = ["水菜とみかんのスムージー",
                                     "水菜...1/6ワ\nみかん...1コ\nヨーグルトドリンク...1/2カップ\nレモン汁...小さじ1/2\nはちみつ...小さじ1",
                                     "g"]
        let smoothie35 : [String] = ["さっぱりメロンスムージー",
                                     "メロン...100g\nゴールドキウイ...1コ\n水...1/4カップ\nはちみつ...小さじ1",
                                     "y"]
        let smoothie36 : [String] = ["まろやかメロンスムージー",
                                     "メロン...100g\nチンゲンサイ...1/4株\nヨーグルトドリンク...カップ1/4\nレモン汁...小さじ1/2\nはちみつ...小さじ1/2",
                                     "g"]
        let smoothie37 : [String] = ["さっぱりバナナスムージー",
                                     "バナナ...1本\nルビーグレープフルーツ...1/4コ\n水...1/4カップ\nしょうが...1/4かけ\nはちみつ...小さじ1",
                                     "y"]
        let smoothie38 : [String] = ["まろやかバナナスムージー",
                                     "バナナ...1本\nミニトマト...8コ\n水...1/4カップ\nレモン汁...小さじ1\nはちみつ...小さじ1",
                                     "r"]
        let smoothie39 : [String] = ["さっぱりすいかのスムージー",
                                     "すいか...100g\nいちご...5コ\n水...1/4カップ\nはちみつ...小さじ1",
                                     "r"]
        let smoothie40 : [String] = ["まろやかすいかのスムージー",
                                     "すいか...100g\nバナナ...1/2本\n豆乳...1/4カップ\nローストアーモンド...3粒",
                                     "r"]
        let smoothie41 : [String] = ["サラダほうれんそうのスムージー",
                                     "サラダほうれんそう...1/4ワ\nバナナ...1本\n豆乳...1/2カップ\nはちみつ...小さじ1",
                                     "g"]
        
        var sm : [String] = ["レシピが存在しません"]
        
        if smooth == multiSmoothie1[0]{
            sm = multiSmoothie1;
        }else if smooth == multiSmoothie2[0]{
            sm = multiSmoothie2;
        }else if smooth == multiSmoothie3[0]{
            sm = multiSmoothie3;
        }else if smooth == multiSmoothie4[0]{
            sm = multiSmoothie4;
        }else if smooth == smoothie1[0]{
            sm = smoothie1;
        }else if smooth == smoothie2[0]{
            sm = smoothie2;
        }else if smooth == smoothie3[0]{
            sm = smoothie3;
        }else if smooth == smoothie4[0]{
            sm = smoothie4;
        }else if smooth == smoothie5[0]{
            sm = smoothie5;
        }else if smooth == smoothie6[0]{
            sm = smoothie6;
        }else if smooth == smoothie7[0]{
            sm = smoothie7;
        }else if smooth == smoothie8[0]{
            sm = smoothie8;
        }else if smooth == smoothie9[0]{
            sm = smoothie9;
        }else if smooth == smoothie10[0]{
            sm = smoothie10;
        }else if smooth == smoothie11[0]{
            sm = smoothie11;
        }else if smooth == smoothie12[0]{
            sm = smoothie12;
        }else if smooth == smoothie13[0]{
            sm = smoothie13;
        }else if smooth == smoothie14[0]{
            sm = smoothie14;
        }else if smooth == smoothie15[0]{
            sm = smoothie15;
        }else if smooth == smoothie16[0]{
            sm = smoothie16;
        }else if smooth == smoothie17[0]{
            sm = smoothie17;
        }else if smooth == smoothie18[0]{
            sm = smoothie18;
        }else if smooth == smoothie19[0]{
            sm = smoothie19;
        }else if smooth == smoothie20[0]{
            sm = smoothie20;
        }else if smooth == smoothie21[0]{
            sm = smoothie21;
        }else if smooth == smoothie22[0]{
            sm = smoothie22;
        }else if smooth == smoothie23[0]{
            sm = smoothie23;
        }else if smooth == smoothie24[0]{
            sm = smoothie24;
        }else if smooth == smoothie25[0]{
            sm = smoothie25;
        }else if smooth == smoothie26[0]{
            sm = smoothie26;
        }else if smooth == smoothie27[0]{
            sm = smoothie27;
        }else if smooth == smoothie28[0]{
            sm = smoothie28;
        }else if smooth == smoothie29[0]{
            sm = smoothie29;
        }else if smooth == smoothie30[0]{
            sm = smoothie30;
        }else if smooth == smoothie31[0]{
            sm = smoothie31;
        }else if smooth == smoothie32[0]{
            sm = smoothie32;
        }else if smooth == smoothie33[0]{
            sm = smoothie33;
        }else if smooth == smoothie34[0]{
            sm = smoothie34;
        }else if smooth == smoothie35[0]{
            sm = smoothie35;
        }else if smooth == smoothie36[0]{
            sm = smoothie36;
        }else if smooth == smoothie37[0]{
            sm = smoothie37;
        }else if smooth == smoothie38[0]{
            sm = smoothie38;
        }else if smooth == smoothie39[0]{
            sm = smoothie39;
        }else if smooth == smoothie40[0]{
            sm = smoothie40;
        }else if smooth == smoothie41[0]{
            sm = smoothie41;
        }
        
        return sm
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
