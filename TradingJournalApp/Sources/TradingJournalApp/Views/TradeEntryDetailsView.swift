import SwiftUI
import SwiftData

struct TradeEntryDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \TradingAccount.name) private var accounts: [TradingAccount]
    
    var tradeToEdit: Trade?
    
    @State private var selectedAccount: TradingAccount?
    @State private var asset = ""
    @State private var direction: TradeDirection = .long
    @State private var entryPrice = ""
    @State private var stopLoss = ""
    @State private var takeProfit = ""
    @State private var positionSize = ""
    @State private var dateEntered: Date = Date()
    
    @State private var exitPrice = ""
    @State private var manualPnL = ""
    @State private var dateExited: Date = Date()
    
    @State private var entryScreenshot: Data?
    @State private var exitScreenshot: Data?
    
    // State for viewing full-screen images natively
    @State private var viewingImage: NSImage?
    
    var isEditing: Bool { tradeToEdit != nil }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text(isEditing ? "Update Strategy" : "New Trade Entry")
                        .font(.headlineLg())
                        .foregroundColor(Theme.onBackground)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.onSurfaceVariant)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                .background(Theme.surfaceContainerHighest)
                
                // Scrollable Form Area
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Main Details
                        VStack(alignment: .leading, spacing: 16) {
                            
                            if accounts.isEmpty {
                                Text("⚠️ Please create a Trading Account in the 'Accounts' tab before logging a trade.")
                                    .font(.labelMd())
                                    .foregroundColor(Theme.secondary)
                                    .padding(.bottom, 8)
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ACCOUNT")
                                        .font(.labelSm())
                                        .foregroundColor(Theme.onSurfaceVariant)
                                    
                                    HStack {
                                        Picker("", selection: $selectedAccount) {
                                            Text("Select Account").tag(TradingAccount?.none)
                                            ForEach(accounts, id: \.id) { account in
                                                Text(account.name).tag(account as TradingAccount?)
                                            }
                                        }
                                        .labelsHidden()
                                        .pickerStyle(.menu)
                                        .tint(Theme.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .frame(height: 42)
                                    .background(Theme.surfaceContainerLowest)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Theme.outlineVariant.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            
                            HStack(spacing: 16) {
                                TerminalTextField(title: "ASSET (e.g., EUR/USD)", text: $asset)
                                TerminalDatePicker(title: "ENTRY TIME", date: $dateEntered)
                            }
                            
                            Picker("Direction", selection: $direction) {
                                Text("LONG").tag(TradeDirection.long)
                                Text("SHORT").tag(TradeDirection.short)
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 8)
                            
                            HStack(spacing: 16) {
                                TerminalTextField(title: "ENTRY PRICE", text: $entryPrice)
                                TerminalTextField(title: "POSITION SIZE", text: $positionSize)
                            }
                            
                            HStack(spacing: 16) {
                                TerminalTextField(title: "STOP LOSS", text: $stopLoss)
                                TerminalTextField(title: "TAKE PROFIT", text: $takeProfit)
                            }
                            
                            if isEditing {
                                Divider()
                                    .background(Theme.outlineVariant.opacity(0.3))
                                    .padding(.vertical, 8)
                                HStack(spacing: 16) {
                                    TerminalTextField(title: "EXIT PRICE (Leave empty if Open)", text: $exitPrice)
                                    TerminalDatePicker(title: "EXIT TIME", date: $dateExited)
                                }
                                TerminalTextField(title: "MANUAL P/L (Override)", text: $manualPnL)
                            }
                        }
                        .padding(24)
                        .surface(color: Theme.surfaceContainerLow)
                        
                        // Screenshot Upload Areas
                        HStack(spacing: 16) {
                            ImageUploadZone(title: "Entry / Context Screenshot", imageData: $entryScreenshot) { nsImage in
                                viewingImage = nsImage
                            }
                            
                            if isEditing {
                                ImageUploadZone(title: "Exit / Result Screenshot", imageData: $exitScreenshot) { nsImage in
                                    viewingImage = nsImage
                                }
                            }
                        }
                    }
                    .padding(24)
                }
                
                // Footer with Save Button
                HStack {
                    Spacer()
                    Button(action: saveOrUpdateTrade) {
                        Text(isEditing ? "Update Log" : "Execute Log")
                            .font(.headlineSm())
                            .foregroundColor(Theme.background)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background((accounts.isEmpty || selectedAccount == nil) ? Theme.surfaceContainerHighest : Theme.primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .disabled(accounts.isEmpty || selectedAccount == nil)
                }
                .padding(24)
                .background(Theme.surfaceContainerHighest)
            }
            .frame(width: 650, height: isEditing ? 850 : 750)
            
            // Fullscreen Image Overlay
            if let targetImage = viewingImage {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.85)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { viewingImage = nil }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { viewingImage = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Theme.onBackground)
                            }
                            .buttonStyle(.plain)
                            .padding(24)
                        }
                        
                        Image(nsImage: targetImage)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    }
                }
                .frame(width: 650, height: isEditing ? 850 : 750)
                .transition(.opacity)
                .zIndex(10) // Render on top
            }
            
        } // ZStack
        // Glassmorphism rule on Modals
        .glassSurface()
        .onAppear(perform: loadDataIfEditing)
        .animation(.easeInOut(duration: 0.2), value: viewingImage)
    }
    
    // ... logic remains the same ...
    private func loadDataIfEditing() {
        if let trade = tradeToEdit {
            selectedAccount = trade.account
            asset = trade.asset
            direction = trade.direction
            entryPrice = String(trade.entryPrice)
            stopLoss = String(trade.stopLoss)
            takeProfit = String(trade.takeProfit)
            positionSize = String(trade.positionSize)
            dateEntered = trade.dateEntered
            
            if let exit = trade.exitPrice { exitPrice = String(exit) }
            if let pnl = trade.manualPnL { manualPnL = String(pnl) }
            if let dExited = trade.dateExited { dateExited = dExited }
            
            entryScreenshot = trade.entryScreenshot
            exitScreenshot = trade.exitScreenshot
        } else {
            // New Trade: Set account auto if only 1 exists
            if accounts.count == 1 {
                selectedAccount = accounts.first
            }
        }
    }
    
    private func saveOrUpdateTrade() {
        guard let entry = Double(entryPrice),
              let sl = Double(stopLoss),
              let tp = Double(takeProfit),
              let size = Double(positionSize) else {
            return // Soft fail, needs basic validation alerts
        }
        
        // Account checking
        guard let validAccount = selectedAccount else { return }
        
        let parsedExit = Double(exitPrice)
        let parsedPnL = Double(manualPnL)
        let newStatus: TradeStatus = parsedExit != nil ? .closed : .open
        let theExitDate: Date? = parsedExit != nil ? dateExited : nil
        
        if let trade = tradeToEdit {
            // Update
            trade.account = validAccount
            trade.asset = asset
            trade.direction = direction
            trade.entryPrice = entry
            trade.stopLoss = sl
            trade.takeProfit = tp
            trade.positionSize = size
            trade.exitPrice = parsedExit
            trade.manualPnL = parsedPnL
            trade.entryScreenshot = entryScreenshot
            trade.exitScreenshot = exitScreenshot
            trade.dateEntered = dateEntered
            trade.dateExited = theExitDate
            trade.status = newStatus
        } else {
            // Create
            let newTrade = Trade(
                asset: asset,
                direction: direction,
                entryPrice: entry,
                exitPrice: parsedExit,
                stopLoss: sl,
                takeProfit: tp,
                positionSize: size,
                dateEntered: dateEntered,
                dateExited: theExitDate,
                status: newStatus,
                manualPnL: parsedPnL,
                entryScreenshot: entryScreenshot,
                exitScreenshot: exitScreenshot,
                account: validAccount
            )
            modelContext.insert(newTrade)
        }
        
        dismiss()
    }
}

