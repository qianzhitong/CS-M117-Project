//
//  GetOrderInfo.swift
//  QuickDrinksApp
//
//  Created by CLICC User on 12/2/17.
//  Copyright © 2017 CS117. All rights reserved.
//

import Foundation

protocol GetOrderInfo: class{
    func itemsDownloaded(items: NSArray)
}

class OrderInfo: NSObject, URLSessionDataDelegate {
    weak var delegate: GetOrderInfo!
    
    var data = Data()
    
    let urlPath: String = "http://quickdrinks.000webhostapp.com/quickserve_request.php"
    
    func downloadItems() {
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                print("Failed to download data")
            }
            else {
                print("Data downloaded")
                self.parseJSON( data!)
            }
        }
        task.resume()
        
    }
    
    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        let groups = NSMutableArray()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let group = Group()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let name = jsonElement["drink"] as? String,
                let status = jsonElement["status"] as? String
            {
                
                group.name = name
                group.status = status
            }
            
            groups.add(group)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(items: groups)
            
        })
    }
}
