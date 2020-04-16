//
//  WeeklyTabController.swift
//  HW9
//
//  Created by bryce on 11/27/19.
//  Copyright © 2019 bryce. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts


class WeeklyTabController: UIViewController {
    var data: JSON = []
    
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
    
    
    @IBOutlet weak var panel: UIView!
    @IBOutlet weak var lineChartView: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        panel.backgroundColor = UIColor(white: 1, alpha: 0.25)
        panel.layer.cornerRadius = 5;
        print("build me2")
        // Do any additional setup after loading the view.
        
        let image = panel.viewWithTag(3)!.viewWithTag(0) as! UIImageView
        let label = panel.viewWithTag(3)!.viewWithTag(1) as! UILabel
        
        image.image = UIImage(named: iconImage[data["weekly"]["icon"][0].stringValue]!)
        label.text = data["weekly"]["summary"][0].stringValue
        
        var high : [Double] = []
        var low : [Double] = []
        for i in 0..<data["weekly"]["temperature"].count {
            low.append(data["weekly"]["temperature"][i][0].doubleValue)
            high.append(data["weekly"]["temperature"][i][1].doubleValue)
        }
        setChartData(high: high, low: low )
        
    }
    
    func setChartData(high : [Double], low : [Double]) {
        
        let data = LineChartData()
        var lineChartEntry1 = [ChartDataEntry]()
        
        for i in 0..<low.count {
            lineChartEntry1.append(ChartDataEntry(x: Double(i), y: Double(low[i]) ?? 0.0))
        }
        let line1 = LineChartDataSet(entries: lineChartEntry1, label: "Minimum Temperature (°F)")
        line1.colors = [NSUIColor.white]
        line1.setCircleColor(NSUIColor.white)
        line1.circleRadius = 3.0

        data.addDataSet(line1)
        if (low.count > 0) {
            var lineChartEntry2 = [ChartDataEntry]()
            for i in 0..<high.count {
                lineChartEntry2.append(ChartDataEntry(x: Double(i), y: Double(high[i]) ?? 0.0))
            }
            let line2 = LineChartDataSet(entries: lineChartEntry2, label: "Maximum Temperature (°F)")
            line2.colors = [NSUIColor.orange]
            line2.setCircleColor(NSUIColor.orange)
            line2.circleRadius = 3.0
            
            data.addDataSet(line2)
        }
        self.lineChartView.data = data
    }
    
    func assignbackground(){
        let background = UIImage(named: "background")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
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
