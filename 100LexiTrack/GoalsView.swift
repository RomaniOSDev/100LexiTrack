import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.lexiBackground.ignoresSafeArea()
                
                Group {
                    if viewModel.goals.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "target")
                                .font(.system(size: 40))
                                .foregroundColor(.lexiPlanned)
                            Text("No goals yet")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Create your first goal to stay motivated.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        List {
                            ForEach(viewModel.goals) { goal in
                                GoalRow(goal: goal)
                                    .listRowBackground(Color.lexiBackground)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                
                Button {
                    showingAddGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(Color.lexiPlanned)
                        .shadow(radius: 8)
                }
                .padding()
            }
            .navigationTitle("Goals")
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(viewModel: viewModel, isPresented: $showingAddGoal)
            }
        }
    }
}

struct GoalRow: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(goal.title)
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                if goal.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.lexiCompleted)
                }
            }
            
            Text(goal.languageName)
                .foregroundColor(.gray)
                .font(.caption)
            
            let progress = min(Double(goal.currentValue) / Double(max(goal.targetValue, 1)), 1.0)
            
            HStack {
                Text("\(goal.currentValue)/\(goal.targetValue) \(goal.unit)")
                    .foregroundColor(.lexiPlanned)
                    .font(.caption)
                Spacer()
            }
            
            ProgressView(value: progress)
                .tint(goal.isCompleted ? .lexiCompleted : .lexiPlanned)
        }
        .padding(.vertical, 4)
    }
}

