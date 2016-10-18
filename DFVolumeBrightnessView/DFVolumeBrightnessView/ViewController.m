//
//  ViewController.m
//  DFVolumeBrightnessView
//
//  Created by DevilFinger on 10/18/16.
//  Copyright © 2016 DevilFingerTeam. All rights reserved.
//

#import "ViewController.h"
#import "DFVolumeBrightness.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)viewDidAppear:(BOOL)animated
{
    [[DFVolumeBrightness sharedInstance] initSwipWithTargetView:self.view];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:pan];

}

- (void)handleSwipe:( UIPanGestureRecognizer *)gesture
{
    [[DFVolumeBrightness sharedInstance] handleSwipe:gesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
