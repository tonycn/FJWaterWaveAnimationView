//
//  FJWaterWaveAnimationView.h
//  TestWaterWav
//
//  Created by Jianjun on 16/11/2016.
//  Copyright © 2016 jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJWaterWaveAnimationView : UIView
@property (nonatomic, readonly) CGFloat currentPosition;
- (instancetype)initWithMaxHeight:(CGFloat)maxHeight;
- (void)addGradientLayer;
- (void)updateViewByWavePosition:(CGFloat)wavePosition;
- (void)startWaveAnimationWithDuration:(CGFloat)duration;

@end
