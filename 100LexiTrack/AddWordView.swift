import SwiftUI

struct AddWordView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedLanguageId: UUID?
    @State private var word: String = ""
    @State private var translation: String = ""
    @State private var partOfSpeech: String = ""
    @State private var context: String = ""
    @State private var difficulty: Int = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                Form {
                    languageSection
                    wordSection
                    contextSection
                    difficultySection
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("New word")
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
                        saveWord()
                    }
                    .foregroundColor(.lexiBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.lexiPlanned)
                    .cornerRadius(8)
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            if selectedLanguageId == nil {
                selectedLanguageId = viewModel.activeLanguages.first?.id
            }
        }
    }
    
    private var languageSection: some View {
        Section(header: Text("Language").foregroundColor(.lexiPlanned)) {
            Picker("Language", selection: $selectedLanguageId) {
                ForEach(viewModel.activeLanguages) { language in
                    Text("\(language.language.flag) \(language.language.displayName)")
                        .tag(language.id as UUID?)
                }
            }
        }
    }
    
    private var wordSection: some View {
        Section(header: Text("Word").foregroundColor(.lexiPlanned)) {
            TextField("Word or phrase", text: $word)
                .foregroundColor(.white)
                .accentColor(.lexiPlanned)
            
            TextField("Translation", text: $translation)
                .foregroundColor(.white)
                .accentColor(.lexiPlanned)
            
            TextField("Part of speech (optional)", text: $partOfSpeech)
                .foregroundColor(.white)
                .accentColor(.lexiPlanned)
        }
    }
    
    private var contextSection: some View {
        Section(header: Text("Context").foregroundColor(.lexiPlanned)) {
            TextField("Usage example", text: $context)
                .foregroundColor(.white)
                .accentColor(.lexiPlanned)
        }
    }
    
    private var difficultySection: some View {
        Section(header: Text("Difficulty").foregroundColor(.lexiPlanned)) {
            Picker("Difficulty", selection: $difficulty) {
                ForEach(1...5, id: \.self) { level in
                    Text(String(repeating: "★", count: level)).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespaces).isEmpty &&
        !translation.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedLanguageId != nil
    }
    
    private func saveWord() {
        guard let languageId = selectedLanguageId, canSave else { return }
        
        viewModel.addWord(
            languageId: languageId,
            word: word.trimmingCharacters(in: .whitespaces),
            translation: translation.trimmingCharacters(in: .whitespaces),
            context: context.isEmpty ? nil : context,
            partOfSpeech: partOfSpeech.isEmpty ? nil : partOfSpeech,
            difficulty: difficulty
        )
        
        isPresented = false
    }
}

