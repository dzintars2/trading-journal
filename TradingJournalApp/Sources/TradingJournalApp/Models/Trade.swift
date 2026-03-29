import Foundation
import SwiftData

enum TradeDirection: String, Codable, CaseIterable {
    case long = "LONG"
    case short = "SHORT"
}

enum TradeStatus: String, Codable {
    case open = "OPEN"
    case closed = "CLOSED"
}

@Model
final class Trade {
    var id: UUID
    var asset: String
    var direction: TradeDirection
    var entryPrice: Double
    var exitPrice: Double?
    var stopLoss: Double
    var takeProfit: Double
    var positionSize: Double // Quantity or Lots
    var dateEntered: Date
    var dateExited: Date?
    var status: TradeStatus
    
    // NEW FIELDS
    var manualPnL: Double?
    @Attribute(.externalStorage) var entryScreenshot: Data?
    @Attribute(.externalStorage) var exitScreenshot: Data?
    
    // RELATIONSHIPS
    var account: TradingAccount?
    
    init(id: UUID = UUID(), asset: String, direction: TradeDirection, entryPrice: Double, exitPrice: Double? = nil, stopLoss: Double, takeProfit: Double, positionSize: Double, dateEntered: Date, dateExited: Date? = nil, status: TradeStatus, manualPnL: Double? = nil, entryScreenshot: Data? = nil, exitScreenshot: Data? = nil, account: TradingAccount? = nil) {
        self.id = id
        self.asset = asset
        self.direction = direction
        self.entryPrice = entryPrice
        self.exitPrice = exitPrice
        self.stopLoss = stopLoss
        self.takeProfit = takeProfit
        self.positionSize = positionSize
        self.dateEntered = dateEntered
        self.dateExited = dateExited
        self.status = status
        self.manualPnL = manualPnL
        self.entryScreenshot = entryScreenshot
        self.exitScreenshot = exitScreenshot
        self.account = account
    }
    
    // MARK: - Calculated Metrics
    var pnlPips: Double? {
        guard let exitPrice = exitPrice else { return nil }
        // Very basic pip calculation
        if direction == .long {
            return (exitPrice - entryPrice) * 10000 
        } else {
            return (entryPrice - exitPrice) * 10000
        }
    }
    
    var pnlCurrency: Double? {
        if let manual = manualPnL { return manual }
        guard let exit = exitPrice else { return nil }
        let points = direction == .long ? (exit - entryPrice) : (entryPrice - exit)
        return points * positionSize
    }
    
    var isWinning: Bool {
        guard let pnl = pnlCurrency else { return false }
        return pnl > 0
    }
    
    var rMultiple: Double? {
        guard let exit = exitPrice else { return nil }
        let initialRisk = abs(entryPrice - stopLoss)
        if initialRisk == 0 { return 0 }
        
        let reward = direction == .long ? (exit - entryPrice) : (entryPrice - exit)
        return reward / initialRisk
    }
}
