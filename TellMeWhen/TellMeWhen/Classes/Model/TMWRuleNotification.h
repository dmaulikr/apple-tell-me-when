@import Foundation;     // Apple

FOUNDATION_EXPORT NSString* const TMWRuleNotificationTypeAPNS;
FOUNDATION_EXPORT NSString* const TMWRuleNotificationTypeGCM;
FOUNDATION_EXPORT NSString* const TMWRuleNotificationTypeEmail;

/*!
 *  @abstract Type of the notification that a specific rule support.
 */
@interface TMWRuleNotification : NSObject <NSCoding,NSCopying>

- (instancetype)initWithDeviceToken:(NSData*)deviceToken;
- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary;

@property (strong,nonatomic) NSString* type;
@property (strong,nonatomic) NSData* deviceToken;

@end
