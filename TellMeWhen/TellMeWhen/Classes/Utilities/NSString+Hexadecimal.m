#import "NSString+Hexadecimal.h"    // Header

@implementation NSString (Hexadecimal)

+ (NSData*)dataFromHexString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableData* result = [[NSMutableData alloc] init];
    char byte_chars[3] = {'\0','\0','\0'};
    
    NSUInteger const length = string.length/2;
    for (NSUInteger i=0; i<length; ++i)
    {
        NSUInteger const iterator = i*2;
        byte_chars[0] = [string characterAtIndex:iterator];
        byte_chars[1] = [string characterAtIndex:iterator+1];
        unsigned char const whole_byte = strtol(byte_chars, NULL, 16);
        [result appendBytes:&whole_byte length:1];
    }
    return [NSData dataWithData:result];
}

@end
