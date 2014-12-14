@import UIKit;      // Apple
@class TMWRule;     // TMW (Model)

@interface TMWRuleTransmittersController : UITableViewController

@property (strong,nonatomic) TMWRule* rule;

@property (nonatomic) BOOL needsServerModification;

@end
