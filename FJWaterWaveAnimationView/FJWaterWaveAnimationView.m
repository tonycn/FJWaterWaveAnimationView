//
//  FJWaterWaveAnimationView.m
//  TestWaterWav
//
//  Created by Jianjun on 16/11/2016.
//  Copyright © 2016 jianjun. All rights reserved.
//

#import "FJWaterWaveAnimationView.h"

static const NSInteger kNumbersOfPage = 3;
static const NSInteger kNumbersOfPageWhenTwoWave = kNumbersOfPage * 2;

@interface WaterWaveBreizerPath : NSObject <NSCopying>
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint controlPoint1;
@property (nonatomic, assign) CGPoint controlPoint2;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGPoint offsetPoint;
@property (nonatomic, strong) NSString *tag;
+ (instancetype)pathFrom:(CGPoint)sp
                     cp1:(CGPoint)cp1
                     cp2:(CGPoint)cp2
                     end:(CGPoint)ep
                  offset:(CGPoint)offsetPoint;
@end

@implementation WaterWaveBreizerPath
+ (instancetype)pathFrom:(CGPoint)sp cp1:(CGPoint)cp1 cp2:(CGPoint)cp2 end:(CGPoint)ep offset:(CGPoint)offsetPoint
{
    WaterWaveBreizerPath *path = [[WaterWaveBreizerPath alloc] init];
    path.startPoint = sp;
    path.controlPoint1 = cp1;
    path.controlPoint2 = cp2;
    path.endPoint = ep;
    path.offsetPoint = offsetPoint;
    return path;
}
- (UIBezierPath *)generateWavePathByOffsetX:(CGFloat)offsetX
{
    CGPoint start = CGPointMake(self.startPoint.x + self.offsetPoint.x + offsetX, self.startPoint.y + self.offsetPoint.y);
    CGPoint cp1 = CGPointMake(self.controlPoint1.x + self.offsetPoint.x + offsetX, self.controlPoint1.y + self.offsetPoint.y);
    CGPoint cp2 = CGPointMake(self.controlPoint2.x + self.offsetPoint.x + offsetX, self.controlPoint2.y + self.offsetPoint.y);
    CGPoint end = CGPointMake(self.endPoint.x + self.offsetPoint.x + offsetX, self.endPoint.y + self.offsetPoint.y);
    
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path moveToPoint:start];
    [path addCurveToPoint:end controlPoint1:cp1 controlPoint2:cp2];
    return path;
}

- (CGPoint)actualStartPoint
{
    CGPoint start = CGPointMake(self.startPoint.x + self.offsetPoint.x, self.startPoint.y + self.offsetPoint.y);
    return start;
}

- (CGPoint)actualEndPoint
{
    CGPoint end = CGPointMake(self.endPoint.x + self.offsetPoint.x, self.endPoint.y + self.offsetPoint.y);
    return end;
}

- (CGFloat)width
{
    return self.endPoint.x - self.startPoint.x;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"WaterWaveBreizerPath %@", self.tag];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    WaterWaveBreizerPath *copy = [WaterWaveBreizerPath pathFrom:self.startPoint
                                                            cp1:self.controlPoint1
                                                            cp2:self.controlPoint2
                                                            end:self.endPoint
                                                         offset:self.offsetPoint];
    copy.tag = self.tag;
    return copy;
}

@end

@interface FJWaterWaveAnimationView ()
@property (nonatomic, strong) CALayer *gradientLayer;
@property (nonatomic, strong) NSArray<__kindof WaterWaveBreizerPath *> *bezierPaths;
@property (nonatomic, strong) NSArray<__kindof WaterWaveBreizerPath *> *bezierPathsForDisplay;
@property (nonatomic) CGFloat waveMaxHeight;
@property (nonatomic) CGFloat wavePosition;
@property (nonatomic) CGFloat allWavesWidth;
@property (nonatomic, readwrite) CGFloat currentPosition;
@end

@implementation FJWaterWaveAnimationView

- (instancetype)initWithMaxHeight:(CGFloat)maxHeight
{
    self = [super init];
    self.waveMaxHeight = maxHeight;
    return self;
}

