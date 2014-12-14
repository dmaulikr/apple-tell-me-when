#import "TMWTableViewCell.h"    // Header
#import "TMWUIProperties.h"     // TMW (Views)

static UIColor* kTMWTableViewCellUpperLineColor;
static UIColor* kTMWTableViewCellBottomLineColor;
static CGFloat kTMWTableViewCellLineHeight;

@implementation TMWTableViewCell
{
    CALayer* _upperLine;
    CALayer* _bottomLine;
}

#pragma mark - Public API

+ (void)initialize
{
    kTMWTableViewCellUpperLineColor = TMWCntrl_UpperLineColor;
    kTMWTableViewCellBottomLineColor = TMWCntrl_BottomLineColor;
    kTMWTableViewCellLineHeight = TMWCntrl_LineHeight;
}

- (void)awakeFromNib
{
    [self setUpperLineWithColor:kTMWTableViewCellUpperLineColor height:kTMWTableViewCellLineHeight];
    [self setBottomLineWithColor:kTMWTableViewCellBottomLineColor height:kTMWTableViewCellLineHeight];
}

- (void)setUpperLineWithColor:(UIColor*)color height:(CGFloat)height
{
    if (!color)
    {
        if (!_upperLine) { return; }
        [_upperLine removeFromSuperlayer];
        _upperLine = nil;
    }
    else
    {
        if (!_upperLine)
        {
            _upperLine = [CALayer layer];
            [self.layer addSublayer:_upperLine];
        }
        
        CGFloat const w = self.bounds.size.width;
        CGFloat const h = (height > 0) ? height : 0;
        _upperLine.bounds = CGRectMake(0.0, 0.0, w, h);
        _upperLine.position = CGPointMake(0.5*w, 0.5*h);
        _upperLine.backgroundColor = color.CGColor;
    }
}

- (void)setBottomLineWithColor:(UIColor*)color height:(CGFloat)height
{
    if (!color)
    {
        if (!_bottomLine) { return; }
        [_bottomLine removeFromSuperlayer];
        _bottomLine = nil;
    }
    else
    {
        if (!_bottomLine)
        {
            _bottomLine = [CALayer layer];
            [self.layer addSublayer:_bottomLine];
        }
        
        CGSize const size = self.bounds.size;
        CGFloat const h = (height > 0) ? height : 0;
        _bottomLine.bounds = CGRectMake(0.0, 0.0, size.width, h);
        _bottomLine.position = CGPointMake(0.5*size.width, size.height-0.5*h);
        _bottomLine.backgroundColor = color.CGColor;
    }
}

+ (TMWTableViewCell*)findCellOfChildView:(UIView*)view
{
    if (!view) { return nil; }
    Class const cellClass = [TMWTableViewCell class];
    
    while (![view isKindOfClass:cellClass])
    {
        view = view.superview;
        if (!view) { return nil; }
    }
    
    return (TMWTableViewCell*)view;
}

#pragma mark UIView methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize const size = self.bounds.size;
    if (_upperLine)
    {
        CGFloat const height = _upperLine.bounds.size.height;
        _upperLine.bounds = CGRectMake(0.0, 0.0, size.width, height);
        _upperLine.position = CGPointMake(0.5*size.width, 0.5*height);
    }
    
    if (_bottomLine)
    {
        CGFloat const height = _bottomLine.bounds.size.height;
        _bottomLine.bounds = CGRectMake(0.0, 0.0, size.width, height);
        _bottomLine.position = CGPointMake(0.5*size.width, size.height - 0.5*height);
    }
}

#pragma mark UITableViewCell methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
