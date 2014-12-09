#import "TMWRootViewControllerSwapSegue.h"  // Header

@implementation TMWRootViewControllerSwapSegue

- (void)perform
{
    [UIApplication sharedApplication].keyWindow.rootViewController = self.destinationViewController;
}

@end
