#import "NSData+Hexadecimal.h"  // Header

@implementation NSData (Hexadecimal)

- (NSString*)hexadecimalString
{
    unsigned char const* dataBuffer = self.bytes;
    if (!dataBuffer) { return [NSString string]; }
    
    NSUInteger const dataLength = self.length;
    NSMutableString* hexString = [NSMutableString stringWithCapacity:dataLength*2];
    
    for (int i=0; i<dataLength; ++i)
    {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

@end
