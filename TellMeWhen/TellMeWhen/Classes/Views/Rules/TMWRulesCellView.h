#import "TMWTableViewCell.h"    // TMW (Views)

@interface TMWRulesCellView : TMWTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* logo;
@property (weak, nonatomic) IBOutlet UILabel* ruleName;
@property (weak, nonatomic) IBOutlet UILabel* ruleDescription;
@property (weak, nonatomic) IBOutlet UISwitch* activator;

@end
