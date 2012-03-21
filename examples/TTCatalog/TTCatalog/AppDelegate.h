#import <Three20Lite/Three20Lite.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> {
   TTBaseNavigationController* _masterController;
}

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, retain) TTBaseNavigationController* masterController;

@end

