import SwiftUI

struct WhatsAppLinkView: View {
    @State private var phoneNumber: String = ""
    @State private var showError: Bool = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("WhatsApp Chat")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter a phone number to start a chat")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
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
                    
                    // Preview of the number
                    if !cleanedPhoneNumber.isEmpty && cleanedPhoneNumber.count > 4 {
                        Group {
                            if horizontalSizeClass == .regular {
                                // Landscape - horizontal layout
                                HStack {
                                    HStack(spacing: 8) {
                                        Text("Chat will open with:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("+" + cleanedPhoneNumber.replacingOccurrences(of: "+", with: ""))
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    Spacer()
                                }
                                
                            } else {
                                // Portrait - vertical layout
                                VStack(spacing: 4) {
                                    Text("Chat will open with:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("+" + cleanedPhoneNumber.replacingOccurrences(of: "+", with: ""))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
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
        }
    }
    
    // MARK: - Subviews
    
    private var phoneNumberInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phone Number")
                .font(.headline)
            
            HStack {
                Text("+")
                TextField("1-123-456-7890", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .autocorrectionDisabled()
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
                Text("Open WhatsApp Chat")
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(cleanedPhoneNumber.isEmpty)
        .opacity(cleanedPhoneNumber.isEmpty ? 0.6 : 1.0)
    }
    
    // MARK: - Helper Properties and Methods
    
    // Remove all non-numeric characters except +
    private var cleanedPhoneNumber: String {
        phoneNumber.filter { $0.isNumber }
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
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                showError = false
            } else {
                showError = true
            }
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
