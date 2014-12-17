@import UIKit;      // Apple

@interface TMWNavRulesController : UINavigationController

- (void)queryRulesWithCompletion:(void (^)(NSError*))completion;

- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData;

@end
