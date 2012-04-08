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

#import "TTTableSettingsItemCell.h"

// UI
#import "TTTableSettingsItem.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableSettingsItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
  if (self) {

  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  NSLocale* locale = TTCurrentLocale();
  if ([locale.localeIdentifier isEqualToString:@"he"]) {
    self.textLabel.textAlignment = UITextAlignmentRight; 
    self.detailTextLabel.textAlignment = UITextAlignmentLeft;

    self.detailTextLabel.frame = CGRectMake(30, 
                                      self.detailTextLabel.frame.origin.y, 
                                      self.detailTextLabel.frame.size.width, 
                                      self.detailTextLabel.frame.size.height);
    
    self.textLabel.frame = CGRectMake(self.contentView.frame.size.width - self.textLabel.frame.size.width - 10, 
                                      self.textLabel.frame.origin.y, 
                                      self.textLabel.frame.size.width, 
                                      self.textLabel.frame.size.height);
    
    
  }
  
  

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableSettingsItem* item = object;
    self.textLabel.text = item.caption;
    self.detailTextLabel.text = item.text;
  }
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
  return self.textLabel;
}


@end
