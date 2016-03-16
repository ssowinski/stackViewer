//
//  User.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 08.03.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import Foundation

struct User : CustomStringConvertible {
    
    var reputation : Int?
    var userId : Int?
    var userType : String? //one of unregistered, registered, moderator, or does_not_exist (create enum ?)
    var acceptRate : Int?
    var profileImage : NSURL?
    var displayName : String?
    var link : NSURL?

    var description: String { return "\(displayName):\(userId) (\(userType))" }
    
    init?(data : NSDictionary?){
        guard let displayName = data?[UserApiKey.DisplayName] as? String else { return nil }
        self.displayName = displayName
        reputation = data?[UserApiKey.Reputation] as? Int //data?.valueForKeyPath(UserApiKey.displayName) as? Int
        userId = data?[UserApiKey.UserId] as? Int
        userType = data?[UserApiKey.UserType] as? String
        acceptRate = data?[UserApiKey.AcceptRate] as? Int
        if let urlProfileImageString = data?[UserApiKey.ProfileImage] as? String {
            profileImage = NSURL(string: urlProfileImageString)
        }
        if let urlLinkString = data?[UserApiKey.Link] as? String {
            link = NSURL(string: urlLinkString)
        }
    }
    
    var asPropertyList: AnyObject { //Read-Only Computed Properties (get)
        var dictionary = Dictionary<String,String>()
        dictionary[UserApiKey.Reputation] = String(reputation)
        dictionary[UserApiKey.UserId] = String(userId)
        dictionary[UserApiKey.UserType] = userType
        dictionary[UserApiKey.AcceptRate] = String(acceptRate)
        dictionary[UserApiKey.ProfileImage] = profileImage?.absoluteString
        dictionary[UserApiKey.DisplayName] = displayName
        dictionary[UserApiKey.Link] = link?.absoluteString
        return dictionary
    }
    
    private struct UserApiKey {
        static let Reputation = "reputation"
        static let UserId = "user_id"
        static let UserType = "user_type"
        static let AcceptRate = "accept_rate"
        static let ProfileImage = "profile_image"
        static let DisplayName = "display_name"
        static let Link = "link"
    }
    
}





