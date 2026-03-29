import SwiftUI
import Charts

struct PerformanceAnalyticsView: View {
    var trades: [Trade]
    
    var metrics: TradeMetrics {
        TradeMetrics(trades: trades)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Performance Analytics")
                    .font(.displayLg())
                    .foregroundColor(Theme.onBackground)
                
                // Main Chart Area
                VStack(alignment: .leading, spacing: 16) {
                    Text("Equity Curve")
                        .font(.headlineMd())
                        .foregroundColor(Theme.onBackground)
                    
                    EquityChart(trades: trades)
                        .frame(height: 300)
                }
                .padding()
                .surface(color: Theme.surfaceContainerLowest)
                
                // Advanced Metrics Sidebar Style embedded
                HStack(spacing: 24) {
                    MetricPanel(title: "Win Rate", value: String(format: "%.1f%%", metrics.winRate * 100))
                    MetricPanel(title: "Avg R-Multiple", value: String(format: "%.2f R", metrics.averageR))
                    MetricPanel(title: "Total Trades", value: "\(trades.count)")
                }
            }
            .padding(32)
        }
        .background(Theme.background)
    }
}

struct EquityChart: View {
    var trades: [Trade]
    
    // Convert trades to cumulative equity curve
    var cumulativeEquity: [(Date, Double)] {
        var currentEquity: Double = 0
        var curve: [(Date, Double)] = []
        let closedTrades = trades.filter { $0.status == .closed }.sorted { $0.dateExited! < $1.dateExited! }
        
        for trade in closedTrades {
            if let pnl = trade.pnlCurrency {
                currentEquity += pnl
                curve.append((trade.dateExited!, currentEquity))
            }
        }
        return curve
    }
    
    var body: some View {
        Chart {
            ForEach(Array(cumulativeEquity.enumerated()), id: \.offset) { index, point in
                LineMark(
                    x: .value("Date", point.0),
                    y: .value("Equity", point.1)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(Theme.primary)
                
                AreaMark(
                    x: .value("Date", point.0),
                    y: .value("Equity", point.1)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primary.opacity(0.2), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) {
                AxisGridLine().foregroundStyle(Theme.outlineVariant.opacity(0.05))
                AxisValueLabel().foregroundStyle(Theme.onSurfaceVariant)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) {
                AxisGridLine().foregroundStyle(Theme.outlineVariant.opacity(0.05))
                AxisValueLabel().foregroundStyle(Theme.onSurfaceVariant)
            }
        }
    }
}

struct MetricPanel: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.displaySm())
                .foregroundColor(Theme.onBackground)
            Text(title)
                .font(.labelMd())
                .foregroundColor(Theme.onSurfaceVariant)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .surface(color: Theme.surfaceContainerLow)
    }
}
