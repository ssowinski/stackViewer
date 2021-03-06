//
//  StackRequest.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 14.02.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import Foundation

enum RequestMethod : String {
    case Questions = "questions"
    case Answers = "answers"
    case Search = "search"
}

enum OrdersType : String {
    case Desc = "desc"
    case Asc = "asc"
}

enum SortsType : String {
    case Activity = "activity"
    case Votes = "votes"
    case Creation = "creation"
    case Relevance = "relevance"
}

class StackRequest {
    
    private struct Const {
        static let URLHost = "https://api.stackexchange.com/2.2/"
        static let Page = "page"
        static let Pagesize = "pagesize"
        static let Order = "order"
        static let Sort = "sort"
        static let Intitle = "intitle"
        static let Site = "site"
        static let DefaultSite = "stackoverflow"
        static let Separator = "&"
        static let SeparatorMethodAndParameters = "?"
        static let LastActivityDate = "last_activity_date"
        static let CreationDate = "creation_date"
        static let Min = "min"
    }
    
    private let urlSession : NSURLSession
    private let sessionConfig : NSURLSessionConfiguration
    private var dataTask: NSURLSessionDataTask?
    private let requestMethod : RequestMethod
    //    private let idsString : String? //questions/{ids}?   (/2.2/questions/11222;2222;31222?order=desc&sort=reputation&site=stackoverflow)
    private var parameters = [String:String]()
    
    private var minCreationDate: String? = nil //greater than this are the newly added
    private var maxCreationDate: String? = nil //smaller then this are the older
    
    // designated initializer
    init (requestMethod: RequestMethod = RequestMethod.Search, ids: [Int]? = nil, pages: Int? = nil, pagesize: Int? = nil, order: OrdersType = OrdersType.Desc, sort: SortsType = SortsType.Creation ,site: String = Const.DefaultSite, intitle: String) {
        
        self.requestMethod = requestMethod
        
        //ids TODO
        
        if let pages = pages {
            parameters[Const.Page] = String(pages)
        }
        if let pagesize = pagesize {
            parameters[Const.Pagesize] = String(pagesize)
        }
        parameters[Const.Order] = order.rawValue
        parameters[Const.Sort] = sort.rawValue
        parameters[Const.Intitle] = intitle
        parameters[Const.Site] = site
        
        sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 20.0
        sessionConfig.timeoutIntervalForResource = 30.0
        //        sessionConfig.HTTPAdditionalHeaders = ["Accept": "application/json", "user_key": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
        urlSession = NSURLSession(configuration: sessionConfig)
    }
    
    var requestForNewer: StackRequest? {
        return (minCreationDate != nil) ? modifiedRequestParameters(Const.Min, value: minCreationDate!) : nil
    }
    
    private func modifiedRequestParameters(paramertrToChange:String, value:String) -> StackRequest{
        parameters[paramertrToChange] = value
        return self
    }
    
    func fetchData(completionHandler: ([Search]?, String?) -> Void) {
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        guard let url = NSURL(string: "\(Const.URLHost)\(requestMethod.rawValue)\(parametersToString(parameters))") else { return }
        print(url)
        
        dataTask = urlSession.dataTaskWithURL(url) {
            data, response, error in
            
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
//                    if let d = data {
//                        print(NSString(data: d, encoding: NSUTF8StringEncoding))
//                    }
                    let result = self.paresResponseData(data)
                    completionHandler(result, nil)
                }
            }
        }
        
        dataTask?.resume()
    }
    
    private func parametersToString(parameters: [String:String]) -> String {
        var parArray = [String]()
        
        for (parName, parValue) in parameters {
            if let encodedValue = parValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                parArray.append("\(parName)=\(encodedValue)")
            }
        }
        return parArray.isEmpty ? "" : Const.SeparatorMethodAndParameters + parArray.joinWithSeparator(Const.Separator)
    }
    
    // This helper method helps parse response JSON NSData into an array of Model objects.
    private func paresResponseData(data: NSData?) -> [Search] {
        var searchResults = [Search]()
        
        do {
            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] {
                //sprawdzić options: NSJSONReadingOptions(rawValue:0)NSJSONReadingOptions.AllowFragments
                // Get the results array
                if let arrayOfItems = response["items"] as? [AnyObject] {
//                    minCreationDate = nil  //for test error response
                    if !arrayOfItems.isEmpty { minCreationDate = nil } //if we have any item in response we set minCreationDate to nil
                    for searchDictonary in arrayOfItems {
                        if let searchDictonary = searchDictonary as? [String: AnyObject] {
                            
                            if minCreationDate == nil {
                                    if let ldoub = searchDictonary[Const.CreationDate] as? Int {
                                    minCreationDate = String(ldoub + 1)
                                    print(minCreationDate!)
                                }
                            }
                            
                            if let searchObj = Search(data: searchDictonary) {
                                searchResults.append(searchObj)
                                
                            }
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Items key not found in dictionary")
                }
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        return searchResults
    }
    
    
    
    // not used
    
    private func generatUrl() -> NSURL? {
        let components = NSURLComponents()
        //        components.scheme = Const.URLScheme
        components.host = Const.URLHost
        //        components.path = urlPath.rawValue
        
        
        return components.URL
    }
}








//let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://httpbin.org/get")!, completionHandler: { (data, response, error) -> Void in
//    do{
//        let str = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
//        print(str)
//    }
//    catch {
//        print("json error: \(error)")
//    }
//})
//task.resume()