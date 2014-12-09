@import Foundation; // Apple


@interface TMWNotification : NSObject <NSCoding>

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@property (strong,nonatomic) NSString *uid;
@property (strong,nonatomic) NSString *revisionString;
@property (strong,nonatomic) NSString *ruleID;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSDate *timestamp;
@property (strong,nonatomic) id value;

// Legacy Properties
@property (strong, nonatomic) NSString *name;

@end
