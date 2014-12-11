#import "TMWSegueEmbedViewInTableBacgroundkView.h"    // Header

@implementation TMWSegueEmbedViewInTableBacgroundkView

- (void)perform
{
    UITableViewController* tableVC = self.sourceViewController;
    UIViewController* childVC = self.destinationViewController;
    
    if (tableVC.tableView.backgroundView)
    {
        UIViewController* previousVC;
        for (UIViewController* childCntrll in tableVC.childViewControllers)
        {
            if ([childCntrll isViewLoaded] && childCntrll.view==tableVC.tableView.backgroundView)
            {
                previousVC = childVC;
                break;
            }
        }
        
        if (previousVC)
        {
            [previousVC willMoveToParentViewController:nil];
            [previousVC.view removeFromSuperview];
            tableVC.tableView.backgroundView = nil;
            [previousVC removeFromParentViewController];
        }
    }
    
    [tableVC addChildViewController:childVC];
    tableVC.tableView.backgroundView = childVC.view;
    [childVC didMoveToParentViewController:tableVC];
}

@end
