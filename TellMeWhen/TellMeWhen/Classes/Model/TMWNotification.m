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

@implementation TMWNotification

#pragma mark - Public API

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }
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

- (NSString*)valueDescription
{
    return ([_value isKindOfClass:[NSNumber class]]) ? ((NSNumber*)_value).stringValue : @"N/A";
}

+ (void)synchronizeStoredNotifications:(NSMutableArray*)coreNotifs withNewlyArrivedNotifications:(NSArray*)serverNotifs
{
    if (!coreNotifs || !serverNotifs.count) { return; }
    
    for (TMWNotification* sNotif in serverNotifs)
    {
        BOOL addToCoreNotifications = YES;
        for (TMWNotification* cNotif in coreNotifs)
        {
            if ([sNotif.uid isEqualToString:cNotif.uid])
            {
                addToCoreNotifications = NO;
                cNotif.revisionString = sNotif.revisionString;
                cNotif.ruleID = sNotif.ruleID;
                cNotif.userID = sNotif.userID;
                cNotif.timestamp = sNotif.timestamp;
                cNotif.value = sNotif.value;
                break;
            }
        }
        if (addToCoreNotifications) { [coreNotifs addObject:sNotif]; }
    }
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
}

@end
