import Foundation
import Network

/// Force iOS to show Local Network permission popup
/// This is required for Agora SDK to work on iOS 14+
@objc class LocalNetworkPermissionTrigger: NSObject {
    
    private var listener: NWListener?
    
    @objc static func trigger() {
        let trigger = LocalNetworkPermissionTrigger()
        trigger.startListener()
    }
    
    private func startListener() {
        do {
            // Create a temporary listener on a random port
            // This will trigger iOS to show the Local Network permission popup
            let listener = try NWListener(using: .tcp, on: .any)
            
            listener.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    print("🌐 [LOCAL_NETWORK] Permission trigger ready")
                    // Stop immediately after triggering the permission
                    self?.stopListener()
                case .failed(let error):
                    print("🌐 [LOCAL_NETWORK] Permission trigger failed: \(error)")
                    self?.stopListener()
                default:
                    break
                }
            }
            
            listener.start(queue: .main)
            self.listener = listener
            
            // Auto-stop after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.stopListener()
            }
            
        } catch {
            print("🌐 [LOCAL_NETWORK] Failed to create listener: \(error)")
        }
    }
    
    private func stopListener() {
        listener?.cancel()
        listener = nil
    }
}
