#import "TMWRulesTableViewCell.h" // Header
#import "TMWRuleCondition.h"


@implementation TMWRulesTableViewCell


#pragma mark - Public Methods

- (void)setRuleDescriptionTextForRule:(TMWRule *)rule {
    _ruleDescription.text = [NSString stringWithFormat:@"%@ %@", rule.type, rule.thresholdDescription];
}

@end
