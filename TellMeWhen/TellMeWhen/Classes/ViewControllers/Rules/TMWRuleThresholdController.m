#import "TMWRuleThresholdController.h"      // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)
#import "TMWAPIService.h"                   // TMW (Model)
#import "TMWLogging.h"                      // TMW (Model)
#import <Relayr/Relayr.h>                   // Relayr.framework
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleNamingController.h"         // TMW (ViewControllers/Rules)
#import "TMWUIProperties.h"                 // TMW (Views)
#import "TMWButton.h"                       // TMW (Views)

#pragma mark - Definitions

#define TMWRuleThreshold_LessThanButtonText     @"<\nless than"
#define TMWRuleThreshold_GreaterThanButtonText  @">\ngreater than"

#define TMWRuleThreshold_CellValue(type, num, unit) [NSString stringWithFormat:@"%@ = %.1f %@", type, ((NSNumber*)num).floatValue, unit]
#define TMWRuleThreshold_CellSubscriptionError      @"Error subscripbing to MQTT channel"
#define TMWRuleThreshold_CellSubscriptionUnknown    @"N/A"

#define TMWRuleThreshold_DoneButtonText_Done    @"done"
#define TMWRuleThreshold_DoneButtonText_Next    @"next"

@interface TMWRuleThresholdController () <TMWSegueUnwindingRules>
@property (strong, nonatomic) IBOutlet UIImageView* measurementImageView;
@property (strong, nonatomic) IBOutlet UILabel* transmitterNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* measurementLabel;

@property (strong, nonatomic) IBOutlet UIButton* lessThanButton;
- (IBAction)lessThanTapped:(UIButton*)sender;
@property (strong, nonatomic) IBOutlet UIButton* greaterThanButton;
- (IBAction)greaterThanTapped:(UIButton*)sender;

@property (strong, nonatomic) IBOutlet UILabel* conditionValueLabel;
@property (strong, nonatomic) IBOutlet UISlider* conditionValueSlider;
- (IBAction)conditionValueChanged:(UISlider*)sender;

@property (strong, nonatomic) IBOutlet UILabel* currentValueLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* currentIndicator;

@property (strong, nonatomic) IBOutlet TMWButton* doneButton;
- (IBAction)buttonTapped:(TMWButton*)sender;
@end

@implementation TMWRuleThresholdController

#pragma mark - Public API

#pragma mark NSObject

- (void)dealloc
{
    TMWRule* rule = ((_tmpRule) ? _tmpRule : _rule);
    NSString* meaning = rule.condition.meaning;
    
    RelayrDevice* device = [rule.transmitter devicesWithInputMeaning:meaning].anyObject;
    [[device inputWithMeaning:meaning] unsubscribeTarget:self action:@selector(dataArrivedFromDevice:withInput:)];
}

#pragma mark UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesThreshToNaming])
    {
        [RelayrCloud logMessage:TMWLogging_Creation_Name onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
        TMWRule* ruleCopied = _rule.copy;
        ruleCopied.condition.operation = (_lessThanButton.selected) ? [TMWRuleCondition lessThanOperator] : [TMWRuleCondition greaterThanOperator];
        ruleCopied.condition.valueConverted = [NSNumber numberWithFloat:_conditionValueSlider.value];
        ((TMWRuleNamingController*)segue.destinationViewController).rule = ruleCopied;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TMWRule* dataRule = (_tmpRule) ? _tmpRule : _rule;
    _measurementImageView.image = dataRule.icon;
    _transmitterNameLabel.text = dataRule.transmitter.name.uppercaseString;
    _measurementLabel.text = dataRule.type;
    
    BOOL const lessThanSelected = ([dataRule.condition.operation isEqualToString:[TMWRuleCondition lessThanOperator]]) ? YES : NO;
    _lessThanButton.selected = lessThanSelected;
    _greaterThanButton.selected = !lessThanSelected;
    
    [_lessThanButton setAttributedTitle:[self operatorsText:TMWRuleThreshold_LessThanButtonText] forState:UIControlStateNormal];
    [_greaterThanButton setAttributedTitle:[self operatorsText:TMWRuleThreshold_GreaterThanButtonText] forState:UIControlStateNormal];
    
    FPRange const sliderRange = dataRule.condition.range;
    _conditionValueSlider.minimumValue = sliderRange.min;
    _conditionValueSlider.maximumValue = sliderRange.max;
    
    float const value = dataRule.condition.valueConverted.floatValue;
    _conditionValueLabel.text = [NSString stringWithFormat:@"%.1f %@", value, dataRule.condition.unit];
    _conditionValueSlider.value = value;
    
    NSString* buttonText = (!_needsServerModification) ? TMWRuleThreshold_DoneButtonText_Next : TMWRuleThreshold_DoneButtonText_Done;
    [_doneButton setTitle:buttonText forState:UIControlStateNormal];
    
    __weak TMWRuleThresholdController* weakSelf = self;
    [self subscribeToRule:dataRule withTarget:self action:@selector(dataArrivedFromDevice:withInput:) withErrorBlock:^(NSError *error) {
        TMWRuleThresholdController* strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf.currentIndicator stopAnimating];
        strongSelf.currentIndicator.hidden = YES;
        
        strongSelf.currentValueLabel.text = TMWRuleThreshold_CellSubscriptionError;
        strongSelf.currentValueLabel.hidden = NO;
    }];
}

