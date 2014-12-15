#import "TMWTableViewCell.h"    // TMW (Views)

@interface TMWRuleTransmitterCellView : TMWTableViewCell

@property (strong,nonatomic) IBOutlet UILabel* transmitterNameLabel;
@property (strong,nonatomic) NSString* transmitterID;

@end
