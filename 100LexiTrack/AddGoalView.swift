import SwiftUI

struct AddGoalView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedLanguageId: UUID?
    @State private var title: String = ""
    @State private var targetValue: String = ""
    @State private var unit: String = "minutes"
    @State private var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var hasDeadline: Bool = false
    
    private let units = ["minutes", "words", "lessons"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                Form {
                    languageSection
                    titleSection
                    targetSection
                    deadlineSection
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("New goal")
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
                        saveGoal()
                    }
                    .foregroundColor(.lexiBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(canSave ? Color.lexiPlanned : Color.gray)
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
    
    private var titleSection: some View {
        Section(header: Text("Goal").foregroundColor(.lexiPlanned)) {
            TextField("Goal title (e.g. 500 new words)", text: $title)
                .foregroundColor(.white)
                .accentColor(.lexiPlanned)
        }
    }
    
    private var targetSection: some View {
        Section(header: Text("Target").foregroundColor(.lexiPlanned)) {
            HStack {
                TextField("Amount", text: $targetValue)
                    .keyboardType(.numberPad)
                    .foregroundColor(.white)
                    .accentColor(.lexiPlanned)
                
                Picker("Unit", selection: $unit) {
                    ForEach(units, id: \.self) { value in
                        Text(value.capitalized).tag(value)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private var deadlineSection: some View {
        Section(header: Text("Deadline").foregroundColor(.lexiPlanned)) {
            Toggle("Set deadline", isOn: $hasDeadline)
                .toggleStyle(SwitchToggleStyle(tint: .lexiPlanned))
            
            if hasDeadline {
                DatePicker("Date", selection: $deadline, displayedComponents: .date)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var canSave: Bool {
        guard let target = Int(targetValue), target > 0 else { return false }
        return !title.trimmingCharacters(in: .whitespaces).isEmpty && selectedLanguageId != nil
    }
    
    private func saveGoal() {
        guard canSave, let languageId = selectedLanguageId, let target = Int(targetValue) else { return }
        
        viewModel.addGoal(
            languageId: languageId,
            title: title.trimmingCharacters(in: .whitespaces),
            targetValue: target,
            unit: unit,
            deadline: hasDeadline ? deadline : nil
        )
        
        isPresented = false
    }
}

