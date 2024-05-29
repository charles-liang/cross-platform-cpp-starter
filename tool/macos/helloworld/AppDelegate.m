#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSRect frame = NSMakeRect(0, 0, 400, 300);
  NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskResizable |
                     NSWindowStyleMaskClosable;

  self.window = [[NSWindow alloc] initWithContentRect:frame
                                            styleMask:style
                                              backing:NSBackingStoreBuffered
                                                defer:NO];
  self.window.title = @"Objective-C++ Example";

  ViewController *viewController = [[ViewController alloc] init];
  self.window.contentViewController = viewController;

  [self.window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

@end
