import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: LexiTrackViewModel
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lexiBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        overallStats
                        monthlyProgressChart
                        activityDistribution
                        activityCalendar
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Statistics")
                .font(.largeTitle.bold())
                .foregroundColor(.lexiPlanned)
            
            Text("See your long‑term progress")
                .foregroundColor(.white)
                .font(.subheadline)
        }
    }
    
    private var overallStats: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatCard(
                title: "Total words",
                value: "\(viewModel.totalWords)",
                icon: "character.book.closed",
                color: .lexiCompleted
            )
            
            StatCard(
                title: "Mastered",
                value: "\(viewModel.masteredWords)",
                icon: "checkmark.seal.fill",
                color: .lexiCompleted
            )
            
            StatCard(
                title: "Time",
                value: "\(viewModel.totalMinutes) min",
                icon: "clock.fill",
                color: .lexiPlanned
            )
            
            StatCard(
                title: "Sessions",
                value: "\(viewModel.totalSessions)",
                icon: "rectangle.stack.fill",
                color: .lexiPlanned
            )
        }
    }
    
    private var monthlyProgressChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly progress")
                .foregroundColor(.lexiPlanned)
                .font(.headline)
            
            Chart {
                ForEach(Array(viewModel.monthlyProgress.enumerated()), id: \.offset) { _, data in
                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Words", data.words)
                    )
                    .foregroundStyle(Color.lexiCompleted)
                    
                    AreaMark(
                        x: .value("Month", data.month),
                        y: .value("Words", data.words)
                    )
                    .foregroundStyle(Color.lexiCompleted.opacity(0.1))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var activityDistribution: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity types")
                .foregroundColor(.lexiPlanned)
                .font(.headline)
            
            ForEach(viewModel.activityDistribution) { item in
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(.lexiPlanned)
                        .frame(width: 24)
                    
                    Text(item.type)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(item.minutes) min")
                        .foregroundColor(.gray)
                    
                    Text("(\(Int(item.percentage))%)")
                        .foregroundColor(.lexiCompleted)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var activityCalendar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calendar")
                .foregroundColor(.lexiPlanned)
                .font(.headline)
            
            let calendar = Calendar.current
            let today = Date()
            let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
            
            HStack {
                ForEach(Array(weekDays), id: \.self) { date in
                    let minutes = viewModel.minutesOnDate(date)
                    let intensity = minutes > 0 ? min(Double(minutes) / 60.0, 1.0) : 0
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(minutes > 0 ? Color.lexiCompleted : Color.gray.opacity(0.3))
                            .frame(height: 40)
                            .opacity(0.3 + intensity * 0.7)
                        
                        Text(formattedShortDay(date))
                            .foregroundColor(.gray)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.lexiPlanned.opacity(0.1))
        .cornerRadius(12)
    }
}

