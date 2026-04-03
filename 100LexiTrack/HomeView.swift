import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    @State private var showingAddSession = false
    @State private var showingAddWord = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        todaySummary
                        quickActions
                        statsRow
                        activeLanguages
                        recentSessions
                    }
                    .padding(.vertical)
                }
            }
            .sheet(isPresented: $showingAddSession) {
                AddSessionView(viewModel: viewModel, isPresented: $showingAddSession)
            }
            .sheet(isPresented: $showingAddWord) {
                AddWordView(viewModel: viewModel, isPresented: $showingAddWord)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greetingText)
                .foregroundColor(.lexiPlanned)
                .font(.largeTitle.bold())
            
            Text("Stay on track with your languages")
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding(.horizontal)
    }
    
    private var todaySummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today focus")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Text("\(viewModel.todayMinutes)/\(max(viewModel.dailyGoal, 1)) min")
                    .foregroundColor(viewModel.todayMinutes >= viewModel.dailyGoal && viewModel.dailyGoal > 0 ? .lexiCompleted : .lexiPlanned)
                    .bold()
            }
            
            ProgressView(value: viewModel.dailyGoal > 0 ? viewModel.todayProgress : 0)
                .tint(viewModel.todayProgress >= 1.0 && viewModel.dailyGoal > 0 ? .lexiCompleted : .lexiPlanned)
                .background(Color.lexiPlanned.opacity(0.3))
                .frame(height: 8)
                .scaleEffect(y: 2)
                .cornerRadius(4)
            
            if viewModel.dailyGoal > 0 {
                let remaining = max(viewModel.dailyGoal - viewModel.todayMinutes, 0)
                Text(remaining > 0 ? "\(remaining) minutes to reach your daily goal" : "Daily goal reached — great job!")
                    .foregroundColor(.gray)
                    .font(.caption)
            } else {
                Text("Set daily goals for each language to see progress here.")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.12))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var quickActions: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                title: "Add session",
                icon: "plus.circle.fill",
                color: .lexiPlanned
            ) {
                showingAddSession = true
            }
            
            QuickActionButton(
                title: "Add word",
                icon: "character.book.closed",
                color: .lexiCompleted
            ) {
                showingAddWord = true
            }
            
            QuickActionButton(
                title: "Review",
                icon: "arrow.triangle.2.circlepath",
                color: .lexiPlanned.opacity(0.8)
            ) {
                // Could navigate to Words tab with review filter
                viewModel.selectedFilter = .review
            }
        }
        .padding(.horizontal)
    }
    
    private var statsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Languages",
                    value: "\(viewModel.activeLanguages.count)",
                    icon: "flag.fill",
                    color: .lexiPlanned
                )
                
                StatCard(
                    title: "Words",
                    value: "\(viewModel.totalWords)",
                    icon: "character.book.closed",
                    color: .lexiCompleted
                )
                
                StatCard(
                    title: "Time total",
                    value: "\(viewModel.totalMinutes) min",
                    icon: "clock.fill",
                    color: .lexiPlanned
                )
                
                StatCard(
                    title: "Sessions",
                    value: "\(viewModel.totalSessions)",
                    icon: "rectangle.stack.fill",
                    color: .lexiPlanned
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var activeLanguages: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Active languages")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.activeLanguages.isEmpty {
                Text("Add your first language when creating a session.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.activeLanguages) { language in
                            LanguagePill(language: language)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent sessions")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.recentSessions.isEmpty {
                Text("Your recent study sessions will appear here.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.bottom)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.recentSessions) { session in
                            SessionCard(session: session)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        case 18..<23: return "Good evening"
        default: return "Welcome back"
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundColor(.lexiBackground)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(color)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

