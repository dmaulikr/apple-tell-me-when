@import UIKit;      // Apple

@interface TMWNavNotificationsController : UINavigationController

- (void)setupNotifications;

- (void)queryNotificationsWithCompletion:(void (^)(NSError*))completion;

- (void)notificationDidArrived:(NSDictionary*)userInfo;

@end
