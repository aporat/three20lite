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

#import "TTModelViewController.h"

// UICommon
#import "UIViewControllerAdditions.h"

// Network
#import "TTModel.h"

// Core
#import "TTCorePreprocessorMacros.h"


// UICommon
#import "TTGlobalUICommon.h"
#import "UIViewControllerAdditions.h"

// Core
#import "TTDebug.h"
#import "TTDebugFlags.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTModelViewController

@synthesize model       = _model;
@synthesize modelError  = _modelError;
@synthesize navigationBarStyle      = _navigationBarStyle;
@synthesize navigationBarTintColor  = _navigationBarTintColor;
@synthesize statusBarStyle          = _statusBarStyle;
@synthesize isViewAppearing         = _isViewAppearing;
@synthesize hasViewAppeared         = _hasViewAppeared;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _navigationBarStyle = UIBarStyleDefault;
    _statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    _flags.isViewInvalid = YES;
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
  [_model.delegates removeObject:self];
  TT_RELEASE_SAFELY(_model);
  TT_RELEASE_SAFELY(_modelError);
  
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"DEALLOC %@", self);
    
  TT_RELEASE_SAFELY(_navigationBarTintColor);
  TT_RELEASE_SAFELY(_frozenState);
  
  // You would think UIViewController would call this in dealloc, but it doesn't!
  // I would prefer not to have to redundantly put all view releases in dealloc and
  // viewDidUnload, so my solution is just to call viewDidUnload here.
  [self viewDidUnload];
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetViewStates {
  if (_flags.isShowingLoading) {
    [self showLoading:NO];
    _flags.isShowingLoading = NO;
  }
  if (_flags.isShowingModel) {
    [self showModel:NO];
    _flags.isShowingModel = NO;
  }
  if (_flags.isShowingError) {
    [self showError:NO];
    _flags.isShowingError = NO;
  }
  if (_flags.isShowingEmpty) {
    [self showEmpty:NO];
    _flags.isShowingEmpty = NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateViewStates {
  if (_flags.isModelDidRefreshInvalid) {
    [self didRefreshModel];
    _flags.isModelDidRefreshInvalid = NO;
  }
  if (_flags.isModelWillLoadInvalid) {
    [self willLoadModel];
    _flags.isModelWillLoadInvalid = NO;
  }
  if (_flags.isModelDidLoadInvalid) {
    [self didLoadModel:_flags.isModelDidLoadFirstTimeInvalid];
    _flags.isModelDidLoadInvalid = NO;
    _flags.isModelDidLoadFirstTimeInvalid = NO;
    _flags.isShowingModel = NO;
  }

  BOOL showModel = NO, showLoading = NO, showError = NO, showEmpty = NO;

  if (_model.isLoaded || ![self shouldLoad]) {
    if ([self canShowModel]) {
      showModel = !_flags.isShowingModel;
      _flags.isShowingModel = YES;

    } else {
      if (_flags.isShowingModel) {
        [self showModel:NO];
        _flags.isShowingModel = NO;
      }
    }

  } else {
    if (_flags.isShowingModel) {
      [self showModel:NO];
      _flags.isShowingModel = NO;
    }
  }

  if (_model.isLoading) {
    showLoading = !_flags.isShowingLoading;
    _flags.isShowingLoading = YES;

  } else {
    if (_flags.isShowingLoading) {
      [self showLoading:NO];
      _flags.isShowingLoading = NO;
    }
  }

  if (_modelError) {
    showError = !_flags.isShowingError;
    _flags.isShowingError = YES;

  } else {
    if (_flags.isShowingError) {
      [self showError:NO];
      _flags.isShowingError = NO;
    }
  }

  if (!_flags.isShowingLoading && !_flags.isShowingModel && !_flags.isShowingError) {
    showEmpty = !_flags.isShowingEmpty;
    _flags.isShowingEmpty = YES;

  } else {
    if (_flags.isShowingEmpty) {
      [self showEmpty:NO];
      _flags.isShowingEmpty = NO;
    }
  }

  if (showModel) {
    [self showModel:YES];
    [self didShowModel:_flags.isModelDidShowFirstTimeInvalid];
    _flags.isModelDidShowFirstTimeInvalid = NO;
  }
  if (showEmpty) {
    [self showEmpty:YES];
  }
  if (showError) {
    [self showError:YES];
  }
  if (showLoading) {
    [self showLoading:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createInterstitialModel {
  self.model = [[[TTModel alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  _isViewAppearing = YES;
  _hasViewAppeared = YES;

  [self updateView];

  _isViewAppearing = YES;
  _hasViewAppeared = YES;
  
  if (!self.popupViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    bar.tintColor = _navigationBarTintColor;
    bar.barStyle = _navigationBarStyle;
    
    if (!TTIsPad()) {
      [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
    }
  }
  
  [super viewWillAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
  
  if (_hasViewAppeared && !_isViewAppearing) {
    TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"MEMORY WARNING FOR %@", self);
    
    if (_hasViewAppeared && !_isViewAppearing) {
      NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
      [self persistView:state];
      self.frozenState = state;
      TT_RELEASE_SAFELY(state);
      
      // This will come around to calling viewDidUnload
      [super didReceiveMemoryWarning];
      
      _hasViewAppeared = NO;
      
    } else {
      [super didReceiveMemoryWarning];
    }
    
    [self resetViewStates];
    [self refresh];

  } else {
    TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"MEMORY WARNING FOR %@", self);
    
    if (_hasViewAppeared && !_isViewAppearing) {
      NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
      [self persistView:state];
      self.frozenState = state;
      TT_RELEASE_SAFELY(state);
      
      // This will come around to calling viewDidUnload
      [super didReceiveMemoryWarning];
      
      _hasViewAppeared = NO;
      
    } else {
      [super didReceiveMemoryWarning];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayDidEnd {
  [self invalidateModel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<TTModel>)model {
  if (model == self.model) {
    _flags.isModelWillLoadInvalid = YES;
    _flags.isModelDidLoadFirstTimeInvalid = YES;
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
  if (model == _model) {
    TT_RELEASE_SAFELY(_modelError);
    _flags.isModelDidLoadInvalid = YES;
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    self.modelError = error;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
  if (model == _model) {
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidChange:(id<TTModel>)model {
  if (model == _model) {
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidBeginUpdates:(id<TTModel>)model {
  if (model == _model) {
    [self beginUpdates];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidEndUpdates:(id<TTModel>)model {
  if (model == _model) {
    [self endUpdates];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  if (!_model) {
    [self createModel];
  }
  
  if (!_model) {
    [self createInterstitialModel];
  }
  return _model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setModel:(id<TTModel>)model {
  if (_model != model) {
    [_model.delegates removeObject:self];
    [_model release];
    _model = [model retain];
    [_model.delegates addObject:self];
    TT_RELEASE_SAFELY(_modelError);

    if (_model) {
      _flags.isModelWillLoadInvalid = NO;
      _flags.isModelDidLoadInvalid = NO;
      _flags.isModelDidLoadFirstTimeInvalid = NO;
      _flags.isModelDidShowFirstTimeInvalid = YES;
    }

    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setModelError:(NSError*)error {
  if (error != _modelError) {
    [_modelError release];
    _modelError = [error retain];

    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidateModel {
  BOOL wasModelCreated = self.isModelCreated;
  [self resetViewStates];
  [_model.delegates removeObject:self];
  TT_RELEASE_SAFELY(_model);
  if (wasModelCreated) {
    [self model];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isModelCreated {
  return !!_model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoad {
  return !self.model.isLoaded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldReload {
  return !_modelError && self.model.isOutdated;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoadMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canShowModel {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  _flags.isViewInvalid = YES;
  [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadIfNeeded {
  if ([self shouldReload] && !self.model.isLoading) {
    [self reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refresh {
  _flags.isViewInvalid = YES;
  _flags.isModelDidRefreshInvalid = YES;

  BOOL loading = self.model.isLoading;
  BOOL loaded = self.model.isLoaded;
  if (!loading && !loaded && [self shouldLoad]) {
    [self.model load:TTURLRequestCachePolicyDefault more:NO];

  } else if (!loading && loaded && [self shouldReload]) {
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];

  } else if (!loading && [self shouldLoadMore]) {
    [self.model load:TTURLRequestCachePolicyDefault more:YES];

  } else {
    _flags.isModelDidLoadInvalid = YES;
    if (_isViewAppearing) {
      [self updateView];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beginUpdates {
  _flags.isViewSuspended = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endUpdates {
  _flags.isViewSuspended = NO;
  [self updateView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidateView {
  _flags.isViewInvalid = YES;
  if (_isViewAppearing) {
    [self updateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateView {
  if (_flags.isViewInvalid && !_flags.isViewSuspended && !_flags.isUpdatingView) {
    _flags.isUpdatingView = YES;

    // Ensure the model is created
    [self model];
    // Ensure the view is created
    [self view];

    [self updateViewStates];

    if (_frozenState && _flags.isShowingModel) {
      [self restoreView:_frozenState];
      TT_RELEASE_SAFELY(_frozenState);
    }

    _flags.isViewInvalid = NO;
    _flags.isUpdatingView = NO;

    [self reloadIfNeeded];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willLoadModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didShowModel:(BOOL)firstTime {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showModel:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)frozenState {
  return _frozenState;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrozenState:(NSDictionary*)frozenState {
  [_frozenState release];
  _frozenState = [frozenState retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  _isViewAppearing = NO;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (TTIsPad()) {
    return YES;
    
  } else {
    UIViewController* popup = [self popupViewController];
    if (popup) {
      return [popup shouldAutorotateToInterfaceOrientation:interfaceOrientation];
      
    } else {
      return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  UIViewController* popup = [self popupViewController];
  
  if (popup) {
    return [popup willAnimateRotationToInterfaceOrientation: fromInterfaceOrientation
                                                   duration: duration];
    
  } else {
    return [super willAnimateRotationToInterfaceOrientation: fromInterfaceOrientation
                                                   duration: duration];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  UIViewController* popup = [self popupViewController];
  
  if (popup) {
    return [popup didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
  } else {
    return [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingHeaderView {
  UIViewController* popup = [self popupViewController];
  
  if (popup) {
    return [popup rotatingHeaderView];
    
  } else {
    return [super rotatingHeaderView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingFooterView {
  UIViewController* popup = [self popupViewController];
  
  if (popup) {
    return [popup rotatingFooterView];
    
  } else {
    return [super rotatingFooterView];
  }
}



@end
