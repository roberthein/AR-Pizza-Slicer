import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class ViewController: UIViewController {
    
    let scene = SCNScene()
    var collection: Collection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gyro = GyroManager()
        gyro.delegate = self
        
        let captureSession = AVCaptureSession()
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        do {
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if (captureSession.canAddInput(input as AVCaptureInput)) {
                captureSession.addInput(input as AVCaptureDeviceInput)
            }
            
        } catch let error as NSError {
            print(error)
        }
        
        captureSession.startRunning()
        
        previewLayer.frame = self.view.bounds
        view.layer.addSublayer(previewLayer)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 12)
        
        let scnView = SCNView()
        scnView.frame = self.view.bounds
        scnView.backgroundColor = UIColor.clear
        previewLayer.frame = self.view.bounds
        self.view.addSubview(scnView)
        
        guard let plane = SCNScene(named: "art.scnassets/plane.scn")?.rootNode.childNode(withName: "plane", recursively: true) else { return }
        
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false
        scene.rootNode.addChildNode(plane)
        scnView.scene = scene
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collection = Collection(frame: view.bounds, collectionViewLayout: layout)
        collection.indexDelegate = self
        view.addSubview(collection)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collection.update()
    }
}

extension ViewController: GyroManagerDelegate {
    
    func update(rotation: SCNVector3) {
        let plane = scene.rootNode.childNode(withName: "plane", recursively: true)
        plane?.runAction(SCNAction.rotateTo(x: CGFloat(rotation.x) + CGFloat(Double.pi), y: 0, z: CGFloat(Double.pi), duration: 0.1))
    }
}

extension ViewController: CollectionIndexDelegate {
    
    func didScroll(to shape: Shape) {
        guard let plane = scene.rootNode.childNode(withName: "plane", recursively: true) else { return }
        
        if let material = plane.geometry?.materials.first {
            let image = UIImage(named: shape.imageName)
            material.diffuse.contents = image
            material.selfIllumination.contents = UIColor.white
        }
    }
}
