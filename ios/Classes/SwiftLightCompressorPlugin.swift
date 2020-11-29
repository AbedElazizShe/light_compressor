import Flutter
import UIKit
import Photos 

@available(iOS 11.0, *)
public class SwiftLightCompressorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    private var compression: Compression? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "light_compressor", binaryMessenger: registrar.messenger())
        let instance = SwiftLightCompressorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "compression/stream", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance.self)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startCompression":
            if let myArgs = call.arguments as? [String: Any?],
               let path : String = myArgs["path"] as? String,
               let destinationPath : String? = myArgs["destinationPath"] as? String?,
               let isMinBitRateEnabled : Bool = myArgs["isMinBitRateEnabled"] as? Bool,
               let keepOriginalResolution : Bool = myArgs["keepOriginalResolution"] as? Bool,
               let videoQuality : String = myArgs["videoQuality"] as? String {
                
                var desPath: URL
                if(destinationPath == nil){
                    // Declare destination path and remove anything exists in it
                    desPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSDate().timeIntervalSince1970).mp4")
                    try? FileManager.default.removeItem(at: desPath)
                }else{
                    desPath = URL(fileURLWithPath: destinationPath!)
                }
                
                let videoCompressor = LightCompressor()
                
                compression = videoCompressor.compressVideo(
                    source: URL(fileURLWithPath: path),
                    destination: desPath,
                    quality: getVideoQuality(quality: videoQuality),
                    isMinBitRateEnabled: isMinBitRateEnabled,
                    keepOriginalResolution: keepOriginalResolution,
                    progressQueue: .main,
                    progressHandler: { progress in
                        DispatchQueue.main.async { [unowned self] in
                            if(self.eventSink != nil){
                                self.eventSink!(Float(progress.fractionCompleted * 100))
                            }
                        }
                    },
                    completion: { compressionResult in
                        
                        switch compressionResult {
                        case .onSuccess(let path):
                            DispatchQueue.main.async {
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
                                })
                            }
                            let response: [String: String] = ["onSuccess": path.path]
                            result(response.toJson)
                            
                        case .onStart: break
                            
                        case .onFailure(let error):
                            let response: [String: String] = ["onFailure": error.title]
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
