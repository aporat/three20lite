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

#import "TTTableViewDelegate.h"

// UI
#import "TTTableViewDataSource.h"
#import "TTTableViewController.h"
#import "TTTableHeaderView.h"
#import "TTTableGroupedHeaderView.h"
#import "TTTableView.h"
#import "TTStyledTextLabel.h"

// - Table Items
#import "TTTableItem.h"
#import "TTTableLinkedItem.h"
#import "TTTableButton.h"
#import "TTTableMoreButton.h"

// - Table Item Cells
#import "TTTableMoreButtonCell.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"

// Network
#import "TTURLRequestQueue.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCoreLocale.h"

static const CGFloat kEmptyHeaderHeight = 0.0f;
static const CGFloat kSectionHeaderHeight = 22.0f;
static const CGFloat kGroupedSectionHeaderHeight = 36.0f;
static const CGFloat kGroupedSectionFirstHeaderHeight = 36.0f + 10.0f;
static const NSUInteger kFirstTableSection = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewDelegate

@synthesize controller = _controller;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(TTTableViewController*)controller {
  self = [super init];
  if (self) {
    _controller = controller;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_headers);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * If tableHeaderTintColor has been specified in the global style sheet and this is a plain table
 * (i.e. not a grouped one), then we create header view objects for each header and handle the
 * drawing ourselves.
 */
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSLocale* locale = TTCurrentLocale();

  if (tableView.style == UITableViewStylePlain && [locale.localeIdentifier isEqualToString:@"he"]) {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
      NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
      if (title.length > 0) {
        TTTableHeaderView* header = [_headers objectForKey:title];

        // If retrieved from cache, prepare for reuse here.
        // We reset the the opacity to 1 because UITableView might set this property to 0 after
        // removing it.
        // TODO (jverkoey Feb 26, 2011): When does this happen, exactly?
        if (nil != header) {
          header.alpha = 1;

        } else {
          if (nil == _headers) {
            _headers = [[NSMutableDictionary alloc] init];
          }
          header = [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
          [_headers setObject:header forKey:title];
        }
        return header;
      }
    }
  } else if (tableView.style == UITableViewStyleGrouped && [locale.localeIdentifier isEqualToString:@"he"]) {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
      NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
      if (title.length > 0) {
        TTTableGroupedHeaderView* header = [_headers objectForKey:title];
        
        // If retrieved from cache, prepare for reuse here.
        // We reset the the opacity to 1 because UITableView might set this property to 0 after
        // removing it.
        // TODO (jverkoey Feb 26, 2011): When does this happen, exactly?
        if (nil != header) {
          header.alpha = 1;
          
        } else {
          if (nil == _headers) {
            _headers = [[NSMutableDictionary alloc] init];
          }
          header = [[[TTTableGroupedHeaderView alloc] initWithTitle:title] autorelease];
          [_headers setObject:header forKey:title];
        }
        return header;
      }
    }
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
    NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    if (![title length]) {
      return kEmptyHeaderHeight;
    }

    if (tableView.style == UITableViewStylePlain) {
      return kSectionHeaderHeight;

    } else {
      if (section == kFirstTableSection) {
        return kGroupedSectionFirstHeaderHeight;
      }
      return kGroupedSectionHeaderHeight;
    }

  }
  return kEmptyHeaderHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * When the user taps a cell item, we check whether the tapped item has an attached URL and, if
 * it has one, we navigate to it. This also handles the logic for "Load more" buttons.
 */
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
  id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  if ([object isKindOfClass:[TTTableLinkedItem class]]) {
    TTTableLinkedItem* item = object;
    if (item.delegate && item.selector) {
      [item.delegate performSelector:item.selector withObject:object];
    }

    if ([object isKindOfClass:[TTTableButton class]]) {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];

    } else if ([object isKindOfClass:[TTTableMoreButton class]]) {
      TTTableMoreButton* moreLink = (TTTableMoreButton*)object;
      moreLink.isLoading = YES;
      TTTableMoreButtonCell* cell
        = (TTTableMoreButtonCell*)[tableView cellForRowAtIndexPath:indexPath];
      cell.animating = YES;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];

      if (moreLink.model) {
        [moreLink.model load:TTURLRequestCachePolicyDefault more:YES];

      } else {
        [_controller.model load:TTURLRequestCachePolicyDefault more:YES];
      }
    }
  }

  [_controller didSelectObject:object atIndexPath:indexPath];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_controller.menuView) {
    [_controller hideMenu:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;

  [_controller didBeginDragging];

  if ([scrollView isKindOfClass:[TTTableView class]]) {
    TTTableView* tableView = (TTTableView*)scrollView;
    tableView.highlightedLabel.highlightedNode = nil;
    tableView.highlightedLabel = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [TTURLRequestQueue mainQueue].suspended = NO;
  }

  [_controller didEndDragging];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_controller.menuView) {
    [_controller hideMenu:YES];
  }
}


@end
