@import UIKit;      // Apple

@interface TMWNavRulesController : UINavigationController

- (void)queryRules;

- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData;

@end
