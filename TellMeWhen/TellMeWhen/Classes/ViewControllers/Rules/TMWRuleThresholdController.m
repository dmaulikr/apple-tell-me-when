#import "TMWRuleThresholdController.h"      // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleNamingController.h"         // TMW (ViewControllers/Rules)
#import "TMWUIProperties.h"                 // TMW (Views)
#import "TMWButton.h"                       // TMW (Views)

#pragma mark - Definitions

#define TMWRuleThreshold_LessThanButtonText     @"<\nless than"
#define TMWRuleThreshold_GreaterThanButtonText  @">\ngreater than"

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
@property (strong, nonatomic) IBOutlet TMWButton* doneButton;
@property (readonly,nonatomic) NSString* segueIdentifierForUnwind;
- (IBAction)buttonTapped:(TMWButton*)sender;
@end

@implementation TMWRuleThresholdController

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TMWRule* rule = (_tmpRule) ? _tmpRule : _rule;
    _measurementImageView.image = rule.icon;
    _transmitterNameLabel.text = rule.transmitter.name.uppercaseString;
    _measurementLabel.text = rule.type;
    
    if ([rule.condition.operation isEqualToString:[TMWRuleCondition lessThanOperator]])
    {
        _lessThanButton.selected = YES;
        _greaterThanButton.selected = NO;
    }
    else
    {
        _lessThanButton.selected = NO;
        _greaterThanButton.selected = YES;
    }
    
    NSAttributedString* str = [self operatorsText:TMWRuleThreshold_LessThanButtonText];
    [_lessThanButton setAttributedTitle:str forState:UIControlStateNormal];
    str = [self operatorsText:TMWRuleThreshold_GreaterThanButtonText];
    [_greaterThanButton setAttributedTitle:str forState:UIControlStateNormal];
    
    FPRange const sliderRange = rule.condition.range;
    _conditionValueSlider.minimumValue = sliderRange.min;
    _conditionValueSlider.maximumValue = sliderRange.max;
    
    NSNumber* value = ([rule.condition.value isKindOfClass:[NSNumber class]]) ? rule.condition.value : nil;
    if (value && FPRangeContainsValue([TMWRuleCondition rangeForMeaning:rule.condition.meaning], value.floatValue))
    {
        _conditionValueLabel.text = [NSString stringWithFormat:@"%.1f %@", value.floatValue, rule.condition.unit];
        _conditionValueSlider.value = value.floatValue;
    }
    else
    {
        float const floatValue = 0.5*(fabsf(sliderRange.min) + fabsf(sliderRange.max));
        _conditionValueLabel.text = [NSString stringWithFormat:@"%.1f %@", floatValue, rule.condition.unit];
        _conditionValueSlider.value = floatValue;
    }
    
    NSString* buttonText = (!_needsServerModification) ? TMWRuleThreshold_DoneButtonText_Next : TMWRuleThreshold_DoneButtonText_Done;
    [_doneButton setTitle:buttonText forState:UIControlStateNormal];
}

#pragma mark UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesThreshToNaming])
    {
        ((TMWRuleNamingController*)segue.destinationViewController).rule = _rule;
    }
}

#pragma mark - Private functionality

- (IBAction)backButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
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

- (NSString*)segueIdentifierForUnwind
{
    return (!_needsServerModification || _tmpRule) ? TMWStoryboardIDs_UnwindFromRuleThreshToMeasur : TMWStoryboardIDs_UnwindFromRuleThreshToSum;
}

- (IBAction)buttonTapped:(TMWButton*)sender
{
    if (_tmpRule)
    {
        [_rule setWith:_tmpRule];
        _tmpRule = nil;
    }
    _rule.condition.operation = (_lessThanButton.selected) ? [TMWRuleCondition lessThanOperator] : [TMWRuleCondition greaterThanOperator];
    _rule.condition.value = [NSNumber numberWithFloat:_conditionValueSlider.value];
    return (!_needsServerModification) ?
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesThreshToNaming sender:self] :
        [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
}

- (IBAction)unwindFromRuleName:(UIStoryboardSegue*)segue { }
@end
