@import UIKit;      // Apple

@interface TMWRulesController : UITableViewController

- (void)queryRulesWithCompletion:(void (^)(NSError*))completion;

@end
