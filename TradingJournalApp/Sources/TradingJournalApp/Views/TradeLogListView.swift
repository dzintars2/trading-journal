import SwiftUI
import SwiftData

struct TradeLogListView: View {
    @Environment(\.modelContext) private var modelContext
    var trades: [Trade]
    @Binding var editingTrade: Trade?
    
    // Sort locally descending by open time
    var sortedTrades: [Trade] {
        trades.sorted { $0.dateEntered > $1.dateEntered }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Trade Log")
                    .font(.displayLg())
                    .foregroundColor(Theme.onBackground)
                Spacer()
            }
            .padding(32)
            
            // Table Header (using inter tabular)
            HStack(spacing: 0) {
                Text("ASSET").frame(width: 90, alignment: .leading)
                Text("DIR").frame(width: 55, alignment: .leading)
                Text("ENTRY").frame(width: 90, alignment: .trailing)
                Text("EXIT").frame(width: 90, alignment: .trailing)
                Text("OPENED").frame(width: 140, alignment: .trailing)
                Text("CLOSED").frame(width: 140, alignment: .trailing)
                Text("P/L").frame(width: 90, alignment: .trailing)
                Spacer()
            }
            .font(.labelSm())
            .foregroundColor(Theme.onSurfaceVariant)
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
            
            // The Core Table without 1px Borders
            ScrollView {
                VStack(spacing: 10) { // spacing scale 3 (0.6rem ~= 10pt)
                    ForEach(Array(sortedTrades.enumerated()), id: \.element.id) { index, trade in
                        TradeRow(trade: trade, index: index)
                            .contentShape(Rectangle()) // makes entire row clickable
                            .onTapGesture {
                                editingTrade = trade
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteTrade(trade)
                                } label: {
                                    Label("Delete Strategy", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .background(Theme.background)
    }
    
    private func deleteTrade(_ trade: Trade) {
        modelContext.delete(trade)
        do {
            try modelContext.save()
        } catch {
            print("[TradeLog] Failed to save after delete: \(error)")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd MMM HH:mm"
    return f
}()

struct TradeRow: View {
    var trade: Trade
    var index: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text(trade.asset)
                .font(.bodyMd())
                .foregroundColor(Theme.onBackground)
                .frame(width: 90, alignment: .leading)
            
            Text(trade.direction.rawValue)
                .font(.labelSm())
                .foregroundColor(trade.direction == .long ? Theme.primary : Theme.tertiary)
                .frame(width: 55, alignment: .leading)
            
            Text(String(format: "%.4f", trade.entryPrice))
                .font(.bodyMd())
                .foregroundColor(Theme.onBackground)
                .frame(width: 90, alignment: .trailing)
            
            Text(trade.exitPrice != nil ? String(format: "%.4f", trade.exitPrice!) : "—")
                .font(.bodyMd())
                .foregroundColor(trade.exitPrice != nil ? Theme.onBackground : Theme.onSurfaceVariant)
                .frame(width: 90, alignment: .trailing)
            
            // Opened Date/Time
            Text(dateFormatter.string(from: trade.dateEntered))
                .font(.labelMd())
                .foregroundColor(Theme.onSurfaceVariant)
                .frame(width: 140, alignment: .trailing)
            
            // Closed Date/Time
            Text(trade.dateExited.map { dateFormatter.string(from: $0) } ?? "—")
                .font(.labelMd())
                .foregroundColor(trade.dateExited != nil ? Theme.onSurfaceVariant : Theme.onSurfaceVariant.opacity(0.4))
                .frame(width: 140, alignment: .trailing)
            
            // P/L column
            Text(formattedPnL)
                .font(.bodyMd())
                .foregroundColor(pnlColor)
                .frame(width: 90, alignment: .trailing)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        // Alternating Tones for zebra-striping without borders
        .surface(color: index % 2 == 0 ? Theme.surfaceContainerLow : Theme.surface, radius: 4)
    }
    
    var formattedPnL: String {
        if let pnl = trade.pnlCurrency {
            return String(format: "%+.2f", pnl)
        }
        return "Open"
    }
    
    var pnlColor: Color {
        guard let pnl = trade.pnlCurrency else { return Theme.onSurfaceVariant }
        if pnl > 0 { return Theme.primary }
        if pnl < 0 { return Theme.secondary }
        return Theme.onSurfaceVariant
    }
}
