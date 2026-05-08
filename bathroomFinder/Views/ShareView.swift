//
//  ShareView.swift
//  bathroomFinder
//

import SwiftUI
import MessageUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var friendName = ""
    @State private var phoneNumber = ""
    @State private var message = "Hey! Check out Bathroom Finder 🚽💩 — it helps you find and rate bathrooms nearby. Download it here: [App Store Link]"
    @State private var showMessageComposer = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Share with a friend")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Friend's Name")
                        .font(.subheadline)
                        .bold()
                    TextField("Name", text: $friendName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Text("Phone Number")
                        .font(.subheadline)
                        .bold()
                    TextField("(555) 123-4567", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Text("Message")
                        .font(.subheadline)
                        .bold()
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button {
                    if phoneNumber.isEmpty {
                        alertMessage = "Please enter a phone number"
                        showAlert = true
                    } else if MFMessageComposeViewController.canSendText() {
                        showMessageComposer = true
                    } else {
                        alertMessage = "Text messaging is not available on this device"
                        showAlert = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send Text")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showMessageComposer) {
                MessageComposerView(recipients: [phoneNumber], body: message) {
                    dismiss()
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

// MARK: - Message Composer (UIKit wrapper)
struct MessageComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.recipients = recipients
        controller.body = body
        controller.messageComposeDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let onDismiss: () -> Void
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
            onDismiss()
        }
    }
}

#Preview {
    ShareView()
}
