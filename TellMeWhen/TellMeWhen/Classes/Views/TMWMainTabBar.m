#import "TMWMainTabBar.h"       // Header
#import "TMWUIProperties.h"     // TMW (Utilities)

#pragma mark Definitions

#define TMWMainTabBar_GradientColor0    TMWColorConverter(0xF96B17)
#define TMWMainTabBar_GradientColor1    TMWColorConverter(0xFF295C)
#define TMWMainTabBar_Font              TMWFont_NewJuneBook
#define TMWMainTabBar_FontSize          14.0

#pragma mark Private prototypes

static NSArray* createColors(void);

@interface TMWMainTabBar () <UITabBarDelegate>
@end

@implementation TMWMainTabBar
{
    CAGradientLayer* _gradientLayer;
}

#pragma mark - Public API

- (void)awakeFromNib
{
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    _gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    _gradientLayer.colors = createColors();
    [self.layer insertSublayer:_gradientLayer atIndex:0];
    
    NSDictionary* textProperties = @{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont fontWithName:TMWMainTabBar_Font size:TMWMainTabBar_FontSize]
    };
    [[UITabBarItem appearance] setTitleTextAttributes:textProperties forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize const size = self.bounds.size;
    _gradientLayer.bounds = CGRectMake(0.0, 0.0, 0.5*size.width, size.height);
    
    CGFloat index = [self.items indexOfObject:self.selectedItem];
    _gradientLayer.position = CGPointMake( (0.25 + index*0.5)*size.width, 0.5*size.height );
}

- (void)setSelectedItem:(UITabBarItem*)selectedItem
{
    [super setSelectedItem:selectedItem];
    [self setNeedsLayout];
}

#pragma mark - Private functionality

static NSArray* createColors(void)
{
    CGFloat const colorMembers0[] = TMWMainTabBar_GradientColor0;
    CGFloat const colorMembers1[] = TMWMainTabBar_GradientColor1;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color0 = CGColorCreate(colorSpace, colorMembers0);
    CGColorRef color1 = CGColorCreate(colorSpace, colorMembers1);
    CGColorSpaceRelease(colorSpace);
    
    return @[(__bridge_transfer id)color0, (__bridge_transfer id)color1];
}

@end
