//
//  LoginView.swift
//  bathroomFinder
//
//  Created by Sarah Oliver on 1/8/24.
//

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
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.3), .white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo
                VStack(spacing: 8) {
                    Text("🚽")
                        .font(.system(size: 60))
                    Text("Potty Spotter")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.blue.opacity(0.7))
                }
                
                Spacer()
                
                // Input fields
                VStack(spacing: 12) {
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .focused($focusField, equals: .email)
                        .onSubmit { focusField = .password }
                        .onChange(of: email, { enableButtons() })
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                      
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .focused($focusField, equals: .password)
                        .onSubmit { focusField = nil }
                        .onChange(of: password, { enableButtons() })
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal, 32)
                
                // Buttons
                HStack(spacing: 16) {
                    Button {
                        register()
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 2))
                    }
                    
                    Button {
                        login()
                    } label: {
                        Text("Log In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(buttonsDisabled)
                .opacity(buttonsDisabled ? 0.5 : 1)
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                presentSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            MainTabView()
        }
        
    }
    
    func enableButtons() {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passwordIsGood = password.count >= 6
        buttonsDisabled = !(emailIsGood && passwordIsGood)
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("registration error: \(error.localizedDescription)")
                alertMessage = "registration error: \(error.localizedDescription)"
                showingAlert = true
                return
            }
            print("registration success!")
            presentSheet = true
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("login error: \(error.localizedDescription)")
                alertMessage = "login error: \(error.localizedDescription)"
                showingAlert = true
                return
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

