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
    enum Field {
        case email, password
    }
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonsDisabled = true
    @State private var presentSheet = false
    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack {
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
                    .focused($focusField, equals: .email) //bound to our email field
                    .onSubmit {
                        focusField = .password
                    } //moves you to password
                    .onChange(of: email, {
                        enableButtons()
                    })
                  
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focusField, equals: .password) //bound to our password field
                    .onSubmit {
                        focusField = nil //will dismiss the keyboard
                    }
                    .onChange(of: password, {
                        enableButtons()
                    })
                   
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
            .disabled(buttonsDisabled)
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .padding(.top)
           
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            //if klogged in when app runs, navigate to the new screen and skip login screen
            if Auth.auth().currentUser != nil {
                print("login successful")
                presentSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            HomeView()
        }
        
    }
    
    func enableButtons() {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passwordIsGood = password.count >= 6
        buttonsDisabled = !(emailIsGood && passwordIsGood)
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {  //means if error returns non nil when logging in
                print("registration error: \(error.localizedDescription)")
                alertMessage = "registration error: \(error.localizedDescription)"
                showingAlert = true
            }
            print("registration success!")
            presentSheet = true
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
            presentSheet = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

