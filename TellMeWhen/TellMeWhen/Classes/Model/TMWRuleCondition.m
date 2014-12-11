#import "TMWRuleCondition.h" // Header

#define TMWRule_Condition_Meaning   @"meaning"
#define TMWRule_Condition_Operation @"op"
#define TMWRule_Condition_Value     @"val"


@implementation TMWRuleCondition

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }

    self = [super init];
    if (self)
    {
        _meaning = jsonDictionary[TMWRule_Condition_Meaning];
        _operation = jsonDictionary[TMWRule_Condition_Operation];
        id value = jsonDictionary[TMWRule_Condition_Value];
        if ([value isKindOfClass:[NSNumber class]]) {
            _value = value;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // TODO: Handle non-numeric values
        }
    }
    return self;
}

- (NSDictionary*)compressIntoJSONDictionary
{
    if (!_meaning.length || !_operation.length || !_value) { return nil; }
    return @{
        TMWRule_Condition_Meaning   : _meaning,
        TMWRule_Condition_Operation : _operation,
        TMWRule_Condition_Value     : ([_value isKindOfClass:[NSNumber class]]) ? _value : [NSNull null]
    };
}

@end
