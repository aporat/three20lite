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

#import "TTTableLinkedItemCell.h"

// UI
#import "TTTableLinkedItem.h"
#import "TTImageView.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableLinkedItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_item);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
  return _item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [_item release];
    _item = [object retain];

    TTTableLinkedItem* item = object;

    if (item.accessoryType) {
        NSLocale* locale = TTCurrentLocale();
        if ([locale.localeIdentifier isEqualToString:@"he"]) {
          [_moreView removeFromSuperview];
          TT_RELEASE_SAFELY(_moreView);
          
          _moreView = [[TTImageView alloc] init];
          UITableView* tableView = (UITableView*)self.superview;
          if (tableView.style == UITableViewStylePlain) {
            _moreView.frame = CGRectMake(10, 16, 9, 13);
          } else {
            _moreView.frame = CGRectMake(10, 16, 9, 13);          
          }
          _moreView.urlPath = @"bundle://more.png";
          [self.contentView addSubview:_moreView]; 
        } else {
          self.accessoryType = item.accessoryType;
        }
      } else {
        NSLocale* locale = TTCurrentLocale();
         if ([locale.localeIdentifier isEqualToString:@"he"]) {
           [_moreView removeFromSuperview];
           TT_RELEASE_SAFELY(_moreView);
         }

    }
  }
}


@end