struct ImageUploadZone: View {
    var title: String
    @Binding var imageData: Data?
    var onView: ((NSImage) -> Void)?
    
    @State private var isShowingPicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            if let data = imageData, let nsImage = NSImage(data: data) {
                // Actions when image is present
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .cornerRadius(4)
                
                HStack(spacing: 24) {
                    Button(action: { onView?(nsImage) }) {
                        Text("View Full")
                            .font(.labelMd())
                            .foregroundColor(Theme.primary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { isShowingPicker = true }) {
                        Text("Replace")
                            .font(.labelMd())
                            .foregroundColor(Theme.onSurfaceVariant)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Blank slate file importer
                Button(action: { isShowingPicker = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(Theme.tertiary)
                        Text(title)
                            .font(.labelMd())
                            .foregroundColor(Theme.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .ghostBorder()
        .fileImporter(
            isPresented: $isShowingPicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            do {
                if let url = try result.get().first {
                    if url.startAccessingSecurityScopedResource() {
                        imageData = try Data(contentsOf: url)
                        defer { url.stopAccessingSecurityScopedResource() }
                    }
                }
            } catch {
                print("Failed to read image data: \(error)")
            }
        }
    }
}

// "Input Fields Base: surface_container_lowest. Active State: ... on_surface_variant label moves to primary"
struct TerminalTextField: View {
    var title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.labelSm())
                .foregroundColor(isFocused ? Theme.primary : Theme.onSurfaceVariant)
            
            TextField("", text: $text)
                .font(.bodyMd())
                .foregroundColor(Theme.onBackground)
                .padding(12)
                .frame(height: 42)
                .background(isFocused ? Theme.surfaceContainerLow : Theme.surfaceContainerLowest)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isFocused ? Theme.primary.opacity(0.3) : Theme.outlineVariant.opacity(0.2), lineWidth: 1)
                )
                .focused($isFocused)
                // Remove default focus ring on macOS
                .textFieldStyle(.plain)
        }
    }
}

struct TerminalDatePicker: View {
    var title: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.labelSm())
                .foregroundColor(Theme.onSurfaceVariant)
            
            HStack {
                DatePicker("", selection: $date)
                    .labelsHidden()
                    .colorScheme(.dark)
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(Theme.surfaceContainerLowest)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Theme.outlineVariant.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
