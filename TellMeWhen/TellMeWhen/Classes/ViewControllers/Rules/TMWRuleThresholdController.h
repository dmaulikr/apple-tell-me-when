@import UIKit;      // Apple
@class TMWRule;     // TMW (Model)

@interface TMWRuleThresholdController : UITableViewController

@property (strong,nonatomic) TMWRule* rule;

@property (nonatomic) BOOL needsServerModification;

@property (strong,nonatomic) TMWRule* tmpRule;

@end
