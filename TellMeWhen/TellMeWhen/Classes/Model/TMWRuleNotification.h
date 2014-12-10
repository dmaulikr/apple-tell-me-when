#import <Foundation/Foundation.h>

/*!
 *  @abstract Type of the notification that a specific rule support.
 */
@interface TMWRuleNotification : NSObject

- (instancetype)initWithDeviceToken:(NSData*)deviceToken;
- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary;

@property (readonly,nonatomic) NSString* type;
@property (strong,nonatomic) NSData* deviceToken;

@end
