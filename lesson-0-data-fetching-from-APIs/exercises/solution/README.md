In this exercise you:

Setup a new SwiftUI Project
Modified a ContentView to display some user details.
Defined a UserViewModel that contains the logic for fetching data from the API
Wrote the logic to make the API request.
Exercise Solution
Download the Xcode project exercise solution and compare it to your work. An explanation of a solution for each of the steps is below:

1.Adding user details to the ContentView

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Name:")
                .font(.title)
                .padding()
            Text("Email:")
                .font(.title)
                .padding()
        }
        .padding()
    }
}
2. Define the UserViewModel

In UserViewModel.swift define a class that conforms to ObservableObject.

import Foundation
import Combine

class UserViewModel: ObservableObject {
   @Published var name: String = ""
   @Published var email: String = ""

    // Fetching logic will go here
}
3. Logic for API request to fetch data

In UserViewModel.swift, we created a method called fetchData() that will handle the API request. This method will be responsible for initiating the data fetch from the API. It includes a struct for the URL with the value of the API we are fetching data from: URL(string: "https://randomuser.me/api/")

func fetchData() {
    // Create a URL object
    guard let url = URL(string: "https://randomuser.me/api/") else {
        print("Invalid URL")
        return
    }

    // Create a data task
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        // Code to handle response will go here
    }

    // Start the data task
    task.resume()
}
