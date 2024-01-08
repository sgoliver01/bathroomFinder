//
//  LoginView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/8/24.
//

import Foundation
import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    
    var body: some View {
        NavigationStack {
            Image("toiletEmoji")
                .resizable()
                .scaledToFit()
                .padding()
            
            Group {
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
            }
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .padding(.horizontal)
            
            HStack {
                Button{
                    register()
                } label: {
                    Text("Sign Up")
                }
                .padding(.trailing)
                Button{
                    login()
                    
                } label: {
                    Text("Log In")
                }
                .padding(.leading)
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .padding(.top)
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        
    }
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {  //means if error returns non nil when logging in
                print("registration error: \(error.localizedDescription)")
                alertMessage = "registration error: \(error.localizedDescription)"
                showingAlert = true
            }
            print("registration success!")
            //TODO: load home view
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {  //means if error returns non nil when logging in
                print("login error: \(error.localizedDescription)")
                alertMessage = "login error: \(error.localizedDescription)"
                showingAlert = true
            }
            print("login successful")
            //TODO: load home view
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
