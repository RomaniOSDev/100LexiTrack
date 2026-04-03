import SwiftUI

struct ResourcesView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    @State private var showingAddResource = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.lexiBackground.ignoresSafeArea()
                
                Group {
                    if viewModel.resources.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 40))
                                .foregroundColor(.lexiPlanned)
                            Text("No resources yet")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Add books, apps, podcasts and more.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        List {
                            ForEach(viewModel.resources) { resource in
                                ResourceRow(resource: resource)
                                    .listRowBackground(Color.lexiBackground)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                
                Button {
                    showingAddResource = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(Color.lexiPlanned)
                        .shadow(radius: 8)
                }
                .padding()
            }
            .navigationTitle("Resources")
        }
    }
}

struct ResourceRow: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(resource.title)
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Text(resource.type)
                    .foregroundColor(.lexiPlanned)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.lexiPlanned.opacity(0.15))
                    .cornerRadius(8)
            }
            
            Text(resource.languageName)
                .foregroundColor(.gray)
                .font(.caption)
            
            if let notes = resource.notes, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .lineLimit(2)
            }
            
            ProgressView(value: resource.progress)
                .tint(.lexiCompleted)
        }
        .padding(.vertical, 4)
    }
}

