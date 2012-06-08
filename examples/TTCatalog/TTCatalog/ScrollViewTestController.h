#import <Three20Lite/Three20Lite.h>

@interface ScrollViewTestController : UIViewController <TTScrollViewDataSource, TTScrollViewDelegate> {
  TTScrollView* _scrollView;
  TTPageControl* _pageControl;
  NSArray* _colors;
}

@end
