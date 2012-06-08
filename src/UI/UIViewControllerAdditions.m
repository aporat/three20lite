//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UIViewControllerAdditions.h"

// UICommon
#import "TTGlobalUICommon.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCore.h"
#import "TTDebug.h"
#import "TTDebugFlags.h"

static NSMutableDictionary* gSuperControllers = nil;
static NSMutableDictionary* gPopupViewControllers = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIViewControllerAdditions)

@implementation UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBeTopViewController {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)superController {
  UIViewController* parent = self.parentViewController;
  if (nil != parent) {
    return parent;

  } else if ([self respondsToSelector:@selector(presentingViewController)]) {
    return [self presentingViewController];

  } else {
    NSString* key = [NSString stringWithFormat:@"%d", self.hash];
    return [gSuperControllers objectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSuperController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (nil != viewController) {
    if (nil == gSuperControllers) {
      gSuperControllers = TTCreateNonRetainingDictionary();
    }
    [gSuperControllers setObject:viewController forKey:key];

  } else {
    [gSuperControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topSubcontroller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:controllerIndex+1];
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)popupViewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gPopupViewControllers objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPopupViewController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (viewController) {
    if (!gPopupViewControllers) {
      gPopupViewControllers = TTCreateNonRetainingDictionary();
    }
    [gPopupViewControllers setObject:viewController forKey:key];

  } else {
    [gPopupViewControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontroller {
  [self removeFromSupercontrollerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontrollerAnimated:(BOOL)animated {
  if (self.navigationController) {
    [self.navigationController popViewControllerAnimated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayDidEnd {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showNavigationBar:(BOOL)show animated:(BOOL)animated {

  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  }
  self.navigationController.navigationBar.alpha = show ? 1 : 0;
  if (animated) {
    [UIView commitAnimations];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBars:(BOOL)show animated:(BOOL)animated {

  [[UIApplication sharedApplication] setStatusBarHidden:!show
                                          withAnimation:(animated
                                                          ? UIStatusBarAnimationFade
                                                          :UIStatusBarAnimationNone)];

  [self showNavigationBar:show animated:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissModalViewController {
  [self dismissModalViewControllerAnimated:YES];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTGarbageCollection)




@end
