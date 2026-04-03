import SwiftUI

struct WordsView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    @State private var showingAddWord = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.lexiBackground.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 8) {
                    header
                    filters
                    wordList
                }
                
                Button {
                    showingAddWord = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(Color.lexiPlanned)
                        .shadow(radius: 8)
                }
                .padding()
            }
            .sheet(isPresented: $showingAddWord) {
                AddWordView(viewModel: viewModel, isPresented: $showingAddWord)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("My words")
                .font(.largeTitle.bold())
                .foregroundColor(.lexiPlanned)
            
            Text("Manage and review vocabulary")
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedFilter == nil,
                    color: .lexiPlanned
                )
                .onTapGesture { viewModel.selectedFilter = nil }
                
                FilterChip(
                    title: "New",
                    isSelected: viewModel.selectedFilter == .new,
                    color: .lexiPlanned
                )
                .onTapGesture { viewModel.selectedFilter = .new }
                
                FilterChip(
                    title: "In review",
                    isSelected: viewModel.selectedFilter == .review,
                    color: .lexiPlanned
                )
                .onTapGesture { viewModel.selectedFilter = .review }
                
                FilterChip(
                    title: "Mastered",
                    isSelected: viewModel.selectedFilter == .mastered,
                    color: .lexiCompleted
                )
                .onTapGesture { viewModel.selectedFilter = .mastered }
            }
            .padding(.horizontal)
        }
    }
    
    private var wordList: some View {
        Group {
            if viewModel.filteredWords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "character.book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.lexiPlanned)
                    Text("No words yet")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Add your first word to start tracking vocabulary.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredWords) { word in
                            WordCard(
                                word: word,
                                onMastered: {
                                    viewModel.markAsMastered(word)
                                },
                                onDelete: {
                                    viewModel.deleteWord(word)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct WordCard: View {
    let word: Word
    let onMastered: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text(word.translation)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                if let context = word.context, !context.isEmpty {
                    Text(context)
                        .foregroundColor(.lexiPlanned)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= word.difficulty ? "circle.fill" : "circle")
                            .font(.system(size: 6))
                            .foregroundColor(i <= word.difficulty ? .lexiPlanned : .gray)
                    }
                }
                
                HStack(spacing: 10) {
                    Button {
                        onMastered()
                    } label: {
                        Image(systemName: word.mastered ? "checkmark.seal.fill" : "checkmark.circle")
                            .foregroundColor(.lexiCompleted)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.9))
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.04), Color.lexiBackground.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(word.mastered ? Color.lexiCompleted.opacity(0.7) : Color.lexiPlanned.opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 6)
    }
}

