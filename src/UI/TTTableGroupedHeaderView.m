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

#import "TTTableGroupedHeaderView.h"

// UI
#import "UIViewAdditions.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCoreLocale.h"

#import <QuartzCore/QuartzCore.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableGroupedHeaderView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title {
	self = [super init];
  if (self) {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _label = [[UILabel alloc] init];
    _label.text = title;
    NSLocale* locale = TTCurrentLocale();
    
    if ([locale.localeIdentifier isEqualToString:@"he"]) {
      _label.textAlignment = UITextAlignmentRight;
    }
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont boldSystemFontOfSize:17];
    _label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1];
    _label.shadowOffset = CGSizeMake(0, 1);
    _label.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1.000];
    [self addSubview:_label];
  }
  
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_label);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  _label.size = [_label sizeThatFits:CGSizeMake(self.bounds.size.width - 12,
                                                self.bounds.size.height)];
  _label.origin = CGPointMake(self.frame.size.width-_label.frame.size.width-12, floorf((self.bounds.size.height - _label.size.height)/2.f));
}


@end
