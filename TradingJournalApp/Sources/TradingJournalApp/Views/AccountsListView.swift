import SwiftUI
import SwiftData

struct AccountsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TradingAccount.name) private var accounts: [TradingAccount]
    
    @State private var showingAddAccount = false
    
    // Add Form State
    @State private var newName = ""
    @State private var newBroker = ""
    @State private var newBalance = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Trading Accounts")
                    .font(.displayLg())
                    .foregroundColor(Theme.onBackground)
                Spacer()
                
                Button(action: { showingAddAccount = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Account")
                    }
                    .font(.labelMd())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.surfaceContainerHighest)
                    .foregroundColor(Theme.primary)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            
            if accounts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "briefcase")
                        .font(.system(size: 48))
                        .foregroundColor(Theme.tertiary)
                    Text("No accounts created.")
                        .font(.headlineMd())
                        .foregroundColor(Theme.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Table Header
                HStack {
                    Text("ACCOUNT NAME").frame(width: 150, alignment: .leading)
                    Text("BROKER").frame(width: 150, alignment: .leading)
                    Text("INITIAL BALANCE").frame(width: 150, alignment: .trailing)
                    Text("TRADES").frame(width: 80, alignment: .trailing)
                    Spacer()
                }
                .font(.labelSm())
                .foregroundColor(Theme.onSurfaceVariant)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                            HStack {
                                Text(account.name)
                                    .font(.headlineSm())
                                    .foregroundColor(Theme.onBackground)
                                    .frame(width: 150, alignment: .leading)
                                
                                Text(account.broker)
                                    .font(.bodyMd())
                                    .foregroundColor(Theme.onSurfaceVariant)
                                    .frame(width: 150, alignment: .leading)
                                
                                Text(String(format: "$%.2f", account.initialBalance))
                                    .font(.bodyMd())
                                    .foregroundColor(Theme.primary)
                                    .frame(width: 150, alignment: .trailing)
                                
                                Text("\(account.trades?.count ?? 0)")
                                    .font(.bodyMd())
                                    .foregroundColor(Theme.onSurfaceVariant)
                                    .frame(width: 80, alignment: .trailing)
                                
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .surface(color: index % 2 == 0 ? Theme.surfaceContainerLow : Theme.surface, radius: 4)
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(account)
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("[Accounts] Failed to save after delete: \(error)")
                                    }
                                } label: {
                                    Label("Delete Account", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Theme.background)
        .sheet(isPresented: $showingAddAccount) {
            VStack(alignment: .leading, spacing: 24) {
                Text("New Trading Account")
                    .font(.headlineLg())
                    .foregroundColor(Theme.onBackground)
                
                TerminalTextField(title: "ACCOUNT NAME", text: $newName)
                TerminalTextField(title: "BROKER", text: $newBroker)
                TerminalTextField(title: "INITIAL BALANCE", text: $newBalance)
                
                HStack {
                    Spacer()
                    Button("Cancel") { showingAddAccount = false }
                        .buttonStyle(.plain)
                        .foregroundColor(Theme.onSurfaceVariant)
                    
                    Button(action: saveAccount) {
                        Text("Save Account")
                            .font(.headlineSm())
                            .foregroundColor(Theme.background)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
            }
            .padding(32)
            .frame(width: 400)
            .glassSurface()
        }
    }
    
    private func saveAccount() {
        guard let balance = Double(newBalance), !newName.isEmpty else { return }
        
        let account = TradingAccount(name: newName, broker: newBroker, initialBalance: balance)
        modelContext.insert(account)
        
        do {
            try modelContext.save()
        } catch {
            print("[Accounts] Failed to save: \(error)")
        }
        
        newName = ""
        newBroker = ""
        newBalance = ""
        showingAddAccount = false
    }
}
