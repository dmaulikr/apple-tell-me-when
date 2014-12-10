#import "TMWSegueShowChildController.h"    // Header

#pragma mark - Definitions

#define TMWSegueShowChildCntrll_TransitionDuration  0.3

@implementation TMWSegueShowChildController

#pragma mark - Public API

- (void)perform
{
    UIViewController* containerVC = self.sourceViewController;
    UIViewController* previousChildVC = containerVC.childViewControllers.firstObject;
    UIViewController* futureChildVC = self.destinationViewController;
    if (previousChildVC == futureChildVC) { return; }
    
    if (!containerVC.childViewControllers.count)
    {
        [containerVC addChildViewController:futureChildVC];
        [containerVC.view addSubview:futureChildVC.view];
        [futureChildVC didMoveToParentViewController:containerVC];
    }
    else
    {
        [previousChildVC willMoveToParentViewController:nil];
        [containerVC addChildViewController:futureChildVC];
        
        [previousChildVC.view removeFromSuperview];
        [containerVC.view addSubview:futureChildVC.view];
        
        [previousChildVC removeFromParentViewController];
        [futureChildVC didMoveToParentViewController:containerVC];
//        [containerVC transitionFromViewController:previousChildVC toViewController:futureChildVC duration:TMWSegueShowChildCntrll_TransitionDuration options:UIViewAnimationOptionCurveEaseOut animations:<#^(void)animations#> completion:<#^(BOOL finished)completion#>]
    }
}

@end
