//
//  GooglePhotosTab.swift
//  HW9
//
//  Created by bryce on 11/27/19.
//  Copyright © 2019 bryce. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner

class GooglePhotosTab: UIViewController, UIScrollViewDelegate {
    var data: JSON = []
    @IBOutlet weak var photoViewer: UIScrollView!
    let stackView = UIStackView()
    var imageArray = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Google Images...")
        assignbackground()
        print("build me3")
        stackView.axis = .vertical
        for urlString in data["images"].arrayValue{
            let url = NSURL(string: urlString.stringValue)! as URL
            if let imageData: NSData = NSData(contentsOf: url) {
                imageArray.append(UIImage(data: imageData as Data)!)
            }
        }
        view.addSubview(photoViewer)
        setupImages(imageArray)
        SwiftSpinner.hide()
        // Do any additional setup after loading the view.
    }
    func setupImages(_ images: [UIImage]){
        
        for i in 0..<images.count {
            
            let imageView = UIImageView()
            imageView.image = images[i]
            let yPosition = 600 * CGFloat(i)
            imageView.frame = CGRect(x: 0, y: yPosition, width: photoViewer.frame.width, height: 600)
            //imageView.contentMode = .scaleAspectFit
            
            photoViewer.contentSize.height = 600 * CGFloat(i + 1)
            photoViewer.addSubview(imageView)
            photoViewer.delegate = self
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//  GooglePhotosTab.swift
//  HW9
//
//  Created by bryce on 11/27/19.
//  Copyright © 2019 bryce. All rights reserved.
//
/*
import UIKit
import SwiftyJSON

class GooglePhotosTab: UIViewController, UIScrollViewDelegate {
    var data: JSON = []
    @IBOutlet weak var photoViewer: UIScrollView!
    let stackView = UIStackView()
    var imageArray = [UIImageView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        print("build me3")
        stackView.axis = .vertical
        for urlString in data["images"].arrayValue{
            let imageView = UIImageView()
            imageView.downloaded(from: urlString.stringValue)
            imageArray.append(imageView)
        }
        view.addSubview(photoViewer)
        setupImages(imageArray)
        // Do any additional setup after loading the view.
    }
    func setupImages(_ imageViews: [UIImageView]){
        
        for i in 0..<imageViews.count {
            //imageView.image = images[i]
            let imageView = imageViews[i]
            let yPosition = 800 * CGFloat(i)
            imageView.frame = CGRect(x: 0, y: yPosition, width: photoViewer.frame.width, height: 800)
            //imageView.contentMode = .scaleAspectFit
            
            photoViewer.contentSize.height = 600 * CGFloat(i + 1)
            photoViewer.addSubview(imageView)
            photoViewer.delegate = self
            
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
*/
