#import "TMWNotificationDetailsController.h"    // Header

#import "TMWStore.h"                            // TMW (Model)
#import "TMWRule.h"                             // TMW (Model)
#import "TMWRuleCondition.h"                    // TMW (Model)
#import "TMWNotification.h"                     // TMW (Model)
#import "TMWDateConverter.h"                    // TMW (Model)

@interface TMWNotificationDetailsController ()
@property (strong, nonatomic) IBOutlet UILabel* ruleDescription;
@property (strong,nonatomic) IBOutlet UILabel* ruleName;
@property (strong,nonatomic) IBOutlet UILabel* triggeredDate;
@property (strong,nonatomic) IBOutlet UILabel* triggeredValue;
@property (strong,nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong,nonatomic) IBOutlet UILabel* currentValue;
@end

@implementation TMWNotificationDetailsController

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TMWRule* rule = [TMWRule ruleForID:_notification.ruleID withinRulesArray:[TMWStore sharedInstance].rules];
    if (rule)
    {
        _ruleName.text = rule.name.uppercaseString;
        _ruleDescription.text = rule.thresholdDescription;
    }
    else
    {
        _ruleName.text = @"N/A";
        _ruleDescription.text = @"N/A";
    }
    
    _triggeredDate.text = [NSString stringWithFormat:@"%@ at %@", [TMWDateConverter dayOfDate:_notification.timestamp], [TMWDateConverter timeOfDate:_notification.timestamp]];
    
    NSNumber* value = [_notification convertServerValueWithMeaning:rule.condition.meaning];
    NSString* valueString = (value) ? [NSString stringWithFormat:@"%.1f", value.floatValue] : @"N/A";
    _triggeredValue.text = [NSString stringWithFormat:@"Triggered value: %@", valueString];
}

@end
