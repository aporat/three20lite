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

#import "TTThumbsViewController.h"

// UI
#import "TTThumbsDataSource.h"
#import "TTThumbsTableViewCell.h"
#import "TTPhoto.h"
#import "TTPhotoSource.h"
#import "TTPhotoViewController.h"
#import "UIViewAdditions.h"

// UINavigator
#import "TTGlobalNavigatorMetrics.h"

// UICommon
#import "TTGlobalUICommon.h"
#import "UIViewControllerAdditions.h"

// Style
#import "TTGlobalStyle.h"
#import "TTStyleSheet.h"

// Core
#import "TTGlobalCoreLocale.h"
#import "TTGlobalCoreRects.h"
#import "TTCorePreprocessorMacros.h"

static CGFloat kThumbnailRowHeight = 79.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTThumbsViewController

@synthesize delegate    = _delegate;
@synthesize photoSource = _photoSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.wantsFullScreenLayout = YES;
    self.hidesBottomBarWhenPushed = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<TTThumbsViewControllerDelegate>)delegate {
	self = [self initWithNibName:nil bundle:nil];
  if (self) {
    self.delegate = delegate;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithQuery:(NSDictionary*)query {
  id<TTThumbsViewControllerDelegate> delegate = [query objectForKey:@"delegate"];
  if (nil != delegate) {
    self = [self initWithDelegate:delegate];

  } else {
    self = [self initWithNibName:nil bundle:nil];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [self initWithNibName:nil bundle:nil];
  if (self) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_photoSource.delegates removeObject:self];
  TT_RELEASE_SAFELY(_photoSource);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoadingThumbnails:(BOOL)suspended {
  if (_photoSource.maxPhotoIndex >= 0) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      TTThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[TTThumbsTableViewCell class]]) {
        [cell suspendLoading:suspended];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTableLayout {
  self.tableView.contentInset = UIEdgeInsetsMake(TTBarsHeight()+4, 0, 0, 0);
  self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(TTBarsHeight(), 0, 0, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLForPhoto:(id<TTPhoto>)photo {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.tableView.rowHeight = kThumbnailRowHeight;
  self.tableView.autoresizingMask =
  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self updateTableLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self suspendLoadingThumbnails:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated {
  [self suspendLoadingThumbnails:YES];
  [super viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self updateTableLayout];
  [self.tableView reloadData];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<TTThumbsViewControllerDelegate>)delegate {
  _delegate = delegate;

  if (_delegate) {
    self.navigationItem.leftBarButtonItem =
    [[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] init]
                                                  autorelease]]
     autorelease];
    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"Done", @"")
                                      style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(removeFromSupercontroller)] autorelease];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
  [super didRefreshModel];
  self.title = _photoSource.title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForOverlayView {
  return TTRectContract(CGRectOffset([super rectForOverlayView], 0, TTBarsHeight()-_tableView.top),
                        0, TTBarsHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTThumbsTableViewCellDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
  [_delegate thumbsViewController:self didSelectPhoto:photo];

  BOOL shouldNavigate = YES;
  if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
    shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
  }

  if (shouldNavigate) {
    TTPhotoViewController* controller = [self createPhotoViewController];
    controller.centerPhoto = photo;
    [self.navigationController pushViewController:controller animated:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    self.title = _photoSource.title;
    self.dataSource = [self createDataSource];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTPhotoViewController*)createPhotoViewController {
  return [[[TTPhotoViewController alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTTableViewDataSource>)createDataSource {
  return [[[TTThumbsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
}


@end
