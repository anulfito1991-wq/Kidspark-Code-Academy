import Foundation
import StoreKit
import Observation

enum ProProductID: String, CaseIterable {
    case monthly = "com.codeforkids.pro.monthly"
    case annual = "com.codeforkids.pro.annual"
}

@Observable
@MainActor
final class StoreService {
    var products: [Product] = []
    var hasPro: Bool = false
    var purchaseInFlight: Bool = false
    var lastError: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        startListeningForTransactionUpdates()
    }

    func start() async {
        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        do {
            let ids = ProProductID.allCases.map(\.rawValue)
            let loaded = try await Product.products(for: ids)
            products = loaded.sorted { lhs, rhs in
                (lhs.price as NSDecimalNumber).compare(rhs.price as NSDecimalNumber) == .orderedAscending
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        purchaseInFlight = true
        defer { purchaseInFlight = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    hasPro = true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               ProProductID(rawValue: transaction.productID) != nil,
               transaction.revocationDate == nil {
                active = true
            }
        }
        hasPro = active
    }

    private func startListeningForTransactionUpdates() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }
}
