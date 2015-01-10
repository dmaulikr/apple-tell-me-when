#import "TMWNavNotificationsController.h"   // Header
#import "TMWNotificationsController.h"      // TMW (ViewControllers/Notifications)

@interface TMWNavNotificationsController ()
@property (readonly,nonatomic) TMWNavNotificationsController* notificationController;
@end

@implementation TMWNavNotificationsController

#pragma mark - Public API

- (void)setupNotifications
{
    [self.notificationController setupNotifications];
}

- (void)queryNotificationsWithCompletion:(void (^)(NSError* error))completion
{
    [self.notificationController queryNotificationsWithCompletion:completion];
}

- (void)notificationDidArrived:(NSDictionary*)userInfo
{
    [self queryNotificationsWithCompletion:nil];
}

#pragma mark - Private functionality

- (TMWNavNotificationsController*)notificationController
{
    TMWNavNotificationsController* result;
    for (UIViewController* cntrll in self.childViewControllers)
    {
        if ([cntrll isKindOfClass:[TMWNotificationsController class]]) { result = (TMWNavNotificationsController*)cntrll; break; }
    }
    return result;
}

@end
