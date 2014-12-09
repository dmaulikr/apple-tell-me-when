#import <UIKit/UIKit.h> // Apple


@interface TMWNotificationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *notificationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *notificationDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *notificationTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *ruleDescriptionLabel;

@end
