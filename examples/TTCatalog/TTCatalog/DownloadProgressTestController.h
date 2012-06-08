#import <Three20Lite/Three20Lite.h>

@class DownloadTestModel;
@interface DownloadProgressTestController : UIViewController <TTModelDelegate> {
  NSUInteger        _defaultMaxContentLength;
  TTActivityLabel   *_activityLabel;
  DownloadTestModel *_loadingModel;
  NSTimer           *_progressTimer;
}
@end
