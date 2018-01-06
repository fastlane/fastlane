#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.window.backgroundColor = [UIColor whiteColor];
  UIViewController *controller = [[UIViewController alloc] init];
  self.window.rootViewController = controller;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
