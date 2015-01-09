@import UIKit;      // Apple

@interface TMWNavNotificationsController : UINavigationController

- (void)queryNotifications;

- (void)setupNotifications;

- (void)notificationDidArrived:(NSDictionary*)userInfo;

@end
