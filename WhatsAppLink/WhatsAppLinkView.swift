import SwiftUI

struct WhatsAppLinkView: View {
    @State private var phoneNumber: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
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
                
                TextField("e.g., +1234567890", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .autocorrectionDisabled()
                
                Text("Include country code (e.g., +44 for UK)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
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
