#import <UIKit/UIKit.h> // Apple

#import "TMWRule.h"


@interface TMWRulesTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *ruleName;
@property (strong, nonatomic) IBOutlet UILabel *ruleDescription;

- (void)setRuleDescriptionTextForRule:(TMWRule *)rule;

@end
