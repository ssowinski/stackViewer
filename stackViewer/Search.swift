//
//  Search.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 08.03.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import Foundation

struct Search : CustomStringConvertible {
    
    var tags : [String]?
    var owner : User?
    var isAnswered : Bool?
    var viewCount : Int?
    var answerCount : Int?
    var score : Int?
    var lastActivityDate : NSDate?//NSDate(timeIntervalSince1970: 1415637900)": 1439415184,
    var creationDate : NSDate?
    var lastEditDate : NSDate?
    var questionId : Int?
    var link : NSURL?
    var title : String?
    
    var description : String {
        if let lastActDateStr = lastActivityDate?.getString(.MediumStyle, timeFormatterStyle: .ShortStyle), let questId = questionId, let tit = title {
            return "\(lastActDateStr) - [\(questId)] \(tit)"
        } else {
            return " "
        }
    }
       
    init?(data : NSDictionary?){
        guard let questionId = data?[SearchApiKey.QuestionId] as? Int else { return nil }
        self.questionId = questionId
        
        if let tagsArray = data?[SearchApiKey.Tags] as? NSArray {
            tags = tagsArray as? [String]
        }
        
        if let ownerDictionary = data?[SearchApiKey.Owner] as? NSDictionary {
            if let user = User(data: ownerDictionary) {
                owner = user
            }
        }
        
        isAnswered = data?[SearchApiKey.IsAnswered] as? Bool
        viewCount = data?[SearchApiKey.ViewCount] as? Int
        answerCount = data?[SearchApiKey.AnswerCount] as? Int
        score = data?[SearchApiKey.Score] as? Int
        
        if let doubleLastActivityDate = data?[SearchApiKey.LastActivityDate] as? Double {
            lastActivityDate = NSDate(timeIntervalSince1970: doubleLastActivityDate)
        }
        if let doubleCreationDate = data?[SearchApiKey.CreationDate] as? Double {
            creationDate = NSDate(timeIntervalSince1970: doubleCreationDate)
        }
        if let doubleLastEditDate = data?[SearchApiKey.LastEditDate] as? Double {
            lastEditDate = NSDate(timeIntervalSince1970: doubleLastEditDate)
        }
        
        if let urlString = data?[SearchApiKey.Link] as? String {
            link = NSURL(string: urlString)
        }
        title = data?[SearchApiKey.Title] as? String
    }
    
    private struct SearchApiKey {
        static let Tags = "tags"
        static let Owner = "owner"
        static let IsAnswered = "is_answered"
        static let ViewCount = "view_count"
        static let AnswerCount = "answer_count"
        static let Score = "score"
        static let LastActivityDate = "last_activity_date"
        static let CreationDate = "creation_date"
        static let LastEditDate = "last_edit_date"
        static let QuestionId = "question_id"
        static let Link = "link"
        static let Title = "title"
    }
}