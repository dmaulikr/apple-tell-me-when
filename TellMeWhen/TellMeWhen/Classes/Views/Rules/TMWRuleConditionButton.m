#import "TMWRuleConditionButton.h"  // Header
#import "TMWUIProperties.h"         // TMW (Utilities)

#define TMWRuleConditionButton_GradientColor0    TMWColorConverter(0xF96B17)
#define TMWRuleConditionButton_GradientColor1    TMWColorConverter(0xFF295C)

#pragma mark Private prototypes

static NSArray* createColors(void);

@implementation TMWRuleConditionButton
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
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize const size = self.bounds.size;
    _gradientLayer.bounds = CGRectMake(0.0, 0.0, size.width, size.height);
    _gradientLayer.position = CGPointMake(0.5*size.width, 0.5*size.height);
}

- (void)setHighlighted:(BOOL)highlighted
{
    BOOL const previousState = self.highlighted;
    [super setHighlighted:highlighted];
    if (previousState == highlighted) { return; }
    
    if (!highlighted)
    {
        if (!self.selected && _gradientLayer.superlayer) { [_gradientLayer removeFromSuperlayer]; }
    }
    else
    {
        if (!_gradientLayer.superlayer)
        {
            [self.layer insertSublayer:_gradientLayer atIndex:0];
            [self.layer setNeedsLayout];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    BOOL const previousState = self.selected;
    [super setSelected:selected];
    if (previousState == selected) { return; }
    
    if (!selected)
    {
        if (_gradientLayer.superlayer) { [_gradientLayer removeFromSuperlayer]; }
    }
    else
    {
        if (!_gradientLayer.superlayer)
        {
            [self.layer insertSublayer:_gradientLayer atIndex:0];
            [self.layer setNeedsLayout];
        }
    }
}

#pragma mark - Private functionality

static NSArray* createColors(void)
{
    CGFloat const colorMembers0[] = TMWRuleConditionButton_GradientColor0;
    CGFloat const colorMembers1[] = TMWRuleConditionButton_GradientColor1;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color0 = CGColorCreate(colorSpace, colorMembers0);
    CGColorRef color1 = CGColorCreate(colorSpace, colorMembers1);
    CGColorSpaceRelease(colorSpace);
    
    return @[(__bridge_transfer id)color0, (__bridge_transfer id)color1];
}

@end
