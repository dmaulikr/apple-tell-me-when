@import UIKit;      // Apple
@class TMWRule;     // TMW (Model)

@interface TMWRuleNamingController : UITableViewController

@property (strong,nonatomic) TMWRule* rule;

@property (nonatomic) BOOL needsServerModification;

@end
