
# Model

Represent [Search method](https://api.stackexchange.com/docs/search#page=3&pagesize=10&order=desc&sort=activity&intitle=ios%20button&filter=default&site=stackoverflow&run=true)


# NSURLSession 

**NSURLSession** is the object responsible for sending and receiving HTTP requests. 

For very simple, occasional use, this object might be the singleton sharedSession object.
```
let session = NSURLSession.sharedSession()
```
For more complex applications, you can create your own NSURLSession by one of initializers: 
- ```init(configuration:)```
- ```init(configuration:delegate:delegateQueue:)```
```
let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
```
### NSURLSessionConfiguration
You have to provide **NSURLSessionConfiguration** object describing the desired environment.

```NSURLSessionConfiguration.defaultSessionConfiguration()``` Default sessions behave much like the shared session (unless you customize them further), but let you obtain data incrementally using a delegate. 

```NSURLSessionConfiguration.ephemeralSessionConfiguration()``` Ephemeral sessions are similar to default sessions, but do not write caches, cookies, or credentials to disk. Think of this as a “private” session. 

```NSURLSessionConfiguration.backgroundSessionConfiguration()``` Background sessions let you perform uploads and downloads of content in the background while your app is not running.

NSURLSessionConfiguration object let us apply various options to the session:
- Whether to permit cell data use, or to require Wi-Fi
- The maximum number of simultaneous connections to the remote server
- Timeout values:
-- ```timeoutIntervalForRequest``` The maximum time you’re willing to wait between pieces of data. 
-- ```timeoutIntervalForResource``` The maximum time for the entire download to arrive.
- Cookie, caching, and credential policies



### NSURLSessionTask
**NSURLSessionTask** is the object that actually performs (and represents) one upload or download process. 

There are four kinds of session task (subclasses of NSURLSessionTask):

```NSURLSessionDataTask``` - Data tasks request a resource, returning the server’s response as one or more NSData objects in memory. They are supported in default, ephemeral, and shared sessions, but are not supported in background sessions. (Use this task for HTTP GET requests to retrieve data from servers to memory.)

```NSURLSessionUploadTask``` - Upload tasks are like data tasks, except that they make it easier to provide a request body so you can upload data before retrieving the server’s response. Additionally, upload tasks are supported in background sessions. (Use this task to upload a file from disk to a web service, typically via a HTTP POST or PUT method.)

```NSURLSessionDownloadTask``` - Download tasks download a resource directly to a file on disk. Download tasks are supported in any type of session. 

```NSURLStreamTask``` - New in iOS 9, this type of task makes it possible to deal with streams without having to drop down to the level of NSStream.

The session  will provide you with a list of its tasks in progress ```getAllTasksWithCompletionHandler:```. 

After you create a task in suspended state, you start it by calling its ```resume``` method.
In addition, you can tell a task to resume, suspend, or cancel. 

**Important properties:**
```taskDescription``` ,  ```taskIdentifier```, ```originalRequest```, ```currentRequest```, ```response```, ```countOfBytes``` - to track progress, ```state``` (NSURLSessionTaskState):.Running .Suspended .Canceling .Completed, 
```error```,  ```priority```

NSURLSession returns data in two ways: 

- via a completion handler. This completion handler is called when the task process ends (successfully or with an error) 
- or by calling methods on a delegate that you set upon session creation. (the delegate is called back at various stages of a task’s progress.) For each type of task, there’s a delegate protocol, which is itself often a composite of multiple protocols. For example, for a data task, we would want a data delegate — an object conforming to the ```NSURLSessionDataDelegate``` protocol, which itself conforms to the ```NSURLSessionTaskDelegate``` protocol, which in turn conforms to the ```NSURLSessionDelegate``` protocol, resulting in about a dozen delegate methods we could implement.

### Simple HTTP Request
```
let s = "http://www.someserver.com/somefolder/someimage.jpg"
let url = NSURL(string:s)!
let session = NSURLSession.sharedSession()
let task = session.downloadTaskWithURL(url) {
    (loc:NSURL?, response:NSURLResponse?, error:NSError?) in
        if error != nil {
        print(error)
        return
        }
        let status = (response as! NSHTTPURLResponse).statusCode
        if status != 200 {
            print("response status: \(status)")
            return
        }
    let d = NSData(contentsOfURL:loc!)!
    let im = UIImage(data:d)
    dispatch_async(dispatch_get_main_queue()) {
    self.iv.image = im
    }
}
task.resume()
```
### Formal HTTP Request
```
lazy var downloadsSession: NSURLSession = {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    return session
}()

```
Setting the delegate queue to nil causes the session to create a serial operation queue, by default, to perform all calls to the delegate methods and completion handlers.


Here are some delegate methods for responding to the download:
```
func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64,
    totalBytesWritten writ: Int64, totalBytesExpectedToWrite exp: Int64) {
    print("downloaded \(100*writ/exp)%")
}

func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    print("completed: error: \(error)")
}

func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    self.task = nil
    let response = downloadTask.response as! NSHTTPURLResponse
    let stat = response.statusCode
    print("status \(stat)")
    if stat != 200 {
        return }
    let d = NSData(contentsOfURL:location)!
    let im = UIImage(data:d)
    dispatch_async(dispatch_get_main_queue()) {
        self.iv.image = im
    }

```


>In this particular example, there is very little merit in using an NSURLRequest instead of an NSURL to form our task. Still, an NSURLRequest can come in handy (as I’ll demonstrate later in this chapter), and an upload task requires one.
>Do not use the NSURLRequest to configure properties of the request that are configurable through the NSURLSession. Those properties are left over from the era before NSURLSession existed. For example, there is no point setting the NSURLRequest’s timeoutInterval, as it is the NSURLSession’s timeout properties that are significant.

### Structure of a URL
A URL can be also be divided into pieces based on its structure. For example, the URL 

```https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref``` 

contains the following URL components:


|Component       |   Value                  |
|----------------|--------------------------|
|scheme          |   https                  |
|user            |   johnny                 |
|password        |   p4ssw0rd               |
|host            |   www.example.com        |
|port            |   443                    |
|path            |   /script.ext            |
|pathExtension   |   ext                    |
|pathComponents  |   ["/", "script.ext"]    |
|parameterString |   param=value            |
|query           |   query=value            |
|fragment        |   ref                    |
---------------------------------------------


In Foundation, URLs are represented by ```NSURL```.

```let url = NSURL(string: "https://www.example.com/")```

NSURL also has the initializer NSURL(string:relativeToURL:), which can be used to construct a URL from a string relative to a base URL. 

```
let baseURL = NSURL(string: "https://www.example.com/")
let newURL = NSURL(string:"foo?bar=baz", relativeToURL: baseURL)
// ttps://www.example.com/foo?bar=baz
```

```NSURLComponents``` instances are constructed much in the same way as ```NSURL``` (it can also be initialized without any arguments) 
but ```NSURLComponents``` provides a safe and direct way to modify individual components of a URL.

```
let components = NSURLComponents()
components.scheme = "https"
components.user = "admin"
components.password = "P@$$word"
components.host = "www.example.com"
components.path = "/test/foo"
components.fragment = "ref"
let url = components.url
```


>To go further into networking see Apple’s URL Loading System Programming >Guide and CFNetwork Programming Guide. 

# Refresh Control
```
//declaration 
let refreshControl = UIRefreshControl()

//set up 
refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

//add as subview to the tableView
tableView.addSubview(refreshControl)

//implement action 
func refresh(sender: UIRefreshControl){
    .
    .
    .
    //remember to endRefreshing
    sender.endRefreshing()
}

```

# NSCache

Basic example of use
```
let cache = NSCache()
let myObject: ExpensiveObjectClass

if let cachedVersion = cache.objectForKey("CachedObject") as? ExpensiveObjectClass {
    // use the cached version
    myObject = cachedVersion
} else {
    // create it from scratch then store in the cache
    myObject = ExpensiveObjectClass()
    cache.setObject(myObject, forKey: "CachedObject")
}
```

To share one instance of NSCatche between all UITableViewCell I've created singleton 

```
struct ImageCache {
    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "ImageCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 5*1024*1024 // Max 5MB used.
        return cache
    }()
}

```





