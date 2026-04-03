import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    @State private var showingAddSession = false
    @State private var selectedLanguage: LanguageStudy?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.lexiBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        statsCards
                        todayProgress
                        activeLanguages
                        recentSessions
                    }
                    .padding(.vertical)
                }
                
                Button {
                    showingAddSession = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(Color.lexiPlanned)
                        .shadow(radius: 8)
                }
                .padding()
            }
            .sheet(isPresented: $showingAddSession) {
                AddSessionView(viewModel: viewModel, isPresented: $showingAddSession)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Overview")
                .font(.largeTitle.bold())
                .foregroundColor(.lexiPlanned)
            
            Text("Track your language journey")
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding(.horizontal)
    }
    
    private var statsCards: some View {
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
                    title: "Today",
                    value: "\(viewModel.todayMinutes) min",
                    icon: "sun.max.fill",
                    color: .lexiCompleted
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var todayProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.todayMinutes)/\(viewModel.dailyGoal) min")
                    .foregroundColor(viewModel.todayMinutes >= viewModel.dailyGoal ? .lexiCompleted : .lexiPlanned)
                    .bold()
            }
            
            ProgressView(value: viewModel.todayProgress)
                .tint(viewModel.todayProgress >= 1.0 ? .lexiCompleted : .lexiPlanned)
                .background(Color.lexiPlanned.opacity(0.3))
                .frame(height: 8)
                .scaleEffect(y: 2)
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var activeLanguages: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active languages")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.activeLanguages) { language in
                        LanguagePill(language: language)
                            .onTapGesture {
                                selectedLanguage = language
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent sessions")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.horizontal)
            
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

