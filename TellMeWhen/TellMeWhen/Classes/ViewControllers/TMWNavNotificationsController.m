#import "TMWNavNotificationsController.h"   // Header

@interface TMWNavNotificationsController ()
@property (readonly,nonatomic) TMWNavNotificationsController* notificationController;
@end

@implementation TMWNavNotificationsController

#pragma mark - Public API

- (void)queryNotifications
{
    [self.notificationController queryNotifications];
}

- (void)notificationDidArrived:(NSDictionary*)userInfo
{
    [self queryNotifications];
}

#pragma mark - Private functionality

- (TMWNavNotificationsController*)notificationController
{
    TMWNavNotificationsController* result;
    for (UIViewController* cntrll in self.childViewControllers)
    {
        if ([cntrll isKindOfClass:[TMWNavNotificationsController class]]) { result = (TMWNavNotificationsController*)cntrll; break; }
    }
    return result;
}

@end
