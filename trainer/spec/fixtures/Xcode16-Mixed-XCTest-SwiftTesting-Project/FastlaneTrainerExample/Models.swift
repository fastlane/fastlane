import Foundation

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

@MainActor
class ItemsViewModel: ObservableObject {
    @Published var items: [Item] = [
        Item(title: "First Item", description: "This is the first item"),
        Item(title: "Second Item", description: "This is the second item"),
        Item(title: "Third Item", description: "This is the third item")
    ]
    
    @Published var searchText = ""
    @Published var showInvalidInputAlert = false
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func validateInput(_ text: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+=")
        if text.rangeOfCharacter(from: invalidCharacters) != nil {
            showInvalidInputAlert = true
            return false
        }
        return true
    }
} 