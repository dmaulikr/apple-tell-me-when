#import "TMWNotificationDetailsController.h"    // Header

#import "TMWStore.h"                            // TMW (Model)
#import "TMWRule.h"                             // TMW (Model)
#import "TMWRuleCondition.h"                    // TMW (Model)
#import "TMWNotification.h"                     // TMW (Model)
#import "TMWDateConverter.h"                    // TMW (Model)

#define TMWNotificationDetails_CellValue(type, num, unit)   [NSString stringWithFormat:@"%@ = %.1f %@", type, ((NSNumber*)num).floatValue, unit]
#define TMWNotificationDetailsCntrll_SubscriptionError     @"Error subscripbing to MQTT channel"
#define TMWNotificationDetailsCntrll_SubscriptionUnknown   @"N/A"

@interface TMWNotificationDetailsController ()
@property (readonly,nonatomic) TMWRule* notificationRule;
@property (strong, nonatomic) IBOutlet UILabel* ruleDescription;
@property (strong,nonatomic) IBOutlet UILabel* ruleName;
@property (strong,nonatomic) IBOutlet UILabel* triggeredDate;
@property (strong,nonatomic) IBOutlet UILabel* triggeredValue;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* currentValueIndicator;
@property (strong, nonatomic) IBOutlet UILabel* currentValueLabel;
@end

@implementation TMWNotificationDetailsController

#pragma mark - Public API

#pragma mark NSObject

- (void)dealloc
{
    NSString* meaning = _notificationRule.condition.meaning;
    RelayrDevice* device = [_notificationRule.transmitter devicesWithInputMeaning:meaning].anyObject;
    [[device inputWithMeaning:meaning] unsubscribeTarget:self action:@selector(dataArrivedFromDevice:withInput:)];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _notificationRule = [TMWRule ruleForID:_notification.ruleID withinRulesArray:[TMWStore sharedInstance].rules];
    if (_notificationRule)
    {
        _ruleName.text = _notificationRule.name.uppercaseString;
        _ruleDescription.text = _notificationRule.thresholdDescription;
    }
    else
    {
        _ruleName.text = @"N/A";
        _ruleDescription.text = @"N/A";
    }
    
    _triggeredDate.text = [NSString stringWithFormat:@"%@ at %@", [TMWDateConverter dayOfDate:_notification.timestamp], [TMWDateConverter timeOfDate:_notification.timestamp]];
    
    NSNumber* value = [_notification convertServerValueWithMeaning:_notificationRule.condition.meaning];
    NSString* valueString = (value) ? [NSString stringWithFormat:@"%.1f", value.floatValue] : @"N/A";
    _triggeredValue.text = [NSString stringWithFormat:@"%@ %@", valueString, _notificationRule.condition.unit];
    
    __weak TMWNotificationDetailsController* weakSelf = self;
    [self subscribeToRule:_notificationRule withTarget:self action:@selector(dataArrivedFromDevice:withInput:) withErrorBlock:^(NSError* error) {
        TMWNotificationDetailsController* strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf.currentValueIndicator stopAnimating];
        strongSelf.currentValueIndicator.hidden = YES;
        
        strongSelf.currentValueLabel.text = TMWNotificationDetailsCntrll_SubscriptionError;
        strongSelf.currentValueLabel.hidden = NO;
    }];
}

#pragma mark - Private functionality

- (void)subscribeToRule:(TMWRule*)rule withTarget:(id)target action:(SEL)action withErrorBlock:(void (^)(NSError* error))errorBlock
{
    NSString* meaning = rule.condition.meaning;
    RelayrDevice* device = [rule.transmitter devicesWithInputMeaning:meaning].anyObject;
    RelayrInput* input = [device inputWithMeaning:meaning];
    if (!rule || !input) { if (errorBlock) { errorBlock(RelayrErrorMQTTSubscriptionFailed); } return; }
    
    [input subscribeWithTarget:target action:action error:errorBlock];
}

- (void)dataArrivedFromDevice:(RelayrDevice*)device withInput:(RelayrInput*)input
{
    if (!_currentValueIndicator.hidden)
    {
        [_currentValueIndicator stopAnimating];
        _currentValueIndicator.hidden = YES;
        _currentValueLabel.hidden = NO;
    }
    
    _currentValueLabel.text = ([input.value isKindOfClass:[NSNumber class]]) ?
        TMWNotificationDetails_CellValue(_notificationRule.type, [TMWRuleCondition convertServerValue:input.value withMeaning:_notificationRule.condition.meaning], _notificationRule.condition.unit) :
        TMWNotificationDetailsCntrll_SubscriptionUnknown;
}

@end
