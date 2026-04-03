import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    @State private var currentPage: Int = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track your practice",
            subtitle: "Log sessions for every language and skill to see real progress over time.",
            icon: "clock.fill"
        ),
        OnboardingPage(
            title: "Grow your vocabulary",
            subtitle: "Save new words, mark mastered ones and keep your review list under control.",
            icon: "character.book.closed"
        ),
        OnboardingPage(
            title: "Stay motivated",
            subtitle: "Daily goals, stats and streak‑like visuals help you come back every day.",
            icon: "sparkles"
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.lexiBackground, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 420)
                
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.lexiCompleted : Color.gray.opacity(0.5))
                            .frame(width: index == currentPage ? 10 : 6, height: index == currentPage ? 10 : 6)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Skip") {
                        finish()
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(currentPage == pages.count - 1 ? "Get started" : "Next") {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            finish()
                        }
                    }
                    .foregroundColor(.lexiBackground)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.lexiCompleted)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.lexiPlanned, Color.lexiCompleted],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: .lexiPlanned.opacity(0.6), radius: 30, x: 0, y: 16)
                
                Image(systemName: page.icon)
                    .font(.system(size: 56))
                    .foregroundColor(.lexiBackground)
            }
            .padding(.top, 40)
            
            Text(page.title)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Text(page.subtitle)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private func finish() {
        hasSeenOnboarding = true
        isPresented = false
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
}

