/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to download the feed of recent earthquakes.
*/

import Foundation

class DownloadEarthquakesOperation: GroupOperation {
    // MARK: Properties

    let cacheFile: NSURL
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the earthquake feed will be downloaded.
    init(cacheFile: NSURL) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Earthquakes"
        
        /*
            Since this server is out of our control and does not offer a secure
            communication channel, we'll use the http version of the URL and have
            added "earthquake.usgs.gov" to the "NSExceptionDomains" value in the
            app's Info.plist file. When you communicate with your own servers,
            or when the services you use offer secure communication options, you
            should always prefer to use https.
        */
        let url = NSURL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
//        let task = URLSession.shared.downloadTaskWithURL(url) { url, response, error in
//            self.downloadFinished(url, response: response as? HTTPURLResponse, error: error)
//        }
        
        
        let task = URLSession.shared.downloadTask(with: url as URL) { url, response, error in
           
            self.downloadFinished(url: url as! NSURL, response: response as! HTTPURLResponse, error: error as NSError?)
        }
                
        
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url)
        taskOperation.addCondition(condition: reachabilityCondition)

        let networkObserver = NetworkObserver()
        taskOperation.addObserver(observer: networkObserver)
        
        addOperation(operation: taskOperation)
    }
    
    func downloadFinished(url: NSURL?, response: HTTPURLResponse?, error: NSError?) {
        if let localURL = url {
            do {
                /*
                    If we already have a file at this location, just delete it.
                    Also, swallow the error, because we don't really care about it.
                */
                try FileManager.default.removeItem(at: cacheFile as URL)
            }
            catch { }
            
            do {
                try FileManager.default.moveItem(at: localURL as URL, to: cacheFile as URL)
            }
            catch let error as NSError {
                aggregateError(error: error)
            }
            
        }
        else if let error = error {
            aggregateError(error: error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
}