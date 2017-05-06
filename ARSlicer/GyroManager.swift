import UIKit
import CoreMotion
import SceneKit

protocol GyroManagerDelegate {
    func update(rotation: SCNVector3)
}

class GyroManager {
    
    var delegate: GyroManagerDelegate?
    let manager = CMMotionManager()
    
    var rotation: SCNVector3 = SCNVector3(0, 0, 0) {
        didSet{
            delegate?.update(rotation: rotation)
        }
    }
    
    init() {
        manager.stopGyroUpdates()
        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = 0.01
            manager.startGyroUpdates()
            
            let queue = OperationQueue.main
            manager.startGyroUpdates(to: queue) { data, error in
                
                if self.manager.isDeviceMotionAvailable {
                    self.manager.deviceMotionUpdateInterval = 0.01
                    
                    self.manager.startDeviceMotionUpdates(to: OperationQueue.main) {data, error in
                        guard let data = data else { return }
                        let vertical = atan2(data.gravity.y, data.gravity.z) - Double.pi
                        self.rotation = SCNVector3(vertical, 0, 0)
                    }
                }
            }
        }
    }
}
