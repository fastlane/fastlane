import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ItemsViewModel()
    @State private var showingAlert = false
    @State private var isRefreshing = false
    @State private var selectedImage: Image?
    @State private var imageScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            List {
                SearchField(text: $viewModel.searchText)
                
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        ItemRow(item: item)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            // Delete action
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .accessibilityIdentifier("Delete")
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarItems(trailing: Button(action: {
                showingAlert = true
            }) {
                Image(systemName: "bell")
                    .accessibilityIdentifier("showAlert")
            })
            .refreshable {
                // Simulate refresh
                isRefreshing = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isRefreshing = false
            }
            .alert("Alert Title", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Alert Message")
            }
            .alert("Invalid input", isPresented: $viewModel.showInvalidInputAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The input contains invalid characters")
            }
        }
    }
}

struct SearchField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityIdentifier("searchField")
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                }
                .accessibilityIdentifier("clearText")
            }
        }
        .padding()
    }
}

struct ItemRow: View {
    let item: Item
    @State private var showMenu = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .contextMenu {
            Button("Edit") { }
            Button("Share") { }
            Button("Delete") { }
        }
    }
}

struct DetailView: View {
    let item: Item
    @State private var imageScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            Text(item.title)
                .font(.title)
                .accessibilityIdentifier("Main Header")
            
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 200 * imageScale, height: 200 * imageScale)
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        imageScale = value
                    }
                )
            
            Text(item.description)
                .padding()
            
            Button("Add Item") {
                // Add item action
            }
            .accessibilityIdentifier("Add Item")
        }
        .navigationBarTitle("Details", displayMode: .inline)
        .padding()
    }
}

#Preview {
    HomeView()
} 