#pragma mark - Private functionality

- (void)subscribeToRule:(TMWRule*)rule withTarget:(id)target action:(SEL)action withErrorBlock:(void (^)(NSError* error))errorBlock
{
    NSString* meaning = rule.condition.meaning;
    RelayrDevice* device = [rule.transmitter devicesWithInputMeaning:meaning].anyObject;
    RelayrInput* input = [device inputWithMeaning:meaning];
    if (!input) { if (errorBlock) { errorBlock(RelayrErrorMQTTSubscriptionFailed); return; } }
    
    [input subscribeWithTarget:self action:@selector(dataArrivedFromDevice:withInput:) error:errorBlock];
}

- (void)dataArrivedFromDevice:(RelayrDevice*)device withInput:(RelayrInput*)input
{
    if (!_currentIndicator.hidden)
    {
        [_currentIndicator stopAnimating];
        _currentIndicator.hidden = YES;
        _currentValueLabel.hidden = NO;
    }
    
    TMWRule* rule = ((_tmpRule) ? _tmpRule : _rule);
    _currentValueLabel.text = ([input.value isKindOfClass:[NSNumber class]]) ?
        TMWRuleThreshold_CellValue(rule.type, [TMWRuleCondition convertServerValue:input.value withMeaning:rule.condition.meaning], rule.condition.unit) :
        TMWRuleThreshold_CellSubscriptionUnknown;
}

- (IBAction)backButtonTapped:(id)sender
{
    if (_needsServerModification) { [RelayrCloud logMessage:TMWLogging_Edit_Cancelled onBehalfOfUser:[TMWStore sharedInstance].relayrUser]; }
    [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleThreshold sender:self];
}

- (IBAction)lessThanTapped:(UIButton*)sender
{
    _lessThanButton.selected = YES;
    _greaterThanButton.selected = NO;
}

- (IBAction)greaterThanTapped:(UIButton*)sender
{
    _lessThanButton.selected = NO;
    _greaterThanButton.selected = YES;
}

- (IBAction)conditionValueChanged:(UISlider*)sender
{
    _conditionValueLabel.text = [NSString stringWithFormat:@"%.1f %@", sender.value, (_tmpRule) ? _tmpRule.condition.unit : _rule.condition.unit];
}

- (NSAttributedString*)operatorsText:(NSString*)text
{
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineSpacing = 0.0;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.paragraphSpacing = 0.0;
    style.paragraphSpacingBefore = 0.0;
    
    NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName             : [UIFont fontWithName:TMWFont_NewJuneBook size:15.0],
        NSForegroundColorAttributeName  : [UIColor whiteColor],
        NSParagraphStyleAttributeName   : style
    }];
    
    [str addAttributes:@{ NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBold size:65.0] } range:NSMakeRange(0, 1)];
    return [[NSAttributedString alloc] initWithAttributedString:str];
}

#pragma mark Navigation functionality

- (IBAction)buttonTapped:(TMWButton*)sender
{
    if (!_needsServerModification) {  return [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesThreshToNaming sender:self]; }
    
    if (_tmpRule) { [_rule setWith:_tmpRule]; _tmpRule = nil; }
    
    NSString* previousOperation = _rule.condition.operation;
    NSNumber* previousValueConverted = _rule.condition.valueConverted;
    _rule.condition.operation = (_lessThanButton.selected) ? [TMWRuleCondition lessThanOperator] : [TMWRuleCondition greaterThanOperator];
    _rule.condition.valueConverted = [NSNumber numberWithFloat:_conditionValueSlider.value];
    
    __weak TMWRuleThresholdController* weakSelf = self;
    [TMWAPIService setRule:_rule completion:^(NSError* error) {
        if (error)
        {
            weakSelf.rule.condition.operation = previousOperation;
            weakSelf.rule.condition.valueConverted = previousValueConverted;
        }
        
        [RelayrCloud logMessage:TMWLogging_Edit_Finished onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
        [weakSelf performSegueWithIdentifier:TWMStoryboardIDs_UnwindFromRuleThresholdPacked sender:weakSelf];
    }];
}

- (IBAction)unwindFromRuleName:(UIStoryboardSegue*)segue
{
    [RelayrCloud logMessage:TMWLogging_Creation_Threshold onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
}

@end
