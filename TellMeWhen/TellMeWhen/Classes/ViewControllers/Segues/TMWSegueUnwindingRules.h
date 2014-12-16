@import UIKit;  // Apple

@protocol TMWSegueUnwindingRules <NSObject>

@optional
- (IBAction)unwindFromRuleTransmitters:(UIStoryboardSegue*)segue;

@optional
- (IBAction)unwindFromRuleMeasurements:(UIStoryboardSegue*)segue;

@optional
- (IBAction)unwindFromRuleThreshold:(UIStoryboardSegue*)segue;

@optional
- (IBAction)unwindFromRuleThresholdPacked:(UIStoryboardSegue*)segue;

@optional
- (IBAction)unwindFromRuleName:(UIStoryboardSegue*)segue;

@optional
- (IBAction)unwindFromRuleNameToList:(UIStoryboardSegue*)segue;

@optional
- (IBAction)unwindFromRuleSummary:(UIStoryboardSegue*)segue;

@end
