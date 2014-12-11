#import "TMWSegueEmbedViewInTableBacgroundkView.h"    // Header

@implementation TMWSegueEmbedViewInTableBacgroundkView

- (void)perform
{
    UITableViewController* tableVC = self.sourceViewController;
    UIViewController* childVC = self.destinationViewController;
    
    [tableVC addChildViewController:childVC];
    tableVC.tableView.backgroundView = childVC.view;
    [childVC didMoveToParentViewController:tableVC];
}

@end
