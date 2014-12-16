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
        self.valueConverted = [TMWRuleCondition defaultValueForMeaning:meaning];
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

- (NSNumber*)valueConverted
{
    return [TMWRuleCondition convertServerValue:_value withMeaning:_meaning];
}

- (void)setValueConverted:(NSNumber*)valueConverted
{
    if (!valueConverted) { return; }
    
    FPRange serverRange;
    float serverValue;
    
    if ([_meaning isEqualToString:[TMWRuleCondition meaningForTemperature]])
    {
        serverRange = [TMWRuleCondition rangeServerForTemperature];
        serverValue = valueConverted.floatValue;
    }
    else if ([_meaning isEqualToString:[TMWRuleCondition meaningForHumidity]])
    {
        serverRange = [TMWRuleCondition rangeServerForHumidity];
        serverValue = (serverRange.max / [TMWRuleCondition rangeForHumidity].max) * valueConverted.floatValue;
    }
    else if ([_meaning isEqualToString:[TMWRuleCondition meaningForNoise]])
    {
        serverRange = [TMWRuleCondition rangeServerForNoise];
        serverValue = (serverRange.max / [TMWRuleCondition rangeForNoise].max) * valueConverted.floatValue;
    }
    else if ([_meaning isEqualToString:[TMWRuleCondition meaningForProximity]])
    {
        serverRange = [TMWRuleCondition rangeServerForProximity];
        serverValue = (serverRange.max / [TMWRuleCondition rangeForProximity].max) * valueConverted.floatValue;
    } else if ([_meaning isEqualToString:[TMWRuleCondition meaningForLight]])
    {
        serverRange = [TMWRuleCondition rangeServerForLight];
        serverValue = (serverRange.max / [TMWRuleCondition rangeForLight].max) * valueConverted.floatValue;
    } else { return; }
    
    if (serverValue < serverRange.min) { serverValue = serverRange.min; }
    else if (serverValue > serverRange.max) { serverValue = serverRange.max; }
    
    _value = [NSNumber numberWithFloat:serverValue];
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

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %@ %@", _meaning, _operation, _value];
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

+ (FPRange)rangeServerForTemperature
{
    return FPRangeMake(-40.0, 140.0);
}

+ (FPRange)rangeServerForHumidity
{
    return FPRangeMake(0.0, 100.0);
}

+ (FPRange)rangeServerForNoise
{
    return FPRangeMake(0.0, 1023.0);
}

+ (FPRange)rangeServerForProximity
{
    return FPRangeMake(0.0, 2047.0);
}

+ (FPRange)rangeServerForLight
{
    return FPRangeMake(0.0, 4096.0);
}


+ (NSNumber*)defaultValueForTemperature
{
    return [NSNumber numberWithFloat:28.0];
}

+ (NSNumber*)defaultValueForHumitdity
{
    FPRange const range = [TMWRuleCondition rangeForHumidity];
    return [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
}

+ (NSNumber*)defaultValueForNoise
{
    FPRange const range = [TMWRuleCondition rangeForNoise];
    return [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
}

+ (NSNumber*)defaultValueForProximity
{
    FPRange const range = [TMWRuleCondition rangeForProximity];
    return [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
}

+ (NSNumber*)defaultValueForLight
{
    FPRange const range = [TMWRuleCondition rangeForLight];
    return [NSNumber numberWithFloat:range.min + 0.5*(fabsf(range.min) + fabsf(range.max))];
}

+ (id)defaultValueForMeaning:(NSString*)meaning
{
    if (!meaning.length) {
        return nil;
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) {
        return [TMWRuleCondition defaultValueForTemperature];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForHumidity]]) {
        return [TMWRuleCondition defaultValueForHumitdity];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForNoise]]) {
        return [TMWRuleCondition defaultValueForNoise];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForProximity]]) {
        return [TMWRuleCondition defaultValueForProximity];
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForLight]]) {
        return [TMWRuleCondition defaultValueForLight];
    } else {
        return nil;
    }
}

+ (NSString*)unitForMeaning:(NSString*)meaning
{
    NSString* result = @"N/A";
    if (!meaning.length) { return result; }
    
    if ([meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) {
        result = @"°C";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForHumidity]]) {
        result = @"%";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForNoise]]) {
        result = @"%";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForProximity]]) {
        result = @"%";
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForLight]]) {
        result = @"%";
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

+ (NSNumber*)convertServerValue:(id)serverValue withMeaning:(NSString*)meaning
{
    if (!serverValue || !meaning || ![serverValue isKindOfClass:[NSNumber class]]) { return nil; }
    
    NSNumber* value = serverValue;
    
    FPRange range;
    float convertedValue;
    
    if ([meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) {
        range = [TMWRuleCondition rangeForTemperature];
        convertedValue = value.floatValue;
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForHumidity]]) {
        range = [TMWRuleCondition rangeForHumidity];
        convertedValue = value.floatValue;
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForNoise]]) {
        range = [TMWRuleCondition rangeForNoise];
        convertedValue = (range.max / [TMWRuleCondition rangeServerForNoise].max) * value.floatValue;
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForProximity]]) {
        range = [TMWRuleCondition rangeForProximity];
        convertedValue = (range.max / [TMWRuleCondition rangeServerForProximity].max) * value.floatValue;
    } else if ([meaning isEqualToString:[TMWRuleCondition meaningForLight]]) {
        range = [TMWRuleCondition rangeForLight];
        convertedValue = (range.max / [TMWRuleCondition rangeServerForLight].max) * value.floatValue;
    } else {
        return nil;
    }
    
    if (convertedValue < range.min) { convertedValue = range.min; }
    else if (convertedValue > range.max) { convertedValue = range.max; }
    
    return [NSNumber numberWithFloat:convertedValue];
}

@end
