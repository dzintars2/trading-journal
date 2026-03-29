import Foundation
import SwiftData

struct TradeMetrics {
    var trades: [Trade]
    
    var totalPnL: Double {
        trades.compactMap { $0.pnlCurrency }.reduce(0, +)
    }
    
    var winRate: Double {
        let closedTrades = trades.filter { $0.status == .closed }
        guard !closedTrades.isEmpty else { return 0.0 }
        let wins = closedTrades.filter { $0.isWinning }.count
        return Double(wins) / Double(closedTrades.count)
    }
    
    var averageR: Double {
        let rMultiples = trades.compactMap { $0.rMultiple }
        guard !rMultiples.isEmpty else { return 0.0 }
        return rMultiples.reduce(0, +) / Double(rMultiples.count)
    }
}
