import Foundation
import SwiftUI

// MARK: - Colors

extension Color {
    // #1A2C38 — main background
    static let lexiBackground = Color(red: 0.102, green: 0.173, blue: 0.220) // #1A2C38
    static let lexiPlanned = Color(red: 0.078, green: 0.459, blue: 0.882) // #1475E1
    static let lexiCompleted = Color(red: 0.086, green: 1.0, blue: 0.086) // #16FF16
}

// MARK: - Models

enum Language: String, CaseIterable, Codable {
    case english = "Английский"
    case spanish = "Испанский"
    case french = "Французский"
    case german = "Немецкий"
    case italian = "Итальянский"
    case portuguese = "Португальский"
    case chinese = "Китайский"
    case japanese = "Японский"
    case korean = "Корейский"
    case russian = "Русский"
    case ukrainian = "Украинский"
    case polish = "Польский"
    case turkish = "Турецкий"
    case arabic = "Арабский"
    case hindi = "Хинди"
    case greek = "Греческий"
    case other = "Другой"
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .russian: return "🇷🇺"
        case .ukrainian: return "🇺🇦"
        case .polish: return "🇵🇱"
        case .turkish: return "🇹🇷"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        case .greek: return "🇬🇷"
        case .other: return "🌐"
        }
    }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .russian: return "Russian"
        case .ukrainian: return "Ukrainian"
        case .polish: return "Polish"
        case .turkish: return "Turkish"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        case .greek: return "Greek"
        case .other: return "Other"
        }
    }
}

enum ActivityType: String, CaseIterable, Codable {
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case listening = "Listening"
    case speaking = "Speaking"
    case reading = "Reading"
    case writing = "Writing"
    case lesson = "Lesson"
    case review = "Review"
    
    var icon: String {
        switch self {
        case .vocabulary: return "book"
        case .grammar: return "pencil"
        case .listening: return "headphones"
        case .speaking: return "mic"
        case .reading: return "text.book.closed"
        case .writing: return "pencil.and.outline"
        case .lesson: return "studentdesk"
        case .review: return "repeat"
        }
    }
}

struct LanguageStudy: Identifiable, Codable {
    let id: UUID
    var language: Language
    var level: String // A1, A2, B1, B2, C1, C2
    var startDate: Date
    var goal: String? // study goal
    var isActive: Bool
    var dailyGoalMinutes: Int // daily minutes goal
    var weeklyGoalWords: Int // weekly words goal
}

struct Word: Identifiable, Codable {
    let id: UUID
    var languageId: UUID
    var languageName: String
    var word: String
    var translation: String
    var context: String? // usage example
    var partOfSpeech: String? // noun, verb, etc.
    var difficulty: Int // 1-5
    var dateAdded: Date
    var lastReviewed: Date?
    var reviewCount: Int
    var mastered: Bool // learned / not learned
}

struct Session: Identifiable, Codable {
    let id: UUID
    let date: Date
    var languageId: UUID
    var languageName: String
    var activityType: ActivityType
    var duration: Int // minutes
    var wordsLearned: Int
    var wordsReviewed: Int
    var notes: String?
    var energyLevel: Int? // 1-5
}

struct Goal: Identifiable, Codable {
    let id: UUID
    var languageId: UUID
    var languageName: String
    var title: String
    var targetValue: Int
    var currentValue: Int
    var unit: String // "minutes", "words", "lessons"
    var deadline: Date?
    var isCompleted: Bool
    var dateCreated: Date
}

struct Resource: Identifiable, Codable {
    let id: UUID
    var languageId: UUID
    var languageName: String
    var title: String
    var type: String // "Book", "Podcast", "App", "Course"
    var progress: Double // 0-1
    var notes: String?
}

