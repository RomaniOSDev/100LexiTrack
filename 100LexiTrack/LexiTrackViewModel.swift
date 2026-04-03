import Foundation
import Combine

final class LexiTrackViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var languages: [LanguageStudy] = []
    @Published var words: [Word] = []
    @Published var sessions: [Session] = []
    @Published var goals: [Goal] = []
    @Published var resources: [Resource] = []
    
    @Published var selectedLanguageId: UUID?
    @Published var selectedFilter: WordFilter?
    
    enum WordFilter {
        case new, review, mastered
    }
    
    // MARK: - Computed properties
    var activeLanguages: [LanguageStudy] {
        languages.filter { $0.isActive }
    }
    
    var totalWords: Int {
        words.count
    }
    
    var masteredWords: Int {
        words.filter { $0.mastered }.count
    }
    
    var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var todayMinutes: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.duration }
    }
    
    var dailyGoal: Int {
        // Sum of daily goals for all active languages
        activeLanguages.reduce(0) { $0 + $1.dailyGoalMinutes }
    }
    
    var todayProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return Double(todayMinutes) / Double(dailyGoal)
    }
    
    var recentSessions: [Session] {
        Array(sessions.sorted { $0.date > $1.date }.prefix(10))
    }
    
    var filteredWords: [Word] {
        var result = words
        
        if let languageId = selectedLanguageId {
            result = result.filter { $0.languageId == languageId }
        }
        
        switch selectedFilter {
        case .new:
            result = result.filter { $0.reviewCount == 0 && !$0.mastered }
        case .review:
            result = result.filter { $0.reviewCount > 0 && !$0.mastered }
        case .mastered:
            result = result.filter { $0.mastered }
        case nil:
            break
        }
        
        return result.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    // MARK: - Language methods
    func addLanguage(language: Language, level: String, dailyGoal: Int, weeklyGoal: Int) {
        let newLanguage = LanguageStudy(
            id: UUID(),
            language: language,
            level: level,
            startDate: Date(),
            goal: nil,
            isActive: true,
            dailyGoalMinutes: dailyGoal,
            weeklyGoalWords: weeklyGoal
        )
        languages.append(newLanguage)
        saveToUserDefaults()
    }
    
    // MARK: - Word methods
    func addWord(languageId: UUID, word: String, translation: String, context: String?, partOfSpeech: String?, difficulty: Int) {
        guard let language = languages.first(where: { $0.id == languageId }) else { return }
        
        let newWord = Word(
            id: UUID(),
            languageId: languageId,
            languageName: language.language.displayName,
            word: word,
            translation: translation,
            context: context,
            partOfSpeech: partOfSpeech,
            difficulty: difficulty,
            dateAdded: Date(),
            lastReviewed: nil,
            reviewCount: 0,
            mastered: false
        )
        words.append(newWord)
        saveToUserDefaults()
    }
    
    func markAsMastered(_ word: Word) {
        if let index = words.firstIndex(where: { $0.id == word.id }) {
            words[index].mastered = true
            saveToUserDefaults()
        }
    }
    
    func deleteWord(_ word: Word) {
        words.removeAll { $0.id == word.id }
        saveToUserDefaults()
    }
    
    // MARK: - Session methods
    func addSession(languageId: UUID, activityType: ActivityType, duration: Int, wordsLearned: Int, wordsReviewed: Int, energyLevel: Int?, notes: String?) {
        guard let language = languages.first(where: { $0.id == languageId }) else { return }
        
        let session = Session(
            id: UUID(),
            date: Date(),
            languageId: languageId,
            languageName: language.language.displayName,
            activityType: activityType,
            duration: duration,
            wordsLearned: wordsLearned,
            wordsReviewed: wordsReviewed,
            notes: notes,
            energyLevel: energyLevel
        )
        sessions.append(session)
        
        // Optionally, quick-add placeholder words here in future
        
        saveToUserDefaults()
    }
    
    // MARK: - Goal methods
    func addGoal(languageId: UUID, title: String, targetValue: Int, unit: String, deadline: Date?) {
        guard let language = languages.first(where: { $0.id == languageId }) else { return }
        
        let goal = Goal(
            id: UUID(),
            languageId: languageId,
            languageName: language.language.displayName,
            title: title,
            targetValue: targetValue,
            currentValue: 0,
            unit: unit,
            deadline: deadline,
            isCompleted: false,
            dateCreated: Date()
        )
        
        goals.append(goal)
        saveToUserDefaults()
    }
    
    // MARK: - Statistics
    func wordsCount(for languageId: UUID) -> Int {
        words.filter { $0.languageId == languageId }.count
    }
    
    func masteredCount(for languageId: UUID) -> Int {
        words.filter { $0.languageId == languageId && $0.mastered }.count
    }
    
    func minutesForLanguage(_ languageId: UUID) -> Int {
        sessions.filter { $0.languageId == languageId }
            .reduce(0) { $0 + $1.duration }
    }
    
    func todayMinutesForLanguage(_ languageId: UUID) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { $0.languageId == languageId && calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.duration }
    }
    
    func weeklyWordsForLanguage(_ languageId: UUID) -> Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        
        return words.filter { word in
            word.languageId == languageId &&
            word.dateAdded >= weekAgo &&
            !word.mastered
        }.count
    }
    
    func weeklyActivity(for languageId: UUID) -> [(day: String, minutes: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            let minutes = sessions.filter { session in
                session.languageId == languageId &&
                calendar.isDate(session.date, inSameDayAs: date)
            }.reduce(0) { $0 + $1.duration }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return (day: formatter.string(from: date), minutes: minutes)
        }.reversed()
    }
    
    var monthlyProgress: [(month: String, words: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: words) { word in
            let components = calendar.dateComponents([.year, .month], from: word.dateAdded)
            return calendar.date(from: components) ?? Date()
        }
        
        return grouped.map { date, words in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return (month: formatter.string(from: date), words: words.count)
        }.sorted { $0.month < $1.month }
    }
    
    struct ActivityDistributionItem: Identifiable {
        let id = UUID()
        let type: String
        let icon: String
        let minutes: Int
        let percentage: Double
    }
    
    var activityDistribution: [ActivityDistributionItem] {
        let grouped = Dictionary(grouping: sessions, by: { $0.activityType })
        let total = Double(totalMinutes)
        
        return grouped.map { type, sessions in
            let minutes = sessions.reduce(0) { $0 + $1.duration }
            return ActivityDistributionItem(
                type: type.rawValue,
                icon: type.icon,
                minutes: minutes,
                percentage: total > 0 ? (Double(minutes) / total * 100) : 0
            )
        }.sorted { $0.minutes > $1.minutes }
    }
    
    func minutesOnDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.duration }
    }
    
    // MARK: - Persistence
    private let languagesKey = "lexitrack_languages"
    private let wordsKey = "lexitrack_words"
    private let sessionsKey = "lexitrack_sessions"
    private let goalsKey = "lexitrack_goals"
    private let resourcesKey = "lexitrack_resources"
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(languages) {
            UserDefaults.standard.set(encoded, forKey: languagesKey)
        }
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: wordsKey)
        }
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
        if let encoded = try? JSONEncoder().encode(resources) {
            UserDefaults.standard.set(encoded, forKey: resourcesKey)
        }
    }
    
    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: languagesKey),
           let decoded = try? JSONDecoder().decode([LanguageStudy].self, from: data) {
            languages = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: wordsKey),
           let decoded = try? JSONDecoder().decode([Word].self, from: data) {
            words = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: resourcesKey),
           let decoded = try? JSONDecoder().decode([Resource].self, from: data) {
            resources = decoded
        }
        
        if languages.isEmpty {
            loadDemoData()
        }
    }
    
    private func loadDemoData() {
        let english = LanguageStudy(
            id: UUID(),
            language: .english,
            level: "B1",
            startDate: Date().addingTimeInterval(-86400 * 60),
            goal: "Confident conversation",
            isActive: true,
            dailyGoalMinutes: 30,
            weeklyGoalWords: 20
        )
        
        let spanish = LanguageStudy(
            id: UUID(),
            language: .spanish,
            level: "A1",
            startDate: Date().addingTimeInterval(-86400 * 30),
            goal: "Travel",
            isActive: true,
            dailyGoalMinutes: 15,
            weeklyGoalWords: 10
        )
        
        languages = [english, spanish]
        
        let word1 = Word(
            id: UUID(),
            languageId: english.id,
            languageName: english.language.displayName,
            word: "ubiquitous",
            translation: "present everywhere",
            context: "Smartphones are ubiquitous these days",
            partOfSpeech: "adjective",
            difficulty: 4,
            dateAdded: Date().addingTimeInterval(-86400 * 10),
            lastReviewed: Date().addingTimeInterval(-86400 * 2),
            reviewCount: 3,
            mastered: false
        )
        
        let word2 = Word(
            id: UUID(),
            languageId: spanish.id,
            languageName: spanish.language.displayName,
            word: "desayuno",
            translation: "breakfast",
            context: "El desayuno es la comida más importante",
            partOfSpeech: "sustantivo",
            difficulty: 2,
            dateAdded: Date().addingTimeInterval(-86400 * 5),
            lastReviewed: Date().addingTimeInterval(-86400 * 1),
            reviewCount: 2,
            mastered: true
        )
        
        words = [word1, word2]
        
        let session1 = Session(
            id: UUID(),
            date: Date().addingTimeInterval(-3600 * 5),
            languageId: english.id,
            languageName: english.language.displayName,
            activityType: .vocabulary,
            duration: 25,
            wordsLearned: 5,
            wordsReviewed: 10,
            notes: "Learned 5 new words",
            energyLevel: 4
        )
        
        let session2 = Session(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            languageId: spanish.id,
            languageName: spanish.language.displayName,
            activityType: .listening,
            duration: 15,
            wordsLearned: 2,
            wordsReviewed: 5,
            notes: "Spanish podcast",
            energyLevel: 3
        )
        
        sessions = [session1, session2]
    }
}

