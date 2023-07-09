# Flarum iOS App Unofficial Demo - An App Demo Developed with SwiftUI and Flarum REST API

![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-blue) ![Language](https://img.shields.io/badge/language-Swift%205.5-orange) ![License](https://img.shields.io/badge/license-MIT-green)

This is a [flarum](https://flarum.org/) iOS app demo developed with SwiftUI and Flarum REST API, aiming to provide a convenient and fast way to view, post, and reply to discussions on Flarum using an iPhone.

_*Please note do not use com.flarum or any similar wording that could imply the app is an official product of the [flarum](https://flarum.org/) team. Instead, you can use com.yourname.flarumDemo or any other alternative that does not include flarum's trademark. Additionally, it is important to refrain from using flarum's logo when creating and publishing apps._

## System Requirements

- iOS 16 and above

## Features

- Native iOS interface with a clean UI and intuitive user experience
- Convenient and fast browsing, posting, and replying to discussions on Flarum using an iPhone

## Currently Supported Features

1. Login using username and password, with an option to remember login credentials
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/d18b86f8-3c4a-4b49-b926-fc489613172f" alt="LoginPage" width="180">
</div>

2. Browse all discussions on Flarum, with pagination support and display of pinned discussions
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/4a9b9348-8155-4ee7-b6f7-2ca21240f07c" alt="HomePage" width="180">
</div>

3. View replies to discussions, with the ability to load more replies for discussions with more than 20 replies
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/adc4b99d-2e4b-411a-ad5c-7d74f10ed166" alt="DiscussionPage" width="180">
</div>

4. Support for tags, allowing users to browse discussions by tags (compatible with Flarum installations with the Tags extension disabled)
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/a3e4ddd1-7a1f-4e60-80ca-279e1860e2ec" alt="TagsPage" width="180">
</div>
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/ecd34afa-477d-4b78-b9e6-de78a4898b84" alt="TagsPage" width="180">
</div>

5. Create new discussions and reply to existing discussions
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/f189906d-0df4-4184-bea3-5ff8c41613f5" alt="NewDiscussion" width="180">
</div>
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/d2f82b58-e45b-4c5b-ab1d-1dcf019de766" alt="NewReply" width="180">
</div>

6. User profile page with the ability to view the profile of users who replied to a discussion
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/81fee594-be9c-481a-a267-e9288cbdf1f5" alt="ProfilePage" width="180">
</div>

7. Dark mode support for iOS
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/6d516eef-5b3e-4419-a156-c38aef5aa0ad" alt="DarkMode2" width="180">
</div>
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/1133950b-6c0d-4a13-a823-9e30d3868547" alt="DarkMode" width="180">
</div>

8. Check all your comment in Notification Center
<div align="left">
  <img src="https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo/assets/96178954/1133950b-6c0d-4a13-a823-9e30d3868547" alt="DarkMode" width="180">
</div>


## Customization

If you want to adapt the app to your own Flarum installation, follow these steps:

1. Open the file `Flarum iOS App/LiangJianForum/View/Helper/AppSettings.swift`.
2. Replace the values of `FlarumUrl` and `FlarumName` in the following code snippet with the URL and name of your Flarum installation:

```
swiftCopy code
@Published var FlarumUrl = "https://discuss.flarum.org"
@Published var FlarumName = "Flarum"
```

- Save the file to customize the app for your Flarum installation.

## Running the App

- Running on the Xcode Simulator:
  - Simply run the project in Xcode.
- Installing on an iPhone:
  - Enable developer mode on your iPhone.
  - Configure and sign in with your own Apple ID in Xcode.
  - In the "Signing & Capabilities" tab, configure your own Team information and Bundle Identifier.
  - Click run to install the app on your iPhone (or iPad).

## License

This project is licensed under the MIT License. 

Contributions, issues, and feedback are welcome!
