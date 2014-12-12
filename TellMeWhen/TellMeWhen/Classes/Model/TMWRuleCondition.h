#import <Foundation/Foundation.h> // Apple


/*!
 *  @abstract Condition specify by a rule.
 */
@interface TMWRuleCondition : NSObject

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary;

@property (strong,nonatomic) NSString* meaning;
@property (strong,nonatomic) NSString* operation;
@property (strong,nonatomic) id value;

- (NSDictionary*)compressIntoJSONDictionary;

@end
