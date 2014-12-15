#import "TMWNotificationsCellView.h"    // Header

#import "TMWStore.h"            // TMW (Model)
#import "TMWRule.h"             // TMW (Model)
#import "TMWNotification.h"     // TMW (Model)
#import "TMWDateConverter.h"    // TMW (Model)

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
    _triggeredValue.text = [NSString stringWithFormat:@"Value: %@", [notification valueToString]];
}

#pragma mark - Private functionality

- (void)clearLabels
{
    _notification = nil;
    _ruleName.text = nil;
    _ruleDescription.text = nil;
    _triggeredValue.text = nil;
    _triggeredDay.text = nil;
    _triggeredTime.text = nil;
}

@end
