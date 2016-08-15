//
//  FFRulerControl.m
//  FFRuler
//
//  Created by 刘凡 on 2016/8/15.
//  Copyright © 2016年 joyios. All rights reserved.
//

#import "FFRulerControl.h"

/**
 * 小刻度间距默认值
 */
#define kMinorScaleDefaultSpacing   8.0

/**
 * 主刻度长度默认值
 */
#define kMajorScaleDefaultLength    40.0
/**
 * 中间刻度长度默认值
 */
#define kMiddleScaleDefaultLength   25.0
/**
 * 小刻度长度默认值
 */
#define kMinorScaleDefaultLength    10.0
/**
 * 刻度颜色默认值
 */
#define kScaleDefaultColor          ([UIColor lightGrayColor])

/**
 * 刻度字体颜色默认值
 */
#define kScaleDefaultFontColor      ([UIColor darkGrayColor])
/**
 * 刻度字体默认值
 */
#define kScaleDefaultFontSize       10.0

/**
 * 指示器默认颜色
 */
#define kIndicatorDefaultColor      ([UIColor redColor])
/**
 * 指示器长度默认值
 */
#define kIndicatorDefaultLength     40.0

@implementation FFRulerControl {
    UIScrollView *_scrollView;
    UIImageView *_rulerImageView;
    UIView *_indicatorView;
}

#pragma mark - 构造函数
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    UIImage *image = [self rulerImage];
    
    if (image) {
        _rulerImageView.image = image;
        _rulerImageView.backgroundColor = [UIColor yellowColor];
        
        [_rulerImageView sizeToFit];
        _scrollView.contentSize = _rulerImageView.image.size;
    }
}

#pragma mark - 绘制标尺相关方法
/**
 * 生成标尺图像
 */
- (UIImage *)rulerImage {
    
    // 1. 常数计算
    CGFloat steps = [self stepsWithValue:_maxValue];
    if (steps == 0) {
        return nil;
    }
    
    // 水平方向绘制图像的大小
#warning 临时高度
    CGFloat height = 80;
    CGRect rect = CGRectMake(0, 0, steps * self.minorScaleSpacing, height);
    
    // 2. 绘制图像
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    // 1> 绘制刻度线
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (NSInteger i = _minValue; i <= _maxValue; i += _valueStep) {
        
        // 绘制主刻度
        CGFloat x = (i - _minValue) / _valueStep * self.minorScaleSpacing * 10;
        [path moveToPoint:CGPointMake(x, height)];
        [path addLineToPoint:CGPointMake(x, height - self.majorScaleLength)];
        
        if (i == _maxValue) {
            break;
        }
        
        // 绘制小刻度线
        for (NSInteger j = 1; j < 10; j++) {
            CGFloat scaleX = x + j * self.minorScaleSpacing;
            [path moveToPoint:CGPointMake(scaleX, height)];
            
            CGFloat scaleY = height - ((j == 5) ? self.middleScaleLength : self.minorScaleLength);
            [path addLineToPoint:CGPointMake(scaleX, scaleY)];
        }
    }
    
    [self.scaleColor set];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

/**
 * 计算最小值和指定 value 之间的步长，即：绘制刻度的总数量
 */
- (CGFloat)stepsWithValue:(CGFloat)value {
    
    if (_minValue >= value || _valueStep <= 0) {
        return 0;
    }
    
    return (value - _minValue) / _valueStep * 10;
}
//
///**
// * 以水平绘制方向计算 `最大数值的文字` 尺寸
// */
//- (CGSize)maxValueTextSize {
//    
//    NSString *scaleText = @(self.maxValue).description;
//    
//    return [scaleText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
//                                   options:NSStringDrawingUsesLineFragmentOrigin
//                                attributes:[self scaleTextAttributes]
//                                   context:nil].size;
//}
//
//- (NSDictionary *)scaleTextAttributes {
//    
//    CGFloat fontSize = self.scaleFontSize * [UIScreen mainScreen].scale * 0.5;
//    
//    return @{NSForegroundColorAttributeName: self.scaleFontColor,
//             NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]};
//}
//
#pragma mark - 设置界面
- (void)setupUI {
    // 默认水平方向滚动
    _verticalScroll = NO;
    
    // 滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_scrollView];
    
    // 标尺图像
    _rulerImageView = [[UIImageView alloc] init];
    
    [_scrollView addSubview:_rulerImageView];
    
    // 指示器视图
    _indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = self.indicatorColor;
    
    [self addSubview:_indicatorView];
}

#pragma mark - 属性默认值
- (CGFloat)minorScaleSpacing {
    if (_minorScaleSpacing <= 0) {
        _minorScaleSpacing = kMinorScaleDefaultSpacing;
    }
    return _minorScaleSpacing;
}

- (CGFloat)majorScaleLength {
    if (_majorScaleLength <= 0) {
        _majorScaleLength = kMajorScaleDefaultLength;
    }
    return _majorScaleLength;
}

- (CGFloat)middleScaleLength {
    if (_middleScaleLength <= 0) {
        _middleScaleLength = kMiddleScaleDefaultLength;
    }
    return _middleScaleLength;
}

- (CGFloat)minorScaleLength {
    if (_minorScaleLength <= 0) {
        _minorScaleLength = kMinorScaleDefaultLength;
    }
    return _minorScaleLength;
}

- (UIColor *)scaleColor {
    if (_scaleColor == nil) {
        _scaleColor = kScaleDefaultColor;
    }
    return _scaleColor;
}

- (UIColor *)scaleFontColor {
    if (_scaleFontColor == nil) {
        _scaleFontColor = kScaleDefaultFontColor;
    }
    return _scaleFontColor;
}

- (CGFloat)scaleFontSize {
    if (_scaleFontSize <= 0) {
        _scaleFontSize = kScaleDefaultFontSize;
    }
    return _scaleFontSize;
}

- (UIColor *)indicatorColor {
    if (_indicatorColor == nil) {
        _indicatorColor = kIndicatorDefaultColor;
    }
    return _indicatorColor;
}

- (CGFloat)indicatorLength {
    if (_indicatorLength <= 0) {
        _indicatorLength = kIndicatorDefaultLength;
    }
    return _indicatorLength;
}

@end
