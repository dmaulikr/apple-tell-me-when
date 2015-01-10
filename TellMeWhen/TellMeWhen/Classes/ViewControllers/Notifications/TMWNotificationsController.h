@import UIKit;      // Apple

@interface TMWNotificationsController : UITableViewController

- (void)setupNotifications;

- (void)queryNotificationsWithCompletion:(void (^)(NSError*))completion;

@end
