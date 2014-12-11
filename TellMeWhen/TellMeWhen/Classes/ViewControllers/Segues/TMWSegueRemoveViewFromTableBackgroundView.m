#import "TMWSegueRemoveViewFromTableBackgroundView.h"   // Header

@implementation TMWSegueRemoveViewFromTableBackgroundView

- (void)perform
{
    UITableViewController* tableVC = self.sourceViewController;
    UIViewController* backgroundVC = self.destinationViewController;
    
    [backgroundVC willMoveToParentViewController:nil];
    tableVC.tableView.backgroundView = nil;
    [backgroundVC removeFromParentViewController];
}

@end
