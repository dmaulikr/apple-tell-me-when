#import "TMWNotification.h" // Header

#define TMWNotification_UID @"_id"
#define TMWNotification_Revision @"_rev"
#define TMWNotification_RuleID @"rule_id"
#define TMWNotification_UserID @"user_id"
#define TMWNotification_Timestamp @"timestamp"
#define TMWNotification_Value @"val"

static NSString* const kCodingID = @"uid";
static NSString* const kCodingRevision = @"rev";
static NSString* const kCodingRuleID = @"rID";
static NSString* const kCodingUserID = @"uID";
static NSString* const kCodingTimestamp = @"ts";
static NSString* const kCodingValue = @"val";
static NSString* const kCodingName = @"nam";

@implementation TMWNotification

#pragma mark - Public API

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary {
    if (!jsonDictionary.count) {
        return nil;
    }
    self = [super init];
    if (self) {
        _uid = jsonDictionary[TMWNotification_UID];
        _revisionString = jsonDictionary[TMWNotification_Revision];
        _ruleID = jsonDictionary[TMWNotification_RuleID];
        _userID = jsonDictionary[TMWNotification_UserID];
        NSNumber *timestamp = jsonDictionary[TMWNotification_Timestamp];

        if (timestamp) {
            _timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000.0];
        }
        
        id value = jsonDictionary[TMWNotification_Value];
        if ([value isKindOfClass:[NSNumber class]]) {
            _value = value;
        } else {
            // TODO: Complete when more complex values are added
        }
    }
    return self;
}

// Legacy Methods
- (NSString *)description {
    return _name;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self)
    {
        _uid = [decoder decodeObjectForKey:kCodingID];
        _revisionString = [decoder decodeObjectForKey:kCodingRevision];
        _ruleID = [decoder decodeObjectForKey:kCodingRuleID];
        _userID = [decoder decodeObjectForKey:kCodingUserID];
        _timestamp = [decoder decodeObjectForKey:kCodingTimestamp];
        _value = [decoder decodeObjectForKey:kCodingValue];
        _name = [decoder decodeObjectForKey:kCodingName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_revisionString forKey:kCodingRevision];
    [coder encodeObject:_ruleID forKey:kCodingRuleID];
    [coder encodeObject:_userID forKey:kCodingUserID];
    [coder encodeObject:_timestamp forKey:kCodingTimestamp];
    [coder encodeObject:_value forKey:kCodingValue];
    [coder encodeObject:_name forKey:kCodingName];
}

@end
