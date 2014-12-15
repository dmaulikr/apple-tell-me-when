#import "TMWRuleThresholdController.h"      // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleNamingController.h"         // TMW (ViewControllers/Rules)

@interface TMWRuleThresholdController () <TMWSegueUnwindingRules>
@property (strong, nonatomic) IBOutlet UIImageView* measurementImageView;
@property (strong, nonatomic) IBOutlet UILabel* transmitterNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* measurementLabel;
@property (strong, nonatomic) IBOutlet UIButton* lessThanButton;
- (IBAction)lessThanTapped:(UIButton*)sender;
@property (strong, nonatomic) IBOutlet UIButton* greaterThan;
- (IBAction)greaterThanTapped:(UIButton*)sender;
@property (strong, nonatomic) IBOutlet UILabel* conditionValueLabel;
@property (strong, nonatomic) IBOutlet UISlider* conditionValueSlider;
- (IBAction)conditionValueChanged:(UISlider*)sender;
@property (readonly,nonatomic) NSString* segueIdentifierForUnwind;
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
    _conditionValueLabel.text = [NSString stringWithFormat:@"%@ %@", rule.condition.value, rule.condition.unit];
    FPRange const sliderRange = rule.condition.range;
    _conditionValueSlider.minimumValue = sliderRange.min;
    _conditionValueSlider.maximumValue = sliderRange.max;
    id value = rule.condition.value;
    _conditionValueSlider.value = ([value isKindOfClass:[NSNumber class]]) ? ((NSNumber*)value).floatValue : 0.5*(fabsf(sliderRange.min) + fabsf(sliderRange.max));
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
    
}

- (IBAction)greaterThanTapped:(UIButton*)sender
{
    
}

- (IBAction)conditionValueChanged:(UISlider*)sender
{
    _conditionValueLabel.text = [NSString stringWithFormat:@"%@ %@", @(sender.value), (_tmpRule) ? _tmpRule.condition.unit : _rule.condition.unit];
}

#pragma mark Navigation functionality

- (NSString*)segueIdentifierForUnwind
{
    return (!_needsServerModification) ? TMWStoryboardIDs_UnwindFromRuleThreshToMeasur : TMWStoryboardIDs_UnwindFromRuleThreshToSum;
}

- (IBAction)unwindFromRuleName:(UIStoryboardSegue*)segue { }
@end
