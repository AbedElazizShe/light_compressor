import FlutterMacOS
import Photos 

public class LightCompressorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    private var compression: Compression? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "light_compressor", binaryMessenger: registrar.messenger)
        let instance = LightCompressorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "compression/stream", binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(instance.self)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startCompression":
            if let myArgs = call.arguments as? [String: Any?],
               let path : String = myArgs["path"] as? String,
               let videoName : String = myArgs["videoName"] as? String,
               let isMinBitrateCheckEnabled : Bool = myArgs["isMinBitrateCheckEnabled"] as? Bool,
               let videoBitrateInMbps : Int? = myArgs["videoBitrateInMbps"] as? Int?,
               let disableAudio : Bool = myArgs["disableAudio"] as? Bool,
               let saveInGallery : Bool = myArgs["saveInGallery"] as? Bool,
               let keepOriginalResolution : Bool = myArgs["keepOriginalResolution"] as? Bool,
               let videoHeight : Int? = myArgs["videoHeight"] as? Int?,
               let videoWidth : Int? = myArgs["videoWidth"] as? Int?,
               let videoQuality : String = myArgs["videoQuality"] as? String {
                
                var desPath: URL
                
                desPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(videoName).mp4")
                try? FileManager.default.removeItem(at: desPath)
                
                let videoCompressor = LightCompressor()
                
                compression = videoCompressor.compressVideo(
                    videos: [.init(
                        source: URL(fileURLWithPath: path),
                        destination: desPath,
                        configuration: .init(
                            quality: getVideoQuality(quality: videoQuality),
                            isMinBitrateCheckEnabled: isMinBitrateCheckEnabled,
                            videoBitrateInMbps: videoBitrateInMbps,
                            disableAudio: disableAudio,
                            keepOriginalResolution: keepOriginalResolution,
                            videoSize: videoWidth == nil || videoHeight == nil ? nil : CGSize(width: videoWidth!, height: videoHeight!))
                    )],
                    progressQueue: .main,
                    progressHandler: { progress in
                        DispatchQueue.main.async { [unowned self] in
                            if(self.eventSink != nil){
                                let progress = Float(progress.fractionCompleted * 100)
                                if(progress <= 100) {
                                    self.eventSink!(progress)
                                }
                            }
                        }
                    },
                    completion: { compressionResult in
                        
                        switch compressionResult {
                        case .onSuccess(let index, let path):
                            if(saveInGallery) {
                                DispatchQueue.main.async {
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
                                    })
                                }
                            }
                            let response: [String: String] = ["onSuccess": path.path, "index": String(index)]
                            result(response.toJson)
                            
                        case .onStart: break
                            
                        case .onFailure(let index, let error):
                            let response: [String: String] = ["onFailure": error.title, "index": String(index)]
                            result(response.toJson)
                            
                        case .onCancelled:
                            let response: [String: Bool] = ["onCancelled": true]
                            result(response.toJson)
                        }
                    }
                )
            }
        case "cancelCompression":
            compression?.cancel = true
        default:
            let response: [String: String] = ["onFailure": "Method is not defined!"]
            result(response.toJson)
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    private func getVideoQuality(quality: String) -> VideoQuality{
        switch quality {
        case "very_low":
            return VideoQuality.very_low
        case "low":
            return VideoQuality.low
        case "medium":
            return VideoQuality.medium
        case "high":
            return VideoQuality.high
        case "very_high":
            return VideoQuality.very_high
        default:
            return VideoQuality.medium
        }
    }
    
}
