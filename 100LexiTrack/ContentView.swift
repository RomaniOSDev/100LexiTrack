//
//  ContentView.swift
//  100LexiTrack
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LexiTrackViewModel()
    @State private var selectedTab = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            WordsView(viewModel: viewModel)
                .tabItem {
                    Label("Words", systemImage: "character.book.closed")
                }
                .tag(1)
            
            GoalsView(viewModel: viewModel)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(2)
            
            LanguagesView(viewModel: viewModel)
                .tabItem {
                    Label("Languages", systemImage: "flag.fill")
                }
                .tag(3)
            
            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.loadFromUserDefaults()
            if !hasSeenOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .accentColor(.lexiPlanned)
    }
}

