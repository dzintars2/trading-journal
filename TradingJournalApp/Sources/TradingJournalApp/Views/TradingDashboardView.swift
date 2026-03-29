import SwiftUI

struct TradingDashboardView: View {
    var trades: [Trade]
    
    var metrics: TradeMetrics {
        TradeMetrics(trades: trades)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                Text("Quantitative Archive")
                    .font(.displayLg())
                    .foregroundColor(Theme.onBackground)
                
                // Intentional Asymmetry: Wide main vs narrow sidebar (simulated with Grid)
                HStack(alignment: .top, spacing: 24) {
                    
                    // Main Narrative
                    VStack(spacing: 24) {
                        // Total PnL Card
                        VStack(alignment: .leading) {
                            Text("Total P&L")
                                .font(.labelMd())
                                .foregroundColor(Theme.onSurfaceVariant)
                            
                            Text(String(format: "$%.2f", metrics.totalPnL))
                                .font(.displayLg())
                                .foregroundColor(metrics.totalPnL >= 0 ? Theme.primary : Theme.secondary)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .surface(color: Theme.surfaceContainerHighest)
                        
                        // Recent Performance Mini-Chart
                        VStack(alignment: .leading) {
                            Text("Recent Curve")
                                .font(.headlineSm())
                                .foregroundColor(Theme.onBackground)
                            
                            EquityChart(trades: trades)
                                .frame(height: 200)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .surface(color: Theme.surfaceContainerLow)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // The Metadata Sidebar
                    VStack(spacing: 16) {
                        KPICard(title: "Win Rate", value: String(format: "%.1f%%", metrics.winRate * 100))
                        KPICard(title: "Avg Risk/Reward", value: String(format: "%.1f R", metrics.averageR))
                        KPICard(title: "Trades Taken", value: "\(trades.count)")
                    }
                    .frame(width: 250)
                }
            }
            .padding(32)
        }
        .background(Theme.background)
    }
}

struct KPICard: View {
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
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surface(color: Theme.surfaceContainer)
    }
}
