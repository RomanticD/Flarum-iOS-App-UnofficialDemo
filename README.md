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
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/e68cd517-6edf-4f95-801e-85be565415b3" alt="LoginPage" width="250">
</div>

2. Browse all discussions on Flarum, with pagination support and display of pinned discussions
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/7ed30688-7ac9-4339-bce5-23feb5be7559" alt="HomePage" width="250">
</div>

3. View replies to discussions, with the ability to load more replies for discussions with more than 20 replies
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/4836a227-a5af-4df4-8c5d-94352c691b6f" alt="DiscussionPage" width="250">
</div>

4. Support for tags, allowing users to browse discussions by tags (compatible with Flarum installations with the Tags extension disabled)
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/23d8893c-72dc-4c59-85ea-2911ca458748" alt="TagsPage" width="250">
</div>

5. Create new discussions and reply to existing discussions
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/68d0fd95-a899-4980-83b2-7d5634d6341b" alt="NewDiscussion" width="250">
</div>
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/3e29e712-27e0-4bee-8891-e945b639dcab" alt="NewReply" width="250">
</div>

6. User profile page with the ability to view the profile of users who replied to a discussion
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/d7e9fb05-c995-49e7-a1ee-69ca5de148d6" alt="ProfilePage" width="250">
</div>

7. Dark mode support for iOS
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/bb37340f-84ee-4ecc-8df2-b9363bf62c5e" alt="DarkMode2" width="250">
</div>
<div align="left">
  <img src="https://github.com/RomanticD/FlarumiOSAppSwiftUI/assets/96178954/0a2018ff-c112-4fd1-b49e-9d6ed12633bf" alt="DarkMode" width="250">
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
