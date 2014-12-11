#import "TMWSegueSwapRootViewController.h"  // Header

@implementation TMWSegueSwapRootViewController

- (void)perform
{
    [UIApplication sharedApplication].keyWindow.rootViewController = self.destinationViewController;
}

@end
