#import "LightCompressorPlugin.h"
#if __has_include(<light_compressor/light_compressor-Swift.h>)
#import <light_compressor/light_compressor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "light_compressor-Swift.h"
#endif

@implementation LightCompressorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLightCompressorPlugin registerWithRegistrar:registrar];
}
@end
