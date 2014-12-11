#import "TMWSegueSwapChildController.h"     // Header
#import "TMWActions.h"                      // TMW (ViewController)

#pragma mark - Definitions

#define TMWSegueShowChildCntrll_TransitionDuration  0.3

@implementation TMWSegueSwapChildController

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
    }
    
    if ([futureChildVC respondsToSelector:@selector(loadIoTsWithCompletion:)])
    {
        [(UIViewController<TMWActions>*)futureChildVC loadIoTsWithCompletion:nil];
    }
}

@end
