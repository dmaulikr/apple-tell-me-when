#import "TMWNotificationsCellView.h"    // Header

#import "TMWStore.h"            // TMW (Model)
#import "TMWRule.h"             // TMW (Model)
#import "TMWRuleCondition.h"    // TMW (Model)
#import "TMWNotification.h"     // TMW (Model)
#import "TMWDateConverter.h"    // TMW (Model)

#pragma mark - Definitions

#define TMWNotificationCellView_Unknown     @"N/A"

@interface TMWNotificationsCellView ()
@property (weak, nonatomic) IBOutlet UILabel* ruleName;
@property (weak, nonatomic) IBOutlet UILabel* ruleDescription;
@property (weak, nonatomic) IBOutlet UILabel* triggeredDay;
@property (weak, nonatomic) IBOutlet UILabel* triggeredTime;
@property (weak, nonatomic) IBOutlet UILabel* triggeredValue;
@end

@implementation TMWNotificationsCellView

#pragma mark - Public API

- (void)setNotification:(TMWNotification*)notification
{
    TMWRule* rule = [TMWRule ruleForID:notification.ruleID withinRulesArray:[TMWStore sharedInstance].rules];
    if (!rule) { return [self clearLabels]; }
 
    _notification = notification;
    _ruleName.text = rule.name;
    _ruleDescription.text = rule.thresholdDescription;
    _triggeredDay.text = [TMWDateConverter dayOfDate:notification.timestamp];
    _triggeredTime.text = [TMWDateConverter timeOfDate:notification.timestamp];
    
    NSNumber* value = [notification convertServerValueWithMeaning:rule.condition.meaning];
    NSString* valueString = (value) ? [NSString stringWithFormat:@"%.1f", value.floatValue] : TMWNotificationCellView_Unknown;
    _triggeredValue.text = [NSString stringWithFormat:@"Triggered value: %@", valueString];
}

#pragma mark - Private functionality

- (void)clearLabels
{
    _notification = nil;
    _ruleName.text = TMWNotificationCellView_Unknown;
    _ruleDescription.text = TMWNotificationCellView_Unknown;
    _triggeredValue.text = TMWNotificationCellView_Unknown;
    _triggeredDay.text = TMWNotificationCellView_Unknown;
    _triggeredTime.text = TMWNotificationCellView_Unknown;
}

@end
