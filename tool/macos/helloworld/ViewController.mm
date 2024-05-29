#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSButton *button = [NSButton buttonWithTitle:@"Click Me"
                                        target:self
                                        action:@selector(buttonClicked:)];
  button.frame = NSMakeRect(100, 100, 100, 50);
  [self.view addSubview:button];
}

- (void)buttonClicked:(id)sender {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Button Clicked!"];
  [alert runModal];
}

@end
