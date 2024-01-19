//
//  Review.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var title = ""
    var body = ""
    var easeOfUse = ""
    var easyToFind = ""
    var line = ""
    var toiletPaper = ""
    var cleanliness = ""
    var rating = 0
    var reviewer = ""
    var postedOn = Date()
    
    var dictionary: [String: Any] {
        return ["title": title, "body": body, "easeOfUse": easeOfUse, "rating": rating, "easyToFind": easyToFind, "line": line, "toiletPaper": toiletPaper, "reviewer": Auth.auth().currentUser?.email ?? "", "postedOn": Timestamp(date: Date())]
    }
}
