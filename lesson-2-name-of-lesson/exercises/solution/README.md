# Fetch and Display App - Solution Project

## Course Overview

This advanced iOS app development course introduces networking, concurrency, and API data handling with Swift and SwiftUI. The solution project, "Fetch and Display," showcases a fully functional app that fetches and displays user data from a public API.

## Project Description

The completed "Fetch and Display" app successfully retrieves user data from the Random User API and displays it in an intuitive user interface. The app leverages modern Swift features like async/await for network requests and uses SwiftUI for rendering the UI dynamically.

## Project Components

- `User.swift`: Defines a detailed user model including personal details, contact information, and media assets. This model is designed to parse JSON data seamlessly using Swift's `Codable` protocol.
- `UserResponse.swift`: Handles the JSON response from the API, focusing on extracting the `results` array which contains user data.
- `UserViewModel.swift`: Contains the logic for asynchronous data fetching from the API and updating the UI thread safely using `MainActor`.
- `ContentView.swift`: The main view of the app, which organizes user data into scrollable cards.
- `UserCard.swift`: A reusable view component that presents user details in a card format.

## Installation and Setup

1. **Clone the repository:** Download the project from the source repository.
2. **Open the project in Xcode:** Navigate to the project directory and open the `.xcodeproj` file.
3. **Run the app:** Select a suitable simulator or device in Xcode and run the app. Ensure it compiles and runs without errors, displaying the user data as expected.

## Features and Functionalities

- **Asynchronous Data Fetching:** Utilizes `URLSession` to perform network requests and handles responses with `JSONDecoder`.
- **Concurrency Management:** Ensures that all UI updates are performed on the main thread using `MainActor`, while network requests are handled in the background.
- **Dynamic UI with SwiftUI:** Uses `@State` and `@ObservableObject` to react to data changes and update the UI accordingly.
- **Customizable User Interface:** Each user card displays detailed information including a profile picture, name, email, and location. These cards are styled with SwiftUI's modifiers to enhance visual appeal.

## Testing the Application

- **Explore Various User Profiles:** Users can scroll through different profiles to see varied data loaded in real-time.
- **Test Different Network Scenarios:** Using Xcode’s network link conditioner, test how the app behaves under different network conditions.
- **UI Responsiveness:** Verify that the app responds well to different device orientations and screen sizes.

## Conclusion

This solution project demonstrates effective use of modern iOS development techniques. It serves as an excellent reference for students to understand and implement complex functionalities in an iOS app.

Feel free to explore the code and experiment with different aspects of the app to enhance your learning experience.
