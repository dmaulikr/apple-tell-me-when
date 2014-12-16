#import "TMWNotification.h"     // Header
#import "TMWRuleCondition.h"    // TMW (Model)

#define TMWNotification_UID         @"_id"
#define TMWNotification_Revision    @"_rev"
#define TMWNotification_RuleID      @"rule_id"
#define TMWNotification_RuleRev     @"rule_rev"
#define TMWNotification_UserID      @"user_id"
#define TMWNotification_Timestamp   @"timestamp"
#define TMWNotification_Value       @"val"

static NSString* const kCodingID        = @"uid";
static NSString* const kCodingRevision  = @"rev";
static NSString* const kCodingRuleID    = @"rID";
static NSString* const kCodingRuleRev   = @"rRev";
static NSString* const kCodingUserID    = @"uID";
static NSString* const kCodingTimestamp = @"ts";
static NSString* const kCodingValue     = @"val";

@implementation TMWNotification

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }
    self = [super init];
    if (self) {
        _uid = jsonDictionary[TMWNotification_UID];
        _revisionString = jsonDictionary[TMWNotification_Revision];
        _ruleID = jsonDictionary[TMWNotification_RuleID];
        _ruleRevision = jsonDictionary[TMWNotification_RuleRev];
        _userID = jsonDictionary[TMWNotification_UserID];
        
        NSNumber* timestamp = jsonDictionary[TMWNotification_Timestamp];
        if (timestamp) { _timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000.0]; }
        
        _value = jsonDictionary[TMWNotification_Value]; // TODO: Complete when more complex values are added
    }
    return self;
}

- (NSNumber*)convertServerValueWithMeaning:(NSString*)meaning
{
    return [TMWRuleCondition convertServerValue:_value withMeaning:meaning];
}

+ (BOOL)synchronizeStoredNotifications:(NSMutableArray*)coreNotifs withNewlyArrivedNotifications:(NSArray*)serverNotifs resultingInCellsIndexPathsToAdd:(NSArray *__autoreleasing *)addingCellIndexPaths
{
    NSUInteger const numServerNotifs = serverNotifs.count;
    if (!numServerNotifs)
    {
        *addingCellIndexPaths = nil;
        return NO;
    }
    
    NSUInteger const numCoreNotifs = coreNotifs.count;
    NSUInteger const end = coreNotifs.count + numServerNotifs;
    
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:numServerNotifs];
    for (NSUInteger i=numCoreNotifs; i<end; ++i)
    {
        [result addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [coreNotifs addObjectsFromArray:serverNotifs];
    *addingCellIndexPaths = result.copy;
    return YES;
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

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"\n{\n\tID: %@\n\tRevision: %@\n\tRuleID: %@\n\tUserID: %@\n\tTimestamp: %@\n\tValue: %@\n}\n", _uid, _revisionString, _ruleID, _userID, _timestamp, _value];
}

@end
