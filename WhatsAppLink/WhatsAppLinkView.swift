import SwiftUI

struct WhatsAppLinkView: View {
    @State private var phoneNumber: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
            Text("WhatsApp Chat")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter a phone number to start a chat")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Phone number input
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
            
            // WhatsApp button
            Button(action: openWhatsAppChat) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Open WhatsApp Chat")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(cleanedPhoneNumber.isEmpty)
            .opacity(cleanedPhoneNumber.isEmpty ? 0.5 : 1.0)
            
            // Preview of the number
            if !cleanedPhoneNumber.isEmpty {
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
    
    // Remove all non-numeric characters except +
    private var cleanedPhoneNumber: String {
        phoneNumber.filter { $0.isNumber || $0 == "+" }
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

#Preview {
    WhatsAppLinkView()
}
