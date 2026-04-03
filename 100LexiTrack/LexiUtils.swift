import Foundation

func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func formattedShortDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: date)
}

