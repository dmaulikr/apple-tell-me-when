#import "UIColor+LightAndDark.h"    // Header

@implementation UIColor (LightAndDark)

- (UIColor*)lighterColor
{
    CGFloat h, s, b, a;
    return ([self getHue:&h saturation:&s brightness:&b alpha:&a]) ?
        [UIColor colorWithHue:h saturation:s brightness:MIN(b * 1.3, 1.0) alpha:a] : nil;
}

- (UIColor*)darkerColor
{
    CGFloat h, s, b, a;
    return ([self getHue:&h saturation:&s brightness:&b alpha:&a]) ?
        [UIColor colorWithHue:h saturation:s brightness:b * 0.75 alpha:a] : nil;
}

@end
