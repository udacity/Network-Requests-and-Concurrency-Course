### Exercise: Persisting Data Offline

## Overview

This exercise is a continuation of the TripJournal app. You will implement data persistence using `UserDefaults` to store fetched data locally for offline access. Additionally, you will integrate network monitoring to inform the user when they are viewing cached data and optimize network calls based on network conditions.

#### Objectives
- Choose a persistence solution (e.g., UserDefaults) to store fetched data locally for offline access.
- Ensure all actions are persistently stored and reflected in API data upon app re-launch.
- Use `NWPathMonitor` to inform the user when we are using the cache data (an alert or something).
- Optimize network calls based on network conditions.

#### Instructions

1. **Starter:**
   - Navigate to the starter folder and open `TripJournal.xcodeproj`.
   - Your task is to fill in the missing code as indicated by comments in the Swift files (`TripCacheManager.swift`, `NetworkMonitor.swift`, `JournalServiceLive.swift`, `TripList.swift`, `AddButton.swift`).

2. **Solution:**
   - After you complete the exercise, or if you need to check your work, you can find the complete code in the solution folder.
   - Compare your solution with the completed code to understand different approaches or to debug any issues you encountered.

#### Setup
- Ensure you have the latest version of Xcode installed on your Mac.
- Open the Xcode project from the `starter` folder to begin the exercise.

Feel free to reach out if you encounter any difficulties or have questions regarding the exercises.

Happy coding!
