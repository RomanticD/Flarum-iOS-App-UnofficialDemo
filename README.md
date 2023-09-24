# Flarum iOS App - An App Demo Developed with SwiftUI and Flarum REST API

![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-blue) ![Language](https://img.shields.io/badge/language-Swift%205.5-orange) ![License](https://img.shields.io/badge/license-MIT-green)

This is a Flarum iOS App Demo developed with SwiftUI and Flarum REST API, aiming to provide a convenient and fast way to view, post, and reply to discussions on your own Flarum using an iPhone.

_*Please note do not use com.flarum or any similar wording that could imply the app is an official product of the [Flarum](https://flarum.org/) team._ 

## 🍿 System Requirements

- iOS 16.0 + 

## :gear: Customization

If you want to adapt the app to your own Flarum installation, follow these steps:

1. Open the file `Flarum iOS App/LiangJianForum/View/Helper/AppSettings.swift`.
2. Replace the values of `FlarumUrl` and `FlarumName` in the following code snippet with the URL and name of your Flarum installation:

```
@Published var FlarumUrl = "https://discuss.flarum.org"
@Published var FlarumName = "Your_Flarum_Name"
@Published var FlarumToken = "XXXXXXXXXXXXXXXXXX" //Your Flarum API key, registration view required
```

- Save the file to customize the app for your Flarum installation.

## :rocket: Running the App

- Running on the Xcode Simulator:
  - Simply run the project in Xcode.
- Installing on an iPhone:
  - Enable developer mode on your iPhone.
  - Configure and sign in with your own Apple ID in Xcode.
  - In the "Signing & Capabilities" tab, configure your own Team information and Bundle Identifier.
  - Click run to install the app on your iPhone (or iPad).

## 🎉 Features

![overview](https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/786eb27d-fe44-4629-8e05-f58f906efec8)
![dark mode](https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/b38783be-24cf-46e2-934b-8b52cd169cc8)

- Native iOS interface with a clean UI and intuitive user experience
- Convenient and fast browsing, posting, and replying to discussions on Flarum using an iPhone


  - Login using username and password & Registration
  - Extention support for **Level Rank, BestAnswer, Poll, Money, Check In, User Badge** and more
  - check discussions and comments with more sort options
  - Support for tags, allowing users to browse discussions by tags
  - Create new discussions with tags and reply to existing discussions
  - Exquisite Personal Homepage
  - Dark mode support
  - Check your comments and likes in Notification Center
