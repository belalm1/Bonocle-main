# Bonocle: Video Conferencing App

1. Introduction
Welcome to the Official User Manual Guide of the Bonocle Video Application 1.0. This document will serve as a guide for Bonocle’s development team to understand how to deploy and configure the application environment in order to be able to run it.

2. Pre-requisites
2.1 Setting up the environment
Before you begin the installation process, please ensure that you have the following prerequisites:
A Mac computer running macOS Ventura 10.15.4 or later
An Apple ID
Internet connectivity
A Firebase account

2.2 Installing Xcode
This application was developed on the latest version of Xcode, using Xcode 14 beta. Please make sure you are on the latest version of Xcode in order to run this application

3. Downloading the Package SDK’s
3.1 Installing Firebase Packages
Firebase is a backend service that provides features such as authentication, real-time messaging, and cloud storage. Our app uses Firebase to store user data and manage authentication. Follow these steps to download and install Firebase package dependency:
Open Xcode.
Click on "File" in the top menu bar, then select "Swift Packages" and then "Add Package Dependency".
Insert this link https://github.com/firebase/firebase-ios-sdk in the search bar then press ‘Download’
After the package is configured, pick the following packages:
FirebaseAuth 
FirebaseAuthCombine 
FirebaseDatabase 
FirebaseDatabaseSwift 
FirebaseFirestore 
FirebaseFirestoreCombine 
FirebasteFirestoreSwift 
FirebaseStorage
Now you have the Firebase packages installed

3.2 Installing WebRTC Packages
WebRTC (Web Real-Time Communication) is a free, open-source project that provides web browsers and mobile applications with real-time communication (RTC) capabilities such as Video and Audio exchange. To download this package on the application, follow these steps:
Open Xcode.
Click on "File" in the top menu bar, then select "Swift Packages" and then "Add Package Dependency".
Insert this link https://github.com/stasel/WebRTC-iOS in the search bar then press ‘Download’
Make sure you are downloading the latest version 110.0.0
Please note that if the Package Dependency download fails, please add ‘.git’ at the end of the URL.
Now you have the WebRTC iOS packages installed

4. Incorporating the Firebase Firestore Database into the Application
4.1 Downloading the GoogleService-Info.plist from Firebase
A GoogleService-Info.plist file contains all of the information required by the Firebase iOS SDK to connect to your Firebase project. To download the GoogleService-Info.plist file from Firebase, follow these steps:
Sign in to your Firebase account.
Click on the project titled ‘Bonocle’ 
In the project settings page, click on the "General" tab.
Scroll down to the "Your apps" section and click on the ‘Bonocle’ app.
In the "Your iOS apps" page, scroll down to the "Your app" section.
Click on the "Download GoogleService-Info.plist" button to download the file.

4.2 Adding the GoogleService-Info.plist to the Project
	Now that we have downloaded the GoogleService-Info.plist from Firebase, we need to add this file to our Bonocle project. To do so, follow these steps:
Open the Bonocle Video application
Drag the GoogleService-Info.plist file and drop it in the Project Navigator. 

Now that you have conducted all the steps above, the application should be ready to run!
