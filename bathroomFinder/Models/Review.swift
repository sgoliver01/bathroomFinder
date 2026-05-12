//
//  Review.swift
//  bathroomFinder
//
//  Created by Sarah Oliver on 1/17/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var easeOfUse: Int?
    var easyToFind: Int?
    var waitTime: Int?
    var toiletPaper: Int?
    var cleanliness: Int?
    var body: String?
    var reviewer: String?
    var postedOn: Date?
    
    // Safe accessors with defaults
    var easeOfUseValue: Int { easeOfUse ?? 0 }
    var easyToFindValue: Int { easyToFind ?? 0 }
    var waitTimeValue: Int { waitTime ?? 0 }
    var toiletPaperValue: Int { toiletPaper ?? 0 }
    var cleanlinessValue: Int { cleanliness ?? 0 }
    var bodyValue: String { body ?? "" }
    var reviewerValue: String {
        let email = reviewer ?? ""
        return email.components(separatedBy: "@").first ?? email
    }
    var postedOnValue: Date { postedOn ?? Date() }
    
    /// Computed average of all 5 rating fields (1-5 scale)
    var overallRating: Double {
        let fields = [easeOfUseValue, waitTimeValue, toiletPaperValue, cleanlinessValue]
        let nonZero = fields.filter { $0 > 0 }
        guard !nonZero.isEmpty else { return 0 }
        return Double(nonZero.reduce(0, +)) / Double(nonZero.count)
    }
    
    init() {
        easeOfUse = 0
        easyToFind = 0
        waitTime = 0
        toiletPaper = 0
        cleanliness = 0
        body = ""
        reviewer = ""
        postedOn = Date()
    }
    
    var dictionary: [String: Any] {
        return [
            "easeOfUse": easeOfUse ?? 0,
            "easyToFind": easyToFind ?? 0,
            "waitTime": waitTime ?? 0,
            "toiletPaper": toiletPaper ?? 0,
            "cleanliness": cleanliness ?? 0,
            "body": body ?? "",
            "reviewer": Auth.auth().currentUser?.email ?? "",
            "postedOn": Timestamp(date: Date())
        ]
    }
}
