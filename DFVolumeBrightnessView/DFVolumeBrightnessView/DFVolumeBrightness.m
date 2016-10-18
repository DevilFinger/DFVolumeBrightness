//
//  DFVolumeBrightness.m
//  DFVolumeBrightnessView
//
//  Created by DevilFinger on 10/18/16.
//  Copyright © 2016 DevilFingerTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaToolbox/MediaToolbox.h>

#import "DFVolumeBrightness.h"
#import "DFVolumeBrightnessHUDView.h"


typedef NS_ENUM(NSInteger, DFSwipeDirection)
{
    DFSwipeDirection_None,
    DFSwipeDirection_Hor,
    DFSwipeDirection_Ver
};

typedef NS_ENUM(NSInteger, DFSwipeArea)
{
    DFSwipeArea_None,
    DFSwipeArea_Voice,
    DFSwipeArea_Light,
};

CGFloat const GestureMinimumTranslation = 20.0f;
CGFloat const MPVolumuSliderPerValue = 0.02f;

@interface DFVolumeBrightness()<UIGestureRecognizerDelegate>

@property (nonatomic, assign)  DFSwipeDirection       curSwipDirection;
@property (nonatomic, assign)  DFSwipeArea            curSwipArea;
@property (nonatomic, strong)  UIView                 *targetView;
@property (nonatomic, assign)  CGPoint                firstSwipPoint;
@property (nonatomic, strong)  MPVolumeView           *mpVolumeView;
@property (nonatomic, strong)  UISlider               *mpVolumeSlider;
@end

@implementation DFVolumeBrightness

+ (instancetype)sharedInstance {
    static DFVolumeBrightness *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)initSwipWithTargetView:(UIView *)targetView
{
    if (_targetView) {
        _targetView = nil;
    }
    _targetView = targetView;
    [self setupMPVolumeView];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(deviceOrientationDidChange:)
     
                                                 name:UIDeviceOrientationDidChangeNotification
     
                                               object:nil];
}

-(void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)deviceOrientationDidChange:(NSObject*)sender{
    [[DFVolumeBrightnessHUDView sharedInstance] dismiss];
    
}
-(void)setupMPVolumeView
{
    if (self.mpVolumeView) {
        [self.mpVolumeView removeFromSuperview];
        self.mpVolumeView = nil;
    }
    self.mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, [UIScreen mainScreen].bounds.size.width, 100)];
    self.mpVolumeView.hidden = NO;
    [_targetView addSubview:self.mpVolumeView];
    for (UIView *view in [self.mpVolumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.mpVolumeSlider = (UISlider*)view;
            break;
        }
    }
}

-(DFSwipeDirection)getDirectionWithPoint:(CGPoint)translate
{
    if (_curSwipDirection != DFSwipeDirection_None) {
        return _curSwipDirection;
    }
    else
    {
        if (fabs(translate.x) > GestureMinimumTranslation)
            return  DFSwipeDirection_Hor;
        else if(fabs(translate.y) > GestureMinimumTranslation)
            return  DFSwipeDirection_Ver;
        else
            return  DFSwipeDirection_None;
    }
}


-(CGFloat)getDirectionOffset:(CGPoint)translate
{
    if (_curSwipDirection == DFSwipeDirection_None) {
        return  0.0f;
    }
    else if (_curSwipDirection == DFSwipeDirection_Hor)
    {
        return translate.x;
    }
    else
    {
        return  translate.y;
    }
}

- (void)handleSwipe:( UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        _firstSwipPoint = [gesture translationInView:self.targetView];
        CGPoint point = [gesture locationInView:self.targetView];
        CGFloat midX = [UIScreen mainScreen].bounds.size.width / 2;
        if (point.x > midX) {
            _curSwipArea = DFSwipeArea_Voice;
        }
        else
            _curSwipArea = DFSwipeArea_Light;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged )
    {
        CGPoint currentPoint = [gesture translationInView:self.targetView];
        _curSwipDirection = [self getDirectionWithPoint:currentPoint];
        if (_curSwipDirection == DFSwipeDirection_Ver) {
            if (currentPoint.y - _firstSwipPoint.y > 0) {
                if (_curSwipArea == DFSwipeArea_Voice) {
                    self.mpVolumeSlider.value -= MPVolumuSliderPerValue;
                    [DFVolumeBrightnessHUDView showWithIsVolumen:YES withProgress: self.mpVolumeSlider.value];
                }
                else
                {
                    CGFloat currentLight = [[UIScreen mainScreen] brightness];
                    [[UIScreen mainScreen] setBrightness: currentLight - MPVolumuSliderPerValue];
                    [DFVolumeBrightnessHUDView showWithIsVolumen:NO withProgress: [[UIScreen mainScreen] brightness]];
                }
            }
            else if (currentPoint.y - _firstSwipPoint.y < 0)
            {
                if (_curSwipArea == DFSwipeArea_Voice) {
                    self.mpVolumeSlider.value += MPVolumuSliderPerValue;
                    [DFVolumeBrightnessHUDView showWithIsVolumen:YES withProgress: self.mpVolumeSlider.value];
                }
                else
                {
                    CGFloat currentLight = [[UIScreen mainScreen] brightness];
                    [[UIScreen mainScreen] setBrightness: currentLight + MPVolumuSliderPerValue];
                    [DFVolumeBrightnessHUDView showWithIsVolumen:NO withProgress: [[UIScreen mainScreen] brightness]];
                }
            }
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded )
    {
        _firstSwipPoint   = CGPointZero;
        _curSwipDirection = DFSwipeDirection_None;
        _curSwipArea      = DFSwipeArea_None;
    }
}


@end
