import SwiftUI

struct AddButton: View {
      let action: () -> Void
      // Initialize NetworkMonitor instance to observe network connection status

      var body: some View {
          Button(
              action: action,
              label: {
                  Image(systemName: "plus")
                      .resizable()
                      .bold()
                      .padding(10)
                      .frame(width: 35, height: 35)
              }
          )
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.circle)
          .shadow(radius: 25)
          // Disable the button when there is no network connection
          // Adjust button opacity when there is no network connection
      }
}
