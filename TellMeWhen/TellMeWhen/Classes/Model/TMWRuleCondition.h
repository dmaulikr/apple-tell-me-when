#import <Foundation/Foundation.h> // Apple

typedef struct FPRange {
    float min;
    float max;
} FPRange;

#define FPRangeMake(min,max)    ((struct FPRange){min,max})
#define FPRangeZero             ((struct FPRange){0.0,0.0})
#define FPRangeContainsValue(range,val)     ((val >= range.min) && (val<= range.max))

/*!
 *  @abstract Condition specify by a rule.
 */
@interface TMWRuleCondition : NSObject <NSCoding,NSCopying>

- (instancetype)initWithMeaning:(NSString*)meaning;
- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary;

@property (strong,nonatomic) NSString* meaning;
@property (strong,nonatomic) NSString* operation;
@property (strong,nonatomic) id value;

@property (readonly,nonatomic) NSString* unit;
@property (nonatomic) FPRange range;

- (NSDictionary*)compressIntoJSONDictionary;

+ (NSString*)lessThanOperator;
+ (NSString*)greaterThanOperator;

+ (BOOL)isMeaningValid:(NSString*)meaning;
+ (NSString*)meaningForTemperature;
+ (NSString*)meaningForHumidity;
+ (NSString*)meaningForNoise;
+ (NSString*)meaningForProximity;
+ (NSString*)meaningForLight;

+ (FPRange)rangeForTemperature;
+ (FPRange)rangeForHumidity;
+ (FPRange)rangeForNoise;
+ (FPRange)rangeForProximity;
+ (FPRange)rangeForLight;

+ (id)defaultValueForMeaning:(NSString*)meaning;
+ (NSString*)unitForMeaning:(NSString*)meaning;
+ (FPRange)rangeForMeaning:(NSString*)meaning;

@end
