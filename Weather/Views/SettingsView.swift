import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var locations: [String] = ["Bangalore", "London"]
    @State private var newLocation: String = ""
    @AppStorage("defaultLocation") private var defaultLocation: String = "Bangalore"
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: String?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // Locations List
                locationsList
                
                // Add Location Section
                addLocationSection
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Location", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let location = locationToDelete {
                    deleteLocation(location)
                }
            }
        } message: {
            Text("Are you sure you want to delete this location?")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - View Components
    
    private var locationsList: some View {
        List {
            Section {
                ForEach(locations, id: \.self) { location in
                    LocationRow(
                        location: location,
                        isDefault: location == defaultLocation,
                        onTapLocation: { setDefaultLocation(location) },
                        onTapDelete: { confirmDelete(location) }
                    )
                }
            } header: {
                Text("Locations")
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .textCase(nil)
                    .font(.headline)
                    .padding(.bottom, 8)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
    }
    
    private var addLocationSection: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Add new location", text: $newLocation)
                    .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                    .autocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit {
                        addLocation()
                    }
                
                Button(action: addLocation) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme.buttonBackground)
                }
                .disabled(newLocation.isEmpty)
            }
            .padding(.horizontal)
            
            Text("Tap a location to set as default")
                .font(.caption)
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
        }
        .padding(.bottom)
    }
    
    // MARK: - Supporting Views
    private func addLocation() {
        let trimmedLocation = newLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLocation.isEmpty else { return }
        
        if locations.contains(trimmedLocation) {
            errorMessage = "This location is already in your list"
            showingErrorAlert = true
            return
        }
        
        withAnimation {
            locations.append(trimmedLocation)
            newLocation = ""
            
            // If this is the first location, set it as default
            if locations.count == 1 {
                defaultLocation = trimmedLocation
            }
        }
    }
    
    private func deleteLocation(_ location: String) {
        guard location != defaultLocation else {
            errorMessage = "Cannot delete the default location"
            showingErrorAlert = true
            return
        }
        
        withAnimation {
            if let index = locations.firstIndex(of: location) {
                locations.remove(at: index)
            }
        }
    }
    
    private func setDefaultLocation(_ location: String) {
        withAnimation {
            defaultLocation = location
        }
    }
    
    private func confirmDelete(_ location: String) {
        locationToDelete = location
        showingDeleteAlert = true
    }
}

// MARK: - Supporting Views

struct LocationRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let location: String
    let isDefault: Bool
    let onTapLocation: () -> Void
    let onTapDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(location)
                .foregroundColor(themeManager.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onTapLocation()
                    }
                }
            
            HStack(spacing: 12) {
                if isDefault {
                    Text("Default")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if !isDefault {
                    Button(action: onTapDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .listRowBackground(Color.white.opacity(0.1))
        .listRowSeparatorTint(themeManager.currentTheme.textColor.opacity(0.2))
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    let theme: Theme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(theme.textColor)
            .tint(theme.textColor)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(ThemeManager())
    }
}
