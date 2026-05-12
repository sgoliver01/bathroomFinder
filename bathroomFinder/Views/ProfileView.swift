//
//  ProfileView.swift
//  bathroomFinder
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userReviews: [(review: Review, bathroomName: String)] = []
    @State private var isLoading = true
    @State private var selectedEmoji: String = "😀"
    @State private var showEmojiPicker = false
    @State private var showShareSheet = false
    
    let emojiOptions = ["😀", "😎", "🤠", "💩", "🚽", "👻", "🐸", "🦄", "🧑‍💻", "🤓", "😈", "🐶", "🐱", "🦊", "🐻", "🐼"]
    
    var userEmail: String {
        Auth.auth().currentUser?.email ?? "Unknown"
    }
    
    var recentReviews: [(review: Review, bathroomName: String)] {
        Array(userReviews.prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack(spacing: 12) {
                        Button {
                            showEmojiPicker.toggle()
                        } label: {
                            Text(selectedEmoji)
                                .font(.system(size: 60))
                        }
                        
                        Text(userEmail)
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            StatBox(value: "\(userReviews.count)", label: "Reviews")
                            StatBox(value: averageRating, label: "Avg Rating")
                        }
                    }
                    .padding(.vertical, 16)
                    
                    // Share button
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share Profile with Friends", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Recent reviews section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Reviews")
                                .font(.title3)
                                .bold()
                            Spacer()
                            if userReviews.count > 3 {
                                NavigationLink {
                                    AllReviewsView(reviews: userReviews)
                                } label: {
                                    Text("See All (\(userReviews.count))")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView("Loading reviews...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if userReviews.isEmpty {
                            Text("No reviews yet")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(recentReviews, id: \.review.id) { item in
                                NavigationLink {
                                    ReviewDetailView(review: item.review)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.bathroomName)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            HStack(spacing: 4) {
                                                Text(String(format: "%.1f/5", item.review.overallRating))
                                                    .font(.subheadline)
                                                    .bold()
                                                Text("💩")
                                                    .font(.caption)
                                            }
                                        }
                                        Spacer()
                                        Text(item.review.postedOnValue, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            dismiss()
                        } catch {
                            print("error signing out")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                fetchUserReviews()
                loadEmoji()
            }
            .sheet(isPresented: $showEmojiPicker) {
                VStack(spacing: 16) {
                    Text("Choose your avatar")
                        .font(.headline)
                        .padding(.top)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                                saveEmoji(emoji)
                                showEmojiPicker = false
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 40))
                            }
                        }
                    }
                    .padding()
                    Spacer()
                }
                .presentationDetents([.height(300)])
            }
            .sheet(isPresented: $showShareSheet) {
                ShareView()
            }
        }
    }
    
    var averageRating: String {
        guard !userReviews.isEmpty else { return "—" }
        let avg = userReviews.map { $0.review.overallRating }.reduce(0, +) / Double(userReviews.count)
        return String(format: "%.1f", avg)
    }
    
    func fetchUserReviews() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Read from user's review references (fast - only reads user's docs)
        db.collection("users").document(userId).collection("reviews")
            .order(by: "reviewedAt", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    isLoading = false
                    return
                }
                
                var results: [(review: Review, bathroomName: String)] = []
                let group = DispatchGroup()
                
                for doc in documents {
                    let bathroomId = doc.data()["bathroomId"] as? String ?? ""
                    let bathroomName = doc.data()["bathroomName"] as? String ?? "Unknown"
                    
                    guard !bathroomId.isEmpty else { continue }
                    group.enter()
                    
                    // Fetch the actual review from the bathroom's subcollection
                    db.collection("bathrooms").document(bathroomId).collection("reviews")
                        .whereField("reviewer", isEqualTo: Auth.auth().currentUser?.email ?? "")
                        .getDocuments { reviewSnapshot, _ in
                            if let reviewDocs = reviewSnapshot?.documents {
                                for reviewDoc in reviewDocs {
                                    if let review = try? reviewDoc.data(as: Review.self) {
                                        results.append((review: review, bathroomName: bathroomName))
                                    }
                                }
                            }
                            group.leave()
                        }
                }
                
                group.notify(queue: .main) {
                    userReviews = results.sorted { $0.review.postedOnValue > $1.review.postedOnValue }
                    isLoading = false
                }
            }
    }
    
    func saveEmoji(_ emoji: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["emoji": emoji], merge: true)
    }
    
    func loadEmoji() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { doc, _ in
            if let data = doc?.data(), let emoji = data["emoji"] as? String {
                selectedEmoji = emoji
            }
        }
    }
}

// MARK: - All Reviews View
struct AllReviewsView: View {
    let reviews: [(review: Review, bathroomName: String)]
    
    var body: some View {
        List(reviews, id: \.review.id) { item in
            NavigationLink {
                ReviewDetailView(review: item.review)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.bathroomName)
                            .font(.headline)
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f/5", item.review.overallRating))
                                .font(.subheadline)
                                .bold()
                            Text("💩")
                                .font(.caption)
                        }
                    }
                    Spacer()
                    Text(item.review.postedOnValue, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("All Reviews")
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80)
    }
}

#Preview {
    ProfileView()
}
