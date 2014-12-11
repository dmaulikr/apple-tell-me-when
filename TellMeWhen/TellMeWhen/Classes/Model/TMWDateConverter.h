@import Foundation;

@interface TMWDateConverter : NSObject

+ (NSString*)dayOfDate:(NSDate*)date;

+ (NSString*)timeOfDate:(NSDate*)date;

+ (BOOL)isDateToday:(NSDate*)date;

+ (BOOL)isDateYesterday:(NSDate*)date;

@end
