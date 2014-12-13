@import Foundation;     // Apple

FOUNDATION_EXPORT NSString* const TMWRuleNotificationTypeAPNS;
FOUNDATION_EXPORT NSString* const TMWRuleNotificationTypeGCM;
FOUNDATION_EXPORT NSString* const TMWRuleNotificationTypeEmail;

/*!
 *  @abstract Type of the notification that a specific rule support.
 */
@interface TMWRuleNotification : NSObject <NSCoding>

- (instancetype)initWithDeviceToken:(NSData*)deviceToken;
- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary;

@property (readonly,nonatomic) NSString* type;
@property (strong,nonatomic) NSData* deviceToken;

@end
