#import <UIKit/UIKit.h> // Apple

#import "TMWRule.h"


@interface TMWThresholdDetailsViewController : UIViewController

@property (assign, nonatomic, getter=isEditingRule) BOOL editingRule;
@property (assign, nonatomic, getter=isEditingMeasurement) BOOL editingMeasurement;
@property (strong, nonatomic) TMWRule *rule;

@end
