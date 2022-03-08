#import "TdlibPrintThermalPlugin.h"
#import <tdlib_print_thermal/tdlib_print_thermal-Swift.h>

@implementation TdlibPrintThermalPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTdlibPrintThermalPlugin registerWithRegistrar:registrar];
}
@end
