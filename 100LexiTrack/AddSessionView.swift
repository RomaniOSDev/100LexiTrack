import SwiftUI

struct AddSessionView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedLanguageId: UUID?
    @State private var newLanguage: Language = .english
    @State private var activityType: ActivityType = .vocabulary
    @State private var duration: Int = 30
    @State private var newWords: Int = 0
    @State private var reviewedWords: Int = 0
    @State private var energyLevel: Int?
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                Form {
                    languageSection
                    activitySection
                    timeSection
                    progressSection
                    energySection
                    notesSection
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("New session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.lexiCompleted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSession()
                    }
                    .foregroundColor(.lexiBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.lexiPlanned)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var languageSection: some View {
        Section(header: Text("Language").foregroundColor(.lexiPlanned)) {
            Picker("Select language", selection: $selectedLanguageId) {
                ForEach(viewModel.activeLanguages) { language in
                    Text("\(language.language.flag) \(language.language.displayName)")
                        .tag(language.id as UUID?)
                }
                Text("Add new language").tag(nil as UUID?)
            }
            
            if selectedLanguageId == nil {
                Picker("New language", selection: $newLanguage) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text("\(language.flag) \(language.displayName)")
                            .tag(language)
                    }
                }
            }
        }
    }
    
    private var activitySection: some View {
        Section(header: Text("Activity").foregroundColor(.lexiPlanned)) {
            Picker("Type", selection: $activityType) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon).tag(type)
                }
            }
        }
    }
    
    private var timeSection: some View {
        Section(header: Text("Time").foregroundColor(.lexiPlanned)) {
            HStack {
                Text("Duration")
                Spacer()
                Picker("", selection: $duration) {
                    ForEach(Array(stride(from: 5, through: 180, by: 5)), id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private var progressSection: some View {
        Section(header: Text("Progress").foregroundColor(.lexiPlanned)) {
            HStack {
                Text("New words")
                Spacer()
                Stepper("\(newWords)", value: $newWords, in: 0...100)
                    .foregroundColor(.lexiCompleted)
            }
            
            HStack {
                Text("Reviews")
                Spacer()
                Stepper("\(reviewedWords)", value: $reviewedWords, in: 0...200)
                    .foregroundColor(.lexiPlanned)
            }
        }
    }
    
    private var energySection: some View {
        Section(header: Text("Energy").foregroundColor(.lexiPlanned)) {
            Picker("Energy level", selection: $energyLevel) {
                Text("—").tag(nil as Int?)
                ForEach(1...5, id: \.self) { level in
                    HStack {
                        Text(String(repeating: "⚡", count: level))
                    }
                    .tag(level as Int?)
                }
            }
        }
    }
    
    private var notesSection: some View {
        Section(header: Text("Notes").foregroundColor(.lexiPlanned)) {
            TextEditor(text: $notes)
                .frame(height: 100)
                .foregroundColor(.white)
                .accentColor(.lexiPlanned)
        }
    }
    
    private func saveSession() {
        var languageIdToUse: UUID?
        
        if let selected = selectedLanguageId {
            languageIdToUse = selected
        } else {
            viewModel.addLanguage(language: newLanguage, level: "A1", dailyGoal: 20, weeklyGoal: 20)
            languageIdToUse = viewModel.languages.last?.id
        }
        
        guard let languageId = languageIdToUse else {
            return
        }
        
        viewModel.addSession(
            languageId: languageId,
            activityType: activityType,
            duration: duration,
            wordsLearned: newWords,
            wordsReviewed: reviewedWords,
            energyLevel: energyLevel,
            notes: notes.isEmpty ? nil : notes
        )
        
        isPresented = false
    }
}

