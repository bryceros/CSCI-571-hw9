//
//  FavViewController.swift
//  HW9
//
//  Created by bryce on 12/3/19.
//  Copyright © 2019 bryce. All rights reserved.
//

import UIKit
import SwiftyJSON
class FavViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    
    @IBOutlet weak var navItem: UINavigationItem!
    let defaults = UserDefaults.standard
    fileprivate lazy var pages: [ViewController] = {
        return [
            self.getViewController(withIdentifier: "ViewController",id: JSON([])),
        ]
        }() as! [ViewController]
    
    func findId(id:JSON) -> Int {
        print ("in find:",id)
        for i in 0..<pages.count{
            let vc = pages[i] as! ViewController
            if id["city"] == vc.id["city"] && id["state"] == vc.id["state"]{
                return i
            }
        }
        return -1
    }

    fileprivate func getViewController(withIdentifier identifier: String, id: JSON) -> UIViewController
    {
        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! ViewController
        vc.id = id
        vc.handleAddFav = { [weak self](id) in
            if let vc = self {
                // Do something with the item.
                if vc.findId(id: id) == -1{
                vc.pages.append(vc.getViewController(withIdentifier: "ViewController",id: id) as! ViewController)
                vc.store()
                }
            }
        }
        vc.handleRemoveFav = { [weak self](id) in
            if let vc = self {
                // Do something with the item.
                let index = vc.findId(id: id)
                if index != -1{
                    vc.pages.remove(at: index)
                    vc.setViewControllers([vc.pages[index - 1]], direction: .forward, animated: false, completion: nil)
                    vc.store()
                }
            }
        }
        vc.handleCheckFav = { [weak self] (id)  -> Bool in
            if let vc = self {
                // Do something with the item.
                return (vc.findId(id: id) != -1) as Bool
            }
            return false
        }
        vc.handleBack = { [weak self] (city:String) in
            if let vc = self {
                // Do something with the item.
               vc.navItem.backBarButtonItem = UIBarButtonItem(title: city, style: .plain, target: nil, action: nil)
            }
            
        }
        return vc
    }
    func store() {
        if(pages.count>1){
            var ids : [String] = []
            for i in 1..<pages.count{
                let vc = pages[i] as! ViewController
                ids.append(vc.id.rawString() ?? "")
                
            }
            defaults.set(ids, forKey: "ids")
        }
    }
    func load() {
        let ids = defaults.object(forKey: "ids") as? [String] ?? [String]()
        for i in 0..<ids.count {
            pages.append(self.getViewController(withIdentifier: "ViewController",id: JSON.init(parseJSON:ids[i])) as! ViewController)
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { return }
        DispatchQueue.main.async() {
            self.dataSource = nil
            self.dataSource = self
        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        navItem.backBarButtonItem = UIBarButtonItem(title: "Weather", style: .plain, target: nil, action: nil)
        load()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController as! ViewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        
        guard previousIndex >= 0 else { return nil }
        
        guard pages.count > previousIndex else { return nil}
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController as! ViewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard pages.count > nextIndex else { return nil         }
        
        guard nextIndex < pages.count else { return pages.first }
        
        return pages[nextIndex]
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
