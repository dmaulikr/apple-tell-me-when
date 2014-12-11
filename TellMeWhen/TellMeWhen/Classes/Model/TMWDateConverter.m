#import "TMWDateConverter.h"    // Header

#pragma mark Definitions

#define TMWDateConverter_DateNotAvailable   @"N/A"

@implementation TMWDateConverter

#pragma mark - Public API

+ (NSString*)dayOfDate:(NSDate*)date
{
    return  (!date) ? TMWDateConverter_DateNotAvailable             :
        ([TMWDateConverter isDateToday:date])       ? @"Today"      :
        ([TMWDateConverter isDateYesterday:date])   ? @"Yesterday"  :
        [[TMWDateConverter dayDateFormatter] stringFromDate:date];
}

+ (NSString*)timeOfDate:(NSDate*)date
{
    return  (!date) ? TMWDateConverter_DateNotAvailable : [[TMWDateConverter timeDateFormatter] stringFromDate:date];
}

+ (BOOL)isDateToday:(NSDate*)date
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate* today = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate* dateToCheck = [cal dateFromComponents:components];
    
    return ([today isEqualToDate:dateToCheck]);
}

+ (BOOL)isDateYesterday:(NSDate*)date
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate* yesterday = [cal dateByAddingComponents:components toDate:[NSDate date] options:kNilOptions];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:yesterday];
    yesterday = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate* dateToCheck = [cal dateFromComponents:components];
    
    return ([yesterday isEqualToDate:dateToCheck]);
}

#pragma mark - Private functionality

+ (NSDateFormatter*)dayDateFormatter
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = [NSCalendar currentCalendar];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [formatter setDateFormat:@"yyyy-MM-dd"];
    });
    return formatter;
}

+ (NSDateFormatter*)timeDateFormatter
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = [NSCalendar currentCalendar];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [formatter setDateFormat:@"HH:mm:ss"];
    });
    return formatter;
}

@end
