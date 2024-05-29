#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = [NSApplication sharedApplication];
    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    app.delegate = appDelegate;
    return NSApplicationMain(argc, argv);
  }
}
