import Foundation
import SwiftData

@Model
final class TradingAccount {
    var id: UUID
    var name: String
    var broker: String
    var initialBalance: Double
    var dateCreated: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Trade.account)
    var trades: [Trade]?
    
    init(id: UUID = UUID(), name: String, broker: String, initialBalance: Double, dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.broker = broker
        self.initialBalance = initialBalance
        self.dateCreated = dateCreated
    }
    
    // Calculated metrics can eventually loop over `trades` based on `TradeMetrics`.
}
