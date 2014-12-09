@import Foundation;     // Apple

@interface NSString (Hexadecimal)

/*!
 *  @abstract It returns an <code>NSData</code> object from an already hexadecimal encoded <code>NSString</code>.
 */
+ (NSData*)dataFromHexString:(NSString*)string;

@end
