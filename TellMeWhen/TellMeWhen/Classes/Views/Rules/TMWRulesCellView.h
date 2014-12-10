@import UIKit;      // Apple

@interface TMWRulesCellView : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* logo;
@property (weak, nonatomic) IBOutlet UILabel* ruleName;
@property (weak, nonatomic) IBOutlet UILabel* ruleDescription;
@property (weak, nonatomic) IBOutlet UISwitch* activator;

@end
