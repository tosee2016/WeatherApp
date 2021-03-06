//
//  ViewController.swift
//  WeatherApp
//
//  Created by 大和芳隆 on 2016/11/13.
//  Copyright © 2016年 BETA-yamato. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayImage: UIImageView!

    @IBOutlet weak var tomorrowLabel: UILabel!
    @IBOutlet weak var tomorrowImage: UIImageView!

    
    @IBOutlet weak var afterTomorrowLabel: UILabel!
    @IBOutlet weak var afterTomorrowImage: UIImageView!

    
    @IBAction func zenkokubutton(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("http://weather.livedoor.com/forecast/webservice/json/v1?city=030010").responseJSON { (response: DataResponse<Any>) in
            
            print(response)
            
            if response.result.isFailure == true {
                self.simpleAlert(title: "通信エラー", message: "通信に失敗しました")
                return
            }
            // "guard let 変数 〜 else" で変数の中身がnilの場合のみの処理が書けます。
            // ただし最後に必ずreturnで関数を終了させなければいけません。
            // 変数は以後の関数内でも利用できます。
            guard let val = response.result.value as? [String: Any] else {
                self.simpleAlert(title: "通信エラー", message: "通信結果がJSONではありませんでした")
                return
            }
            
            // responseJSONを使うと辞書形式でも扱えますが、今回はより簡単に扱うためにSwiftyJSONを利用します。
            let json = JSON(val)
            
            // タイトル部分
            if let title = json["title"].string {
                self.titleLabel.text = title
            }
            // 天気の情報
            if let forecasts = json["forecasts"].array {
                
                // 今日の天気
                var box = forecasts[0]
                self.todayLabel.text = box["dateLabel"].stringValue + "\n" + box["telop"].stringValue + "\n" + self.generateTemperatureText(box["temperature"])
                if let imgUrl = box["image"]["url"].string {
                    self.todayImage.sd_setImage(with: URL(string: imgUrl))
                }
                
                // 明日の天気
                var box1 = forecasts[1]
                
                self.tomorrowLabel.text = box1["dateLabel"].stringValue + "\n" + box["telop"].stringValue + "\n" + self.generateTemperatureText(box1["temperature"])
                if let imgUrl = box1["image"]["url"].string {
                    self.tomorrowImage.sd_setImage(with: URL(string: imgUrl))
                }

                
                // 明後日の天気
                // 気象情報の更新が入るまで明後日の天気情報が存在しない場合があるので要素数をチェックします
                if forecasts.count >= 3 {
                    let afterTomorrowWeather = forecasts[2]
                    
                    self.afterTomorrowLabel.text = afterTomorrowWeather["dateLabel"].stringValue + "\n" + afterTomorrowWeather["telop"].stringValue  + "\n" + self.generateTemperatureText(afterTomorrowWeather["temperature"])
                    if let imgUrl = afterTomorrowWeather["image"]["url"].string {
                        self.afterTomorrowImage.sd_setImage(with: URL(string: imgUrl))
                    }
                }
                
            }
            
            
            
        }
    }
    // 閉じるボタンのみのアラートを表示します。
    func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        }
    // 気温のラベル用テキストを生成します。
    func generateTemperatureText(_ temperature: JSON) -> String {
        
        var resultText = ""
        
        if let min = temperature["min"]["celsius"].string {
            resultText += min + "℃"
        } else {
            resultText += "-"
        }
        
        resultText += " / "
        
        if let max = temperature["max"]["celsius"].string {
            resultText += max + "℃"
        } else {
            resultText += "-"
        }
        
        return resultText
    }

    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

