@import UIKit;      // Apple

@interface TMWNavNotificationsController : UINavigationController

- (void)queryNotifications;

- (void)notificationDidArrived:(NSDictionary*)userInfo;

@end
