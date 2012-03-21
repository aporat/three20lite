#import "AppDelegate.h"
#import "CatalogController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize masterController = _masterController;


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  

  CatalogController* vc = [[[CatalogController alloc] initWithNibName:nil bundle:nil] autorelease];
  _masterController = [[TTBaseNavigationController alloc] initWithRootViewController:vc];
  [_window addSubview:_masterController.view];    
  
  [self.window makeKeyAndVisible];

  return YES;
  
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}


- (void)dealloc {
  [_window release];
  [_masterController release];
  [super dealloc];
}

@end
