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

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithMeaning:(NSString*)meaning
{
    if ([TMWRuleCondition isMeaningValid:meaning]) { return nil; }
    
    self = [super init];
    if (self)
    {
        _meaning = meaning;
        _operation = [TMWRuleCondition lessThanOperator];
        _value = [TMWRuleCondition defaultValueForMeaning:meaning];
    }
    return self;
}

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

- (NSString*)unit
{
    return [TMWRuleCondition unitForMeaning:_meaning];
}

- (FPRange)range
{
    return [TMWRuleCondition rangeForMeaning:_meaning];
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
    
    TMWRuleCondition* condition = object;
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

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    TMWRuleCondition* condition = [[TMWRuleCondition alloc] initWithMeaning:_meaning];
    condition.operation = _operation;
    condition.value = _value;
    return condition;
}

#pragma mark Class methods

+ (NSString*)lessThanOperator
{
    return @"<";
}

+ (NSString*)greaterThanOperator
{
    return @">";
}

+ (BOOL)isMeaningValid:(NSString*)meaning
{
    return (!meaning.length
            || ![meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]
            || ![meaning isEqualToString:[TMWRuleCondition meaningForHumidity]]
            || ![meaning isEqualToString:[TMWRuleCondition meaningForNoise]]
            || ![meaning isEqualToString:[TMWRuleCondition meaningForProximity]]
            || ![meaning isEqualToString:[TMWRuleCondition meaningForLight]]) ? NO : YES;
}

+ (NSString*)meaningForTemperature
{
    return @"temperature";
}

+ (NSString*)meaningForHumidity
{
    return @"humidity";
}

+ (NSString*)meaningForNoise
{
    return @"noise_level";
}

+ (NSString*)meaningForProximity
{
    return @"proximity";
}

+ (NSString*)meaningForLight
{
    return @"luminosity";
}

+ (FPRange)rangeForTemperature
{
    return FPRangeMake(-40.0, 140.0);
}

+ (FPRange)rangeForHumidity
{
    return FPRangeMake(0.0, 100.0);
}

+ (FPRange)rangeForNoise
{
    return FPRangeMake(0.0, 100.0);
}

+ (FPRange)rangeForProximity
{
    return FPRangeMake(0.0, 100.0);
}

+ (FPRange)rangeForLight
{
    return FPRangeMake(0.0, 100.0);
}

+ (id)defaultValueForMeaning:(NSString*)meaning
{
    id value;
    if (!meaning.length) { return value; }
    
    if ([meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) {
        value = [NSNumber numberWithFloat:28.0];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForHumidity]]) {
        FPRange const range = [TMWRuleCondition rangeForHumidity];
        value = [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForNoise]]) {
        FPRange const range = [TMWRuleCondition rangeForNoise];
        value = [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForProximity]]) {
        FPRange const range = [TMWRuleCondition rangeForProximity];
        value = [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForLight]]) {
        FPRange const range = [TMWRuleCondition rangeForLight];
        value = [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
    }
    
    return value;
}

+ (NSString*)unitForMeaning:(NSString*)meaning
{
    NSString* result = @"N/A";
    if (!meaning.length) { return result; }
    
    if ([meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) {
        result = @"°C";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForHumidity]]) {
        result = @"%%";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForNoise]]) {
        result = @"%%";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForProximity]]) {
        result = @"%%";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForLight]]) {
        result = @"%%";
    }
    
    return result;
}

+ (FPRange)rangeForMeaning:(NSString*)meaning
{
    if (!meaning.length) { return FPRangeZero; }
    
    return ([meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) ? [TMWRuleCondition rangeForTemperature] :
        ([meaning isEqualToString:[TMWRuleCondition meaningForHumidity]])       ? [TMWRuleCondition rangeForHumidity] :
        ([meaning isEqualToString:[TMWRuleCondition meaningForNoise]])          ? [TMWRuleCondition rangeForNoise] :
        ([meaning isEqualToString:[TMWRuleCondition meaningForProximity]])      ? [TMWRuleCondition rangeForProximity] :
        ([meaning isEqualToString:[TMWRuleCondition meaningForLight]])          ? [TMWRuleCondition rangeForLight] : FPRangeZero;
}

@end
