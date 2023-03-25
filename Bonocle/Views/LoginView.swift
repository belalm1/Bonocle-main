//
//  LoginView.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import SwiftUI
import Firebase
//import FirebaseStorage

struct LoginView: View {
    
    let didCompleteLogin: () -> ()
    
    @State var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var fname = ""
    @State private var lname = ""
    @State private var role = "Student"
    @State private var StatusMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("Bonocle V2")
                        .bold()
                        .foregroundColor(.white)
                        .padding(20)
                        .font(.custom(
                            "Verdana",
                            fixedSize: 30))
                    
                }
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Group {
                            TextField("First Name", text: $fname)
                            TextField("Last Name", text: $lname)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                            Picker("Role", selection: $role) {
                                Text("Teacher").tag("Teacher")
                                Text("Student").tag("Student")
                            }
                            .pickerStyle(DefaultPickerStyle())
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .font(.custom(
                            "Verdana",
                            fixedSize: 12))
                        
                        
                        Button {
                            handleAction()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Create Account")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .font(.custom(
                                        "Verdana",
                                        fixedSize: 18))
                                Spacer()
                            }.background(Color.green)
                            
                        }.cornerRadius(10).alert("This email is already registered", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                    }else {
                        
                        Group {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .font(.custom(
                            "Verdana",
                            fixedSize: 12))
                        
                        Button {
                            loginUser()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Login")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .font(.custom(
                                        "Verdana",
                                        fixedSize: 18))
                                Spacer()
                            }.background(Color.green)
                            
                        }.cornerRadius(10)
                            .alert("Wrong Password", isPresented: $showingAlert) {
                                Button("OK", role: .cancel) { }
                            }
                    }
                    
                    
                }
                .padding()
                
            } //End ScrollView
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .background(
                LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
            
        }// End Navigation
    }
    
    private func loginUser() {
        showingAlert = false
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                showingAlert = true
                
                // print("Failed to login user:", err)
                self.StatusMessage = "Failed to login user: \(err)"
                return
            }
            
            //print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.StatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLogin()
        }
    }
    
    private func handleAction() {
        createNewAccount()
    }
    
    private func createNewAccount() {
        showingAlert = false
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                showingAlert = true
                //print("Failed to create user:", err)
                self.StatusMessage = "Failed to create user: \(err)"
                return
            }
            
            //print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.StatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.storeUserInformation()
        }
    }
    
    private func storeUserInformation() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["fname": self.fname, "lname": self.lname, "email": self.email, "uid": uid, "role": role]
        Firestore.firestore().collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.StatusMessage = "\(err)"
                    return
                }
                
                print("Success")
            }
    }
}
