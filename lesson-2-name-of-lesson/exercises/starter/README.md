# Fetch and Display App

## Course Description

This course focuses on crucial aspects of iOS apps such as networking and concurrency, including sending API requests and responses, parsing and displaying fetched data, and handling authentication with Apple authentication frameworks. The primary tools and languages used are Swift and SwiftUI, with a strong focus on managing concurrency and incorporating Apple's latest developer guidelines from 2023.

## Overview of the App

The "Fetch and Display" app retrieves user data from a public API and displays it in a structured format. This project serves as a practical exercise for implementing and understanding async/await in network operations and handling JSON data in Swift.

## Project Structure

- `User.swift`: Defines the user model, including properties like name, email, date of birth, and associated images.
- `UserResponse.swift`: Handles the JSON structure returned from the Random User API, crucial for decoding the data.
- `UserViewModel.swift`: Manages fetching and storing user data from the API.
- `ContentView.swift`: Contains the SwiftUI views for displaying user data in a scrollable list format.
- `UserCard.swift`: A subcomponent of ContentView that renders details of each user in a card format.

## Getting Started

1. **Clone the repository:** Ensure you have the project cloned from the provided Git repository.
2. **Open the project in Xcode:** Navigate to the directory where the project is stored and open the `.xcodeproj` file.
3. **Run the application:** Select a suitable simulator or device and run the application. Ensure that the app builds successfully and you can see the user data being fetched and displayed.

## Exercises

The following tasks are designed to enhance your understanding and help you apply what you've learned:

1. **Complete the Networking Layer:**
   - Implement the URLSession data task within `UserViewModel.swift` to fetch user data.
   - Decode the fetched JSON into `UserResponse` and update the `users` array.

2. **Enhance the User Model:**
   - Complete the properties in `User.swift` based on the JSON data.
   - Implement computed properties as required.

3. **Build the UI Components:**
   - In `ContentView.swift`, implement the logic to check if user data is available and display it.
   - Add necessary UI components in `UserCard.swift` to display the user's picture, name, and other details.

## Expected Outcomes

By the end of this project, you should be able to:
- Fetch data from a REST API using Swift.
- Parse JSON data and convert it into model objects.
- Display the fetched data dynamically in a user-friendly format using SwiftUI.
