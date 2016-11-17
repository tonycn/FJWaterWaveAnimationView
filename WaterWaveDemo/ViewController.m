//
//  ViewController.m
//  TestWaterWav
//
//  Created by Jianjun on 16/11/2016.
//  Copyright © 2016 jianjun. All rights reserved.
//

#import "ViewController.h"


#import "FJWaterWaveAnimationView.h"

@interface ViewController ()
@property (nonatomic, strong) FJWaterWaveAnimationView *waveView;
@property (nonatomic, strong) FJWaterWaveAnimationView *waveView2;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    FJWaterWaveAnimationView *waveView = [[FJWaterWaveAnimationView alloc] initWithMaxHeight:self.view.frame.size.width / 10];
    self.waveView = waveView;
    [self.view addSubview:self.waveView];
    self.waveView.frame = self.view.bounds;
    [self.waveView addGradientLayer];
    [self.waveView updateViewByWavePosition:0];
    
    FJWaterWaveAnimationView *waveView2 = [[FJWaterWaveAnimationView alloc] initWithMaxHeight:self.view.frame.size.width / 10];
    self.waveView2 = waveView2;
    [self.view addSubview:waveView2];
    self.waveView2.frame = self.view.bounds;
    [self.waveView2 addGradientLayer];
    [self.waveView2 updateViewByWavePosition:0.27];

    [self startWaveAnimation];
}

- (void)startWaveAnimation
{
    [self.waveView startWaveAnimationWithDuration:6];
    [self.waveView2 startWaveAnimationWithDuration:6];
}

@end
