#import "CatalogController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "TableImageTestController.h"
#import "TableItemTestController.h"
#import "TableControlsTestController.h"
#import "TableTestController.h"
#import "TableWithBannerController.h"
#import "TableWithShadowController.h"
#import "TableDragRefreshController.h"
#import "SearchTestController.h"
#import "MessageTestController.h"
#import "ActivityTestController.h"
#import "ScrollViewTestController.h"
#import "LauncherViewTestController.h"
#import "StyledTextTestController.h"
#import "StyledTextTableTestController.h"
#import "StyleTestController.h"
#import "ButtonTestController.h"
#import "TabBarTestController.h"
#import "DownloadProgressTestController.h"

@implementation CatalogController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Three20 Catalog";
    self.navigationItem.backBarButtonItem =
      [[[UIBarButtonItem alloc] initWithTitle:@"Catalog" style:UIBarButtonItemStyleBordered
      target:nil action:nil] autorelease];

    self.tableViewStyle = UITableViewStyleGrouped;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {
  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
    @"Photos",
    [TTTableTextItem itemWithText:@"Photo Viewer" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Photo Thumbnails" accessory:UITableViewCellAccessoryDisclosureIndicator],

    @"Styles",
    [TTTableTextItem itemWithText:@"Styled Views" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Styled Labels" accessory:UITableViewCellAccessoryDisclosureIndicator],

    @"Controls",
    [TTTableTextItem itemWithText:@"Buttons" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Tabs" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Composers" accessory:UITableViewCellAccessoryDisclosureIndicator],

    @"Tables",
    [TTTableTextItem itemWithText:@"Table Items" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Table Controls" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Styled Labels in Table" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Web Images in Table" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Table With Banner" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Table With Shadow" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Table With Drag Refresh" accessory:UITableViewCellAccessoryDisclosureIndicator],

    @"Models",
    [TTTableTextItem itemWithText:@"Model Search" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Model States" accessory:UITableViewCellAccessoryDisclosureIndicator],

    @"General",
    [TTTableTextItem itemWithText:@"Web Image" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Web Browser" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Activity Labels" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Download Progress" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Scroll View" accessory:UITableViewCellAccessoryDisclosureIndicator],
    [TTTableTextItem itemWithText:@"Launcher" accessory:UITableViewCellAccessoryDisclosureIndicator],
    nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath {

  TTViewController* vc;
  if (indexPath.section==0) {
    if (indexPath.row==0) {
      vc = [[[PhotoTest1Controller alloc] initWithNibName:nil bundle:nil] autorelease];
    } else {
      vc = [[[PhotoTest2Controller alloc] initWithNibName:nil bundle:nil] autorelease];
    }
  } else if (indexPath.section==1) {
    if (indexPath.row==0) {
      vc = [[[StyleTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else {
      vc = [[[StyledTextTestController alloc] initWithNibName:nil bundle:nil] autorelease];      
    }
  } else if (indexPath.section==2) {
    if (indexPath.row==0) {
      vc = [[[ButtonTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==1) {
      vc = [[[TabBarTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else {
      vc = [[[MessageTestController alloc] initWithNibName:nil bundle:nil] autorelease];      
    }
  } else if (indexPath.section==3) {
    if (indexPath.row==0) {
      vc = [[[TableItemTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==1) {
      vc = [[[TableControlsTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==2) {
      vc = [[[StyledTextTableTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==3) {
      vc = [[[TableImageTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    }  else if (indexPath.row==4) {
      vc = [[[TableWithBannerController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==5) {
      vc = [[[TableWithShadowController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else {
      vc = [[[TableDragRefreshController alloc] initWithNibName:nil bundle:nil] autorelease];      
    }
  } else if (indexPath.section==4) {
    if (indexPath.row==0) {
      vc = [[[SearchTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==1) {
      vc = [[[TableTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } 
  } else if (indexPath.section==5) {
    if (indexPath.row==0) {
      vc = [[[ImageTest1Controller alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==1) {
      TTWebController* webController = (TTWebController*)[[[TTWebController alloc] initWithNibName:nil bundle:nil] autorelease];
      [webController openURL:[NSURL URLWithString:@"http://three20.info"]];
      vc = webController;
      
    } else if (indexPath.row==2) {
      vc = [[[ActivityTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==3) {
      vc = [[[DownloadProgressTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    }  else if (indexPath.row==4) {
      vc = [[[ScrollViewTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else if (indexPath.row==5) {
      vc = [[[LauncherViewTestController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
  }
  
  [self.navigationController pushViewController:vc animated:YES];
}

@end
