@import UIKit;                  // Apple
@class TMWNotification;         // TMW (Model)
#import "TMWTableViewCell.h"    // TMW (Views)

@interface TMWNotificationsCellView : TMWTableViewCell

@property (strong,nonatomic) TMWNotification* notification;

@end
