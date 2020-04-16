//
//  ViewController.swift
//  HW9
//
//  Created by bryce on 11/23/19.
//  Copyright © 2019 bryce. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Toast_Swift
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate{
    

    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var citySearchTable: UITableView!
    @IBOutlet weak var mainPanel1: UIView!
    @IBOutlet weak var mainPanel2: UIStackView!
    @IBOutlet weak var mainPanel3: UITableView!
    @IBOutlet weak var FavButton: UIImageView!
    //var panel : PanelController!
    @IBOutlet weak var navItem: UINavigationItem!
    

    let locationManager = CLLocationManager()
    
    //let domain = "http://hw8-env.kbtmmfgwys.us-east-2.elasticbeanstalk.com/api/"
    let domain = "http://localhost:3000/api/"
    var citySearch:[String] = []
    
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
    
    
    var id : JSON = []
    var handleAddFav: ((_ id: JSON) -> Void)?
    var handleRemoveFav: ((_ id: JSON) -> Void)?
    var handleCheckFav: ((_ id: JSON) -> Bool)?
    var handleSetNav: ((_ nav: UINavigationItem) -> Void)?
    var handleBack: ((_ city: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        assignbackground()
        citySearchBar.delegate = self
        
        citySearchTable.delegate = self
        citySearchTable.dataSource = self
        citySearchTable.layer.zPosition = 1;
        
        mainPanel3.delegate = self
        mainPanel3.dataSource = self
        
        mainPanel1.backgroundColor = UIColor(white: 1, alpha: 0.25)
        mainPanel1.layer.cornerRadius = 5;
        mainPanel3.backgroundColor = UIColor(white: 1, alpha: 0.25)
        mainPanel3.layer.cornerRadius = 5;


        self.view.addSubview(mainPanel1)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
        gestureRecognizer.delegate = self
        mainPanel1.addGestureRecognizer(gestureRecognizer)
        
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(onTapFav(_:)))
        gestureRecognizer2.delegate = self
        FavButton.isUserInteractionEnabled = true
        FavButton.addGestureRecognizer(gestureRecognizer2)
        
        locationManager.requestAlwaysAuthorization()
        
        //citySearchBar.sizeToFit()
        //citySearchBar.layer.zPosition = 1;
        
        if CLLocationManager.locationServicesEnabled() && self.id == JSON([]){
            SwiftSpinner.show("Loading...")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            FavButton.isHidden = true
            handleBack?("Weather")
        } else{
            SwiftSpinner.show("Fetching Weather Details for "+id["city"].stringValue+"...")
            getData(id: self.id)
            if id["fav"].boolValue{
                FavButton.image = UIImage(named: "trash-can")
            } else {
                citySearchBar.isHidden=true
                navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(addTapped))
                navItem.title = id["city"].stringValue
            }
            handleBack?(id["city"].stringValue)
            
        }
        if id["search"].boolValue == false{
            navItem.titleView = citySearchBar
        } else {
            citySearchBar.isHidden=true
        }
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
    // networking
    func getCities(searchText:String) {
        Alamofire.request(domain+"cats:"+searchText, method: .get).validate()
            .responseJSON{ response in
                if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                self.citySearch = (json.arrayObject as? [String])!
                if(self.citySearch.count == 0){
                   self.citySearchTable.isHidden = true
                } else{
                    self.citySearchTable.isHidden = false
                }
                self.citySearchTable.reloadData()
                
            }else{
                print(response.result.error)
            }
        }
    }
    // Components
    @objc func addTapped() {
        print("Twitter Clicked")
        let url = String( "https://twitter.com/intent/tweet?text="+"The current temperature at "+self.data["city"].stringValue+" is "+self.data["currently"]["Temperature"].stringValue+"°F.The weather conditions are "+self.data["currently"]["Summary"].stringValue+"&hashtags=CSCI571WeatherSearch").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let link = URL(string:url)!
        UIApplication.shared.open(link)
        
    }
    
    @objc func onTapFav(_ gesture:UITapGestureRecognizer){
        print("Fav")
        if FavButton.image == UIImage(named: "plus-circle"){
            FavButton.image = UIImage(named: "trash-can")
            
            self.id["fav"] = true
            var id = self.id
            id["search"] = false
            handleAddFav?(id)
            self.view.makeToast(self.id["city"].stringValue+"was added to your Favorite List")
            
        } else {
            FavButton.image = UIImage(named: "plus-circle")
            self.id["fav"] = false
            handleRemoveFav?(self.id)
        }
    }
    @objc func onTapGesture(_ gesture:UITapGestureRecognizer){
        print("click")
        //self.handleSurge?(data)
        performSegue(withIdentifier: "segue", sender: self)
        /*let nav = self.view.window!.rootViewController as! UINavigationController
        let mc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
        mc.data = data
        nav.show(mc, sender: self)*/
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! MainTabController
        vc.data = data
    }
    func ReloadData(){
        //first panel
        let image = self.mainPanel1.viewWithTag(4) as! UIImageView
        let temp = self.mainPanel1.viewWithTag(1) as? UILabel
        let summary = self.mainPanel1.viewWithTag(2) as? UILabel
        let city = self.mainPanel1.viewWithTag(3) as? UILabel
        
        print(self.iconImage[data["currently"]["Icon"].stringValue]!)
        image.image = UIImage(named:self.iconImage[data["currently"]["Icon"].stringValue]!)
        temp?.text = data["currently"]["Temperature"].stringValue
        summary?.text = data["currently"]["Summary"].stringValue
        city?.text = data["city"].stringValue
        
        //second panel
        let humidity = self.mainPanel2.viewWithTag(4)?.viewWithTag(2) as! UILabel
        let windSpeed = self.mainPanel2.viewWithTag(9)!.viewWithTag(8) as? UILabel
        let visibility = self.mainPanel2.viewWithTag(5)?.viewWithTag(2) as? UILabel
        let pressure = self.mainPanel2.viewWithTag(3)?.viewWithTag(2) as? UILabel
        
        print(data["currently"]["Humidity"].stringValue)
        humidity.text = data["currently"]["Humidity"].stringValue+"%"
        windSpeed!.text = data["currently"]["WindSpeed"].stringValue+" mph"
        visibility!.text = data["currently"]["Visibility"].stringValue+" km"
        pressure!.text = data["currently"]["Pressure"].stringValue+" mb"
        
        //Third panel
        self.mainPanel3.isHidden = false
        self.mainPanel3.reloadData()
        
        SwiftSpinner.hide()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.citySearchTable.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.citySearchTable.isHidden = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getCities(searchText: searchText)
    }
    func getData(id : JSON) {
        print(self.domain+"cats")
        Alamofire.request(self.domain+"cats", method: .post, parameters: id.dictionaryValue).validate()
            .responseJSON{ response in
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                    self.data = json
                    self.data["city"].stringValue = id["city"].stringValue
                    self.ReloadData()
                    //self.panel.updateTable(d: self.data)
                }else{
                    print(response.result.error as Any)
                }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        var citySate = searchBar.text?.split{$0 == ","}
        let city = String(citySate?[0] ?? "")
        let state = String(citySate?[1] ?? "")
        var coord = JSON(["city":city,"state":state,"street":""])
        coord["fav"].boolValue = self.handleCheckFav?(coord) ?? false
        coord["search"].boolValue = true
        let nav = self.view.window!.rootViewController as! UINavigationController
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.id = JSON(coord)
        vc.handleAddFav = { [weak self](id) in
            if let vc = self {
                // Do something with the item.
                vc.handleAddFav?(id)
            }
        }
        vc.handleRemoveFav = { [weak self](id) in
            if let vc = self {
                // Do something with the item.
                vc.handleRemoveFav?(id)
            }
        }
        vc.handleCheckFav = { [weak self] (id)  -> Bool in
            if let vc = self {
                // Do something with the item.
                vc.handleCheckFav?(id)
            }
            return false
        }
        nav.show(vc, sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.citySearchTable {
        return citySearch.count
        }
        print(self.data["weekly"]["time"].count)
        return self.data["weekly"]["time"].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.citySearchTable {
            let cell = citySearchTable.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = citySearch[indexPath.row]
            return cell
        }
        else if tableView == self.mainPanel3 {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "PST") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            let cell = tableView.dequeueReusableCell(withIdentifier: "pCell", for: indexPath) as UITableViewCell
            let date = cell.viewWithTag(0)?.viewWithTag(0)?.viewWithTag(6) as? UILabel
            let icon = cell.viewWithTag(0)?.viewWithTag(0)?.viewWithTag(1) as? UIImageView
            let sunriseLabel = cell.viewWithTag(0)?.viewWithTag(0)?.viewWithTag(2) as? UILabel
            let sunsetLabel = cell.viewWithTag(0)?.viewWithTag(0)?.viewWithTag(4) as? UILabel
            
            dateFormatter.dateFormat = "MM/dd/yyyy"
            date?.text = dateFormatter.string(from:Date(timeIntervalSince1970: TimeInterval(data["weekly"]["time"][indexPath.row].intValue)))
            print(self.iconImage[data["weekly"]["icon"][indexPath.row].stringValue]!)
            icon?.image = UIImage(named:self.iconImage[data["weekly"]["icon"][indexPath.row].stringValue]!)
            
            dateFormatter.dateFormat = "HH:mm"
            sunriseLabel?.text = dateFormatter.string(from:Date(timeIntervalSince1970:TimeInterval(data["weekly"]["sunrise"][indexPath.row].intValue)))
            sunsetLabel?.text = dateFormatter.string(from:Date(timeIntervalSince1970:TimeInterval(data["weekly"]["sunset"][indexPath.row].intValue)))
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        if tableView == self.citySearchTable {
            //here get the text from tapped cell index
            let tappedCellText = citySearch[indexPath.row]
            // here set placeholder
            citySearchBar.text = tappedCellText
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // .requestLocation will only pass one location to the locations array
        // hence we can access it by taking the first element of the array
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        let currentlocation = CLLocation(latitude: manager.location!.coordinate.latitude, longitude: manager.location!.coordinate.longitude)
        
        self.fetchCityAndCountry(from: currentlocation) { city, country, error in
            guard var city = city, let country = country, error == nil else { return }
            var coord = ["lng":String(locValue.longitude),"lat":String(locValue.latitude),"city":city]
            Alamofire.request(self.domain+"cats/cl", method: .post, parameters: coord).validate()
            .responseJSON{ response in
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                    print(city + ", " + country)
                    self.data = json
                    self.data["city"].stringValue = city
                    self.ReloadData()
                    //self.panel.updateTable(d: self.data)
                    self.locationManager.stopUpdatingLocation()
                    
                }else{
                    print(response.result.error as Any)
                }
        }
        }
        
    }
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

}


