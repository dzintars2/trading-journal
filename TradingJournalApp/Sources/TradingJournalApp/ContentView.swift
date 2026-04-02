import SwiftUI
import SwiftData

enum NavigationItem: Hashable {
    case dashboard
    case tradeLog
    case analytics
    case accounts
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trade.dateEntered, order: .reverse) private var trades: [Trade]
    
    @State private var selection: NavigationItem? = .dashboard
    @State private var showingNewTradeEntry = false
    @State private var editingTrade: Trade?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                // MARK: - Branding Header
                HStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .cornerRadius(8)
                        .ambientShadow()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Sovereign")
                            .font(.headlineMd())
                            .foregroundColor(Theme.onBackground)
                        Text("The Archive")
                            .font(.labelSm())
                            .foregroundColor(Theme.onSurfaceVariant)
                            .opacity(0.8)
                    }
                }
                .padding(.vertical, 16)
                .listRowSeparator(.hidden)
                
                NavigationLink(value: NavigationItem.dashboard) {
                    Label("Dashboard", systemImage: "chart.pie")
                }
                NavigationLink(value: NavigationItem.tradeLog) {
                    Label("Trade Log", systemImage: "list.bullet.rectangle.portrait")
                }
                NavigationLink(value: NavigationItem.analytics) {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }
                NavigationLink(value: NavigationItem.accounts) {
                    Label("Accounts", systemImage: "person.2.badge.gearshape")
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)            
            // "The Warning Signal" but used for Primary Action (Entry)
            Button(action: {
                showingNewTradeEntry = true 
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Trade")
                }
                .font(.labelMd())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Theme.surfaceContainerHighest)
                .foregroundColor(Theme.primary)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .padding()
            
        } detail: {
            Group {
                switch selection {
                case .dashboard:
                    TradingDashboardView(trades: trades)
                case .tradeLog:
                    TradeLogListView(trades: trades, editingTrade: $editingTrade)
                case .analytics:
                    PerformanceAnalyticsView(trades: trades)
                case .accounts:
                    AccountsListView()
                case nil:
                    Text("Select an item")
                        .foregroundColor(Theme.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background)
        }
        .sheet(isPresented: $showingNewTradeEntry) {
            TradeEntryDetailsView(tradeToEdit: nil)
        }
        .sheet(item: $editingTrade) { trade in
            TradeEntryDetailsView(tradeToEdit: trade)
        }
    }
}

#Preview {
    ContentView().frame(minWidth: 1000, minHeight: 600)
}
