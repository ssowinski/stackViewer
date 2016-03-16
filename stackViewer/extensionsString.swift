//
//  extensionsString.swift
//  SpeedwayMeetingProgramme
//
//  Created by Slawomir Sowinski on 21.11.2015.
//  Copyright © 2015 Slawomir Sowinski. All rights reserved.
//

import UIKit

extension String {
    func getDate(dateFormatterStyle: NSDateFormatterStyle, timeFormatterStyle: NSDateFormatterStyle) -> NSDate?{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = dateFormatterStyle
        dateFormatter.timeStyle = timeFormatterStyle
        return dateFormatter.dateFromString(self)
    }
}

extension NSDate {
    func getString(dateFormatterStyle: NSDateFormatterStyle, timeFormatterStyle: NSDateFormatterStyle) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = dateFormatterStyle
        dateFormatter.timeStyle = timeFormatterStyle
//        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return dateFormatter.stringFromDate(self)
    }
}

