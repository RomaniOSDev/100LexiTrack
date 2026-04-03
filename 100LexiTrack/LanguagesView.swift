import SwiftUI
import Charts

struct LanguagesView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    @State private var selectedLanguage: LanguageStudy?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                List {
                    ForEach(viewModel.languages) { language in
                        Button {
                            selectedLanguage = language
                        } label: {
                            HStack {
                                Text(language.language.flag)
                                VStack(alignment: .leading) {
                                    Text(language.language.displayName)
                                        .foregroundColor(.white)
                                    Text("Level \(language.level)")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.lexiBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Languages")
            .sheet(item: $selectedLanguage) { language in
                LanguageDetailView(viewModel: viewModel, language: language)
            }
        }
    }
}

struct LanguageDetailView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    let language: LanguageStudy
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        statsGrid
                        goalsCard
                        activityChart
                    }
                    .padding()
                }
            }
            .navigationTitle("\(language.language.flag) \(language.language.displayName)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(language.language.displayName)
                .font(.title.bold())
                .foregroundColor(.lexiPlanned)
            Text("Level \(language.level)")
                .foregroundColor(.white)
            if let goal = language.goal, !goal.isEmpty {
                Text(goal)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatCard(
                title: "Words",
                value: "\(viewModel.wordsCount(for: language.id))",
                icon: "character.book.closed",
                color: .lexiCompleted
            )
            
            StatCard(
                title: "Mastered",
                value: "\(viewModel.masteredCount(for: language.id))",
                icon: "checkmark.seal.fill",
                color: .lexiCompleted
            )
            
            StatCard(
                title: "Minutes",
                value: "\(viewModel.minutesForLanguage(language.id))",
                icon: "clock.fill",
                color: .lexiPlanned
            )
            
            StatCard(
                title: "Level",
                value: language.level,
                icon: "chart.bar.fill",
                color: .lexiPlanned
            )
        }
    }
    
    private var goalsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Goals")
                .foregroundColor(.lexiPlanned)
                .font(.headline)
            
            let todayMinutes = viewModel.todayMinutesForLanguage(language.id)
            
            HStack {
                Text("Daily")
                    .foregroundColor(.white)
                Spacer()
                Text("\(todayMinutes)/\(language.dailyGoalMinutes) min")
                    .foregroundColor(todayMinutes >= language.dailyGoalMinutes ? .lexiCompleted : .lexiPlanned)
            }
            
            ProgressView(value: min(Double(todayMinutes) / Double(language.dailyGoalMinutes), 1.0))
                .tint(.lexiCompleted)
            
            let weeklyWords = viewModel.weeklyWordsForLanguage(language.id)
            
            HStack {
                Text("Words this week")
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(weeklyWords)/\(language.weeklyGoalWords)")
                    .foregroundColor(weeklyWords >= language.weeklyGoalWords ? .lexiCompleted : .lexiPlanned)
            }
            
            ProgressView(value: min(Double(weeklyWords) / Double(language.weeklyGoalWords), 1.0))
                .tint(.lexiCompleted)
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var activityChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity")
                .foregroundColor(.lexiPlanned)
                .font(.headline)
            
            Chart {
                ForEach(viewModel.weeklyActivity(for: language.id), id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(Color.lexiPlanned)
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.1))
        .cornerRadius(12)
    }
}

