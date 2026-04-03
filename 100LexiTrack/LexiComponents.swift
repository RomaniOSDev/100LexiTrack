import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.35), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 26, height: 26)
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold))
                }
                
                Text(title.uppercased())
                    .foregroundColor(.gray)
                    .font(.caption2)
                    .tracking(0.8)
            }
            
            Text(value)
                .foregroundColor(.white)
                .font(.title2.bold())
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.03),
                    color.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.35), lineWidth: 0.8)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 8)
    }
}

struct LanguagePill: View {
    let language: LanguageStudy
    
    var body: some View {
        HStack(spacing: 6) {
            Text(language.language.flag)
            VStack(alignment: .leading, spacing: 2) {
                Text(language.language.displayName)
                    .font(.subheadline.weight(.semibold))
                Text("Level \(language.level)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color.lexiPlanned.opacity(0.35), Color.lexiBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.lexiPlanned.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
    }
}

struct SessionCard: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.lexiPlanned.opacity(0.4), Color.lexiBackground],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: session.activityType.icon)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.languageName)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text(session.activityType.rawValue)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.duration) min")
                    .foregroundColor(.lexiCompleted)
                    .bold()
                
                Text(formattedTime(session.date))
                    .foregroundColor(.gray)
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.03), Color.lexiBackground.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 6)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.lexiBackground.opacity(0.7)
                    }
                }
            )
            .foregroundColor(isSelected ? .lexiBackground : color)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(color.opacity(isSelected ? 0.0 : 0.8), lineWidth: 1)
            )
            .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 6, x: 0, y: 4)
    }
}

