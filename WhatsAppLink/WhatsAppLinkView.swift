import SwiftUI

#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct WhatsAppLinkView: View {
    @State private var phoneNumber: String = ""
    @State private var showError: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Phone number input and button
                    Group {
                        if horizontalSizeClass == .regular {
                            // Landscape/iPad layout - side by side
                            HStack(alignment: .top, spacing: 16) {
                                phoneNumberInputView
                                Spacer()
                                whatsAppButton
                            }
                            .padding(.horizontal)
                        } else {
                            // Portrait layout - stacked vertically
                            VStack(spacing: 8) {
                                phoneNumberInputView
                                whatsAppButton
                                    .padding(.horizontal)
                            }
                            .padding(.top, 20)
                        }
                    }
                    
                    if showError {
                        Text("Unable to open WhatsApp. Make sure it's installed.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    // Restore focus when app becomes active
                    isTextFieldFocused = true
                }
            }
            .onChange(of: horizontalSizeClass) { oldValue, newValue in
                // Restore focus when orientation changes
                isTextFieldFocused = true
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - Subviews
    
    private var phoneNumberInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter a phone number to start a WhatsApp chat")
                .font(.headline)
            
            HStack {
                Text("+")
                TextField(currentPlaceholder, text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .focused($isTextFieldFocused)
#if os(iOS)
                    .keyboardType(.phonePad)
#endif
                
                Button(action: pasteFromClipboard) {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
            
            HStack {
                Text("+")   // Just to pad out the link to be under the Text Field
                    .hidden()
                NavigationLink {
                    CountryCodesReferenceView(phoneNumber: $phoneNumber)
                } label: {
                    HStack {
                        Text("Include country code")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
            }
        }
    }
    
    private var whatsAppButton: some View {
        Button(action: openWhatsAppChat) {
            HStack {
                Image("WhatsApp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack {
                    Text("Open WhatsApp")
                    HStack {
                        if cleanedPhoneNumber.isEmpty || cleanedPhoneNumber.count < 5 {
                            Text("+").hidden()
                        } else {
                            Text("+" + cleanedPhoneNumber.replacingOccurrences(of: "+", with: ""))
                                .font(.body)
                                .fontWeight(.medium)
                            
                        }
                    }
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(cleanedPhoneNumber.isEmpty)
        .opacity(cleanedPhoneNumber.isEmpty ? 0.6 : 1.0)
    }
    
    // MARK: - Helper Properties and Methods
    
    private var currentPlaceholder: String {
        let currentPlaceholder = "1-123-456-7890"
        
        return currentPlaceholder
    }
    
    // If user typed a number, use that. Otherwise, use the cached pasteboard number if available.
    private var cleanedPhoneNumber: String {
        var cleanedPhoneNumber: String = ""
        if !phoneNumber.isEmpty {
            let input = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            cleanedPhoneNumber = input.filter { $0.isNumber }
        }
        
        return cleanedPhoneNumber
    }
        
    private func pasteFromClipboard() {
#if os(iOS)
        let pasteString = UIPasteboard.general.string
#else
        let pasteString = NSPasteboard.general.string(forType: .string)
#endif
        if let pasteString = pasteString
        {
            // Extract only digits from the pasted content
            let digits = pasteString.filter { $0.isNumber }
            phoneNumber = digits
        }
    }
    
    private func openWhatsAppChat() {
        let cleaned = cleanedPhoneNumber
        
        // Remove + from the beginning if present, as WhatsApp URL expects just digits
        let digits = cleaned.replacingOccurrences(of: "+", with: "")
        
        guard !digits.isEmpty else {
            showError = true
            return
        }
        
        // WhatsApp URL scheme
        let urlString = "https://api.whatsapp.com/send/?phone=\(digits)"
        
        if let url = URL(string: urlString) {
#if os(iOS)
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                showError = false
            } else {
                showError = true
            }
#else
            NSWorkspace.shared.open(url)
            showError = false
#endif
        } else {
            showError = true
        }
    }
}

#Preview("Portrait") {
    WhatsAppLinkView()
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("Landscape", traits: .landscapeRight) {
    WhatsAppLinkView()
        .environment(\.horizontalSizeClass, .regular)
}
