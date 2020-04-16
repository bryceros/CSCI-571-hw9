//
//  TadayTabController.swift
//  HW9
//
//  Created by bryce on 11/26/19.
//  Copyright © 2019 bryce. All rights reserved.
//

import UIKit
import SwiftyJSON

class TodayTabController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var navBar: UINavigationBar!
    let iconImage = [
        "clear-day": "weather-sunny",
        "clear-night": "weather-night",
        "rain": "weather-rainy",
        "snow" : "weather-snowy",
        "sleet" : "weather-snowy-rainy",
        "wind" : "weather-windy-variant",
        "fog" : "weather-fog",
        "cloudy" : "weather-cloudy",
        "partly-cloudy-night" : "weather-night-partly-cloudy",
        "partly-cloudy-day" : "weather-partly-cloudy"
    ]
    
    var collectionImage = ["weather-windy","gauge","weather-pouring","thermometer","","water-percent","eye-outline","weather-fog","earth"]
    var collectionLabel1 = [" mph"," mb"," mmph","°F",""," %"," km"," %"," DU"]
    var collectionLabel2 = ["Wind Speed","Pressure","Precipitation","Temperature","","Humidity","Visibility","Cloud Cover","Ozone"]
    var collectionData: [String] = []

    var data: JSON = []
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        print("build me")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let width = (collectionView.frame.size.width - 100)/3
        let height = (collectionView.frame.size.height - 100)/3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionData.append(data["currently"]["WindSpeed"].stringValue)
        collectionData.append(data["currently"]["Pressure"].stringValue)
        collectionData.append(data["currently"]["Precipitation"].stringValue)
        collectionData.append(data["currently"]["Temperature"].stringValue)
        collectionData.append(data["currently"]["Summary"].stringValue)
        collectionData.append(data["currently"]["Humidity"].stringValue)
        collectionData.append(data["currently"]["Visibility"].stringValue)
        collectionData.append(data["currently"]["CloudCover"].stringValue)
        collectionData.append(data["currently"]["Ozone"].stringValue)
        
        collectionImage[4] = iconImage[data["currently"]["Icon"].stringValue] ?? ""
    }
    func assignbackground(){
        let background = UIImage(named: "background")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        self.collectionView.backgroundView = imageView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectCell", for: indexPath)
        cell.backgroundColor = UIColor(white: 1, alpha: 0.25)
        cell.layer.cornerRadius = 5;
        
        let image = cell.viewWithTag(1)!.viewWithTag(0) as! UIImageView
        let label1 = cell.viewWithTag(1)!.viewWithTag(3) as! UILabel
        let label2 = cell.viewWithTag(1)!.viewWithTag(2) as! UILabel
        image.image = UIImage(named: self.collectionImage[indexPath.row])
        label1.text = self.collectionData[indexPath.row] + self.collectionLabel1[indexPath.row]
        label2.text = self.collectionLabel2[indexPath.row]
        return cell
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
