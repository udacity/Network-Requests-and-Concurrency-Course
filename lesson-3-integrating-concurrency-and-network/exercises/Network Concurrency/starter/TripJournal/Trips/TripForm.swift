import SwiftUI

struct TripForm: View {
    /// Determines if the form is being used to add a new trip or edit an existing one.
    enum Mode: Hashable, Identifiable {
        case add

        var id: String {
            switch self {
            case .add:
                return "TripForm.add"
            }
        }
    }

    /// Describes validation errors that might occur locally in the form.
    struct ValidationError: LocalizedError {
        var errorDescription: String?

        static let emptyName = Self(errorDescription: "Please enter a name.")
        static let invalidDates = Self(errorDescription: "Start date should be before end date.")
    }

    init(mode: Mode, updateHandler: @escaping () -> Void) {
        self.mode = mode
        self.updateHandler = updateHandler

        switch mode {
        case .add:
            title = "Add Trip"
        }
    }

    private let mode: Mode
    private let updateHandler: () -> Void
    private let title: String

    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var isLoading = false
    @State private var error: Error?
    @State private var task: Task<Void, Never>? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.journalService) private var journalService

    // MARK: - Body

    var body: some View {
        NavigationView {
            form
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: toolbar)
                .alert(error: $error)
                .loadingOverlay(isLoading)
                .onDisappear {
                    task?.cancel()
                }
        }
    }

    // MARK: - Views

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Dismiss", systemImage: "xmark") {
                dismiss()
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Save") {
                switch mode {
                case .add:
                    task = Task {
                        await addTrip()
                    }
                }
            }
        }
    }

    private var form: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $name, prompt: Text("Amsterdam Adventure"))
            }
            Section("Dates") {
                DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                DatePicker("End date", selection: $endDate, displayedComponents: .date)
            }
        }
    }

    // MARK: - Networking

    private func validateForm() throws {
        if name.nonEmpty == nil {
            throw ValidationError.emptyName
        }
        if startDate > endDate {
            throw ValidationError.invalidDates
        }
    }

    private func addTrip() async {
        isLoading = true
        do {
            try validateForm()
            let request = TripCreate(name: name, startDate: startDate, endDate: endDate)
            try await journalService.createTrip(with: request)
            await MainActor.run {
                updateHandler()
                dismiss()
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
