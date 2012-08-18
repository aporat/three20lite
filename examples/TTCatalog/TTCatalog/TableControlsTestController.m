#import "TableControlsTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableControlsTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.tableViewStyle = UITableViewStyleGrouped;
    self.variableHeightRows = YES;

    UITextField* textField = [[[UITextField alloc] init] autorelease];
    textField.placeholder = @"UITextField";
    textField.font = TTSTYLEVAR(font);

    UITextField* textField2 = [[[UITextField alloc] init] autorelease];
    textField2.font = TTSTYLEVAR(font);
    textField2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    TTTableControlItem* textFieldItem = [TTTableControlItem itemWithCaption:@"TTTableControlItem"
                                                            control:textField2];

    UITextView* textView = [[[UITextView alloc] init] autorelease];
    textView.text = @"UITextView";
    textView.font = TTSTYLEVAR(font);

    UISwitch* switchy = [[[UISwitch alloc] init] autorelease];
    TTTableControlItem* switchItem = [TTTableControlItem itemWithCaption:@"UISwitch" control:switchy];

    UISlider* slider = [[[UISlider alloc] init] autorelease];
    TTTableControlItem* sliderItem = [TTTableControlItem itemWithCaption:@"UISlider" control:slider];

    self.dataSource = [TTListDataSource dataSourceWithObjects:
      textField,
      textView,
      textFieldItem,
      switchItem,
      sliderItem,
      nil];
  }
  return self;
}

@end