- (void)addGradientLayer
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect rect = self.bounds;
    rect.size.width = rect.size.width * kNumbersOfPageWhenTwoWave;
    rect.origin.x = -(kNumbersOfPageWhenTwoWave - 1) * self.bounds.size.width;
    gradient.frame = rect;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithWhite: 0.0 alpha:0.06] CGColor],
                       (id)[[UIColor colorWithWhite: 0.0 alpha:0.01] CGColor], nil];
    gradient.startPoint = CGPointMake(0.5, 0.0); // default; bottom of the view
    gradient.endPoint = CGPointMake(0.5, 1.0);   // default; top of the view
    
    
    self.gradientLayer = gradient;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (WaterWaveBreizerPath *)createPath:(CGFloat)widthRatio
                                 top:(CGFloat)topRatio
                              bottom:(CGFloat)bottomRatio
                              offset:(CGPoint)offset
{
    CGFloat waveW = widthRatio * self.frame.size.width;
    id p = [WaterWaveBreizerPath pathFrom:CGPointZero
                                      cp1:CGPointMake(waveW * 0.5, -self.waveMaxHeight * topRatio)
                                      cp2:CGPointMake(waveW * 0.5, self.waveMaxHeight * bottomRatio)
                                      end:CGPointMake(waveW, 0)
                                   offset:offset];
    return p;
}

- (void)addWaveBreizerPaths
{
    WaterWaveBreizerPath *path1 = [self createPath:0.65 top:1 bottom:1 offset:CGPointMake(0, self.waveMaxHeight)];
    WaterWaveBreizerPath *path2 = [self createPath:0.5 top:1 bottom:0.8 offset:path1.actualEndPoint];
    WaterWaveBreizerPath *path3 = [self createPath:0.7 top:1 bottom:1 offset:path2.actualEndPoint];
    WaterWaveBreizerPath *path4 = [self createPath:0.5 top:1 bottom:0.6 offset:path3.actualEndPoint];
    WaterWaveBreizerPath *path5 = [self createPath:0.65 top:1 bottom:1 offset:path4.actualEndPoint];
    self.bezierPaths = @[path1, path2, path3, path4, path5];
    int i = 1;
    for (WaterWaveBreizerPath *p in self.bezierPaths) {
        p.tag = [@((i++)) stringValue];
    }
    self.allWavesWidth = self.bezierPaths.lastObject.actualEndPoint.x;
    NSAssert((int)self.allWavesWidth / (int)self.frame.size.width == kNumbersOfPage, @"should be kNumbersOfPage * width");
    NSAssert((int)self.allWavesWidth % (int)self.frame.size.width == 0, @"should be n * width");
    NSAssert(self.bezierPaths.lastObject.actualEndPoint.y == self.bezierPaths.firstObject.actualStartPoint.y, @"should equal");
    [self copyWavePathInFront];
}

- (void)copyWavePathInFront
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:2 * self.bezierPaths.count];
    for (WaterWaveBreizerPath *p in self.bezierPaths) {
        WaterWaveBreizerPath *newP = [p copy];
        [arr addObject:newP];
    }
    [arr addObjectsFromArray:self.bezierPaths];
    CGFloat offsetX = 0;
    for (WaterWaveBreizerPath *p in arr) {
        p.offsetPoint = CGPointMake(offsetX, p.offsetPoint.y);
        offsetX = [p actualEndPoint].x;
    }
    self.bezierPathsForDisplay = arr;
}

- (UIBezierPath *)generatePathByOffsetX:(CGFloat)offsetX
{
    UIBezierPath *path;
    for (WaterWaveBreizerPath *p in self.bezierPathsForDisplay) {
        if (path == nil) {
            path = [p generateWavePathByOffsetX:offsetX];
        } else {
            [path appendPath:[p generateWavePathByOffsetX:offsetX]];
        }
    }
    [path addLineToPoint:CGPointMake(self.gradientLayer.bounds.size.width, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(-self.gradientLayer.bounds.size.width, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(-self.gradientLayer.bounds.size.width, self.waveMaxHeight)];
    return path;
}

- (void)updateViewByWavePosition:(CGFloat)wavePosition
{
    [self addWaveBreizerPaths];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = [self generatePathByOffsetX:self.allWavesWidth * wavePosition].CGPath;
    self.gradientLayer.mask = mask;
    self.gradientLayer.masksToBounds = YES;
}

- (void)startWaveAnimationWithDuration:(CGFloat)duration
{
    if ([self.gradientLayer animationForKey:@"move_wave_animation"]) {
        [self.gradientLayer removeAnimationForKey:@"move_wave_animation"];
    }
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"bounds.origin.x"];
    move.fromValue = @(0);
    move.toValue   = @(-0.5 * self.gradientLayer.bounds.size.width);
    move.repeatCount = CGFLOAT_MAX;
    move.duration  = duration;
    // add any additional animation configuration here...
    [self.gradientLayer addAnimation:move forKey:@"move_wave_animation"];
}

@end
