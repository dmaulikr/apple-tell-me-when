@import Foundation;     // Apple

@interface NSData (Hexadecimal)

/*!
 *  @abstract It returns an hexadecimal string of an <code>NSData</code> object.
 *  @discussion If data is empty, an empty string is returned.
 */
- (NSString*)hexadecimalString;

@end
