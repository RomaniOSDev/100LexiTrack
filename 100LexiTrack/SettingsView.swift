import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                List {
                    Section(header: Text("Feedback")) {
                        Button {
                            rateApp()
                        } label: {
                            Label("Rate us", systemImage: "star.fill")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.lexiBackground)
                    }
                    
                    Section(header: Text("Legal")) {
                        Button {
                            openURL("https://www.termsfeed.com/live/9f3b2cb7-e78b-41b4-9d76-77c75dfbaf01")
                        } label: {
                            Label("Privacy Policy", systemImage: "lock.shield")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.lexiBackground)
                        
                        Button {
                            openURL("https://www.termsfeed.com/live/270853bc-11b7-49df-b0c8-4ffa051ba118")
                        } label: {
                            Label("Terms of Use", systemImage: "doc.text")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.lexiBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
    
    private func openURL(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

