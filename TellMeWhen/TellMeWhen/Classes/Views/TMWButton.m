#import "TMWButton.h"               // Header
#import "UIColor+LightAndDark.h"    // TMW (Utilities)

@implementation TMWButton
{
    UIColor* _normalColor;
    UIColor* _highlightColor;
}

#pragma mark - Public API

- (void)willMoveToWindow:(UIWindow*)newWindow
{
    if (newWindow)
    {
        [self setStateColorsWith:self.backgroundColor];
        [self addTarget:self action:@selector(touchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    else { [self removeTarget:self action:@selector(touchedUpInside:) forControlEvents:UIControlEventTouchUpInside]; }
}

- (void)setBackgroundColor:(UIColor*)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [self setStateColorsWith:backgroundColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.highlighted == highlighted) { return; }
    [super setHighlighted:highlighted];
    
    self.layer.backgroundColor = (!highlighted) ? _normalColor.CGColor : _highlightColor.CGColor;
}

#pragma mark - Private funtionality

- (void)setStateColorsWith:(UIColor*)color
{
    _normalColor = (color) ? color : [UIColor grayColor];
    _highlightColor = [_normalColor darkerColor];
}

- (void)touchedUpInside:(TMWButton*)sender
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(backgroundColor))];
    anim.duration = 0.3;
    anim.fromValue = (__bridge id)_highlightColor.CGColor;
    anim.toValue = (__bridge id)_normalColor.CGColor;
    [self.layer addAnimation:anim forKey:@"TMWAnim_TMWButtonTouchedUpInside"];
}

@end
