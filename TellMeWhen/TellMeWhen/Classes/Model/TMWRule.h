#import <Foundation/Foundation.h> // Apple

#import <Relayr/Relayr.h> // Relayr

@class TMWRuleCondition;


/*!
 *  @abstract A rule is a condition to be met by a stream of data (usually MQTT).
 */
@interface TMWRule : NSObject

+ (TMWRule *)ruleForID:(NSString *)ruleID withinRulesArray:(NSArray *)rules;

- (instancetype)initWithUserID:(NSString *)userID;
- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;
- (NSDictionary *)compressIntoJSONDictionary;
- (NSArray*)setupNotificationsWithDeviceToken:(NSData*)deviceToken;

@property (strong,nonatomic) NSString *uid;
@property (strong,nonatomic) NSString *revisionString;
@property (readonly, nonatomic) NSString *userID; // Why is this readonly?
@property (strong, nonatomic) NSString *transmitterID;
@property (strong, nonatomic) NSString *deviceID;
@property (nonatomic) BOOL active; // FIXME: Use idiomatic objective c declaration of a boolean: @property (assign, nonatomic, getter=isActive) BOOL active;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) TMWRuleCondition *condition;
@property (strong, nonatomic) NSArray *notifications;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) UIImage *typeImage;
@property (strong, nonatomic) NSString *thresholdDescription;
@property (strong, nonatomic) RelayrTransmitter *transmitter;


@end
