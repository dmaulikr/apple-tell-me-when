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

@property (nonatomic) NSNumber* valueConverted;
@property (readonly,nonatomic) NSString* unit;
@property (nonatomic) FPRange range;

- (NSDictionary*)compressIntoJSONDictionary;

+ (NSString*)lessThanOperator;
+ (NSString*)greaterThanOperator;
+ (NSString*)defaultOperationForMeaning:(NSString*)meaning;

+ (BOOL)isMeaningValid:(NSString*)meaning;
+ (NSString*)meaningForTemperature;
+ (NSString*)meaningForHumidity;
+ (NSString*)meaningForNoise;
+ (NSString*)meaningForProximity;
+ (NSString*)meaningForLight;

// For converted values
+ (FPRange)rangeForTemperature;
+ (FPRange)rangeForHumidity;
+ (FPRange)rangeForNoise;
+ (FPRange)rangeForProximity;
+ (FPRange)rangeForLight;
// For server values
+ (FPRange)rangeServerForTemperature;
+ (FPRange)rangeServerForHumidity;
+ (FPRange)rangeServerForNoise;
+ (FPRange)rangeServerForProximity;
+ (FPRange)rangeServerForLight;
// Depending on meaning
+ (FPRange)rangeForMeaning:(NSString*)meaning;
+ (NSNumber*)convertServerValue:(id)serverValue withMeaning:(NSString*)meaning;

+ (NSNumber*)defaultValueForTemperature;
+ (NSNumber*)defaultValueForHumitdity;
+ (NSNumber*)defaultValueForNoise;
+ (NSNumber*)defaultValueForProximity;
+ (NSNumber*)defaultValueForLight;
+ (id)defaultValueForMeaning:(NSString*)meaning;

+ (NSString*)unitForMeaning:(NSString*)meaning;

@end
