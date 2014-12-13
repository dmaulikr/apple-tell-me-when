#import "TMWRuleCondition.h" // Header

#pragma mark Definitions

#define TMWRule_Condition_Meaning   @"meaning"
#define TMWRule_Condition_Operation @"op"
#define TMWRule_Condition_Value     @"val"

static NSString* const kCodingMeaning   = @"mean";
static NSString* const kCodingOperation = @"op";
static NSString* const kCodingValue     = @"val";

@implementation TMWRuleCondition

#pragma mark - Public API

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }

    self = [super init];
    if (self)
    {
        _meaning = jsonDictionary[TMWRule_Condition_Meaning];
        _operation = jsonDictionary[TMWRule_Condition_Operation];
        _value = jsonDictionary[TMWRule_Condition_Value];   // TODO: Handle non-numeric values
    }
    return self;
}

- (NSDictionary*)compressIntoJSONDictionary
{
    if (!_meaning.length || !_operation.length || !_value) { return nil; }
    return @{
        TMWRule_Condition_Meaning   : _meaning,
        TMWRule_Condition_Operation : _operation,
        TMWRule_Condition_Value     : (_value) ? _value : [NSNull null]
    };
}

- (BOOL)isEqual:(id)object
{
    if (!object || ![object isKindOfClass:[TMWRuleCondition class]]) { return NO; }
    
    TMWRuleCondition* condition;
    return ([_meaning isEqualToString:condition.meaning] && [_operation isEqualToString:condition.operation] && _value==condition.value) ? YES : NO;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self)
    {
        _meaning = [decoder decodeObjectForKey:kCodingMeaning];
        _operation = [decoder decodeObjectForKey:kCodingOperation];
        _value = [decoder decodeObjectForKey:kCodingValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_meaning forKey:kCodingMeaning];
    [coder encodeObject:_operation forKey:kCodingOperation];
    [coder encodeObject:_value forKey:kCodingValue];
}

@end
