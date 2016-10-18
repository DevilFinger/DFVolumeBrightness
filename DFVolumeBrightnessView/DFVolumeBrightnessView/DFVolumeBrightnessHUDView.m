//
//  DFVolumeBrightnessView.m
//  DFVolumeBrightnessView
//
//  Created by DevilFinger on 10/18/16.
//  Copyright © 2016 DevilFingerTeam. All rights reserved.
//

#import "DFVolumeBrightnessHUDView.h"

#define UIColorHex(c)      [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]
#define TitleLabelHeight   30.0f
#define CenterImageWidth   70.0f
#define CenterImageHeight  75.0f
#define ProgressWidth      47.5f
#define ProgressItemWidth  5.0f

#define ProgressOffsetValue 1.6f
#define ProgressViewWidth  95.0f
#define VolumeBrightnessViewWidth  155.0f
#define VolumeBrightnessViewHeight 155.0f




@interface DFVolumeBrightnessHUDView()
@property (nonatomic, strong)  UIImageView      *bmgView;

@property (strong, nonatomic)  UIView           *progressView;
@property (strong, nonatomic)  UIImageView      *centerImageView;
@property (strong, nonatomic)  UILabel          *titleLabel;
@property (nonatomic, assign)  BOOL             isVolume;
@property (nonatomic, assign)  CGFloat          progress;



@end


@implementation DFVolumeBrightnessHUDView

/*singleton*/
+ (instancetype)sharedInstance {
    static DFVolumeBrightnessHUDView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}


-(void)setupUI
{
    if (self.bmgView) {
        [self.bmgView removeFromSuperview];
        self.bmgView = nil;
    }
    
    self.bmgView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.bmgView.image = [UIImage imageNamed:@"setting_bg"];
    [self addSubview:self.bmgView];
    
    if (self.titleLabel) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TitleLabelHeight)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = UIColorHex(0xFFFFFF);
    [self addSubview:self.titleLabel];
    
    if (self.centerImageView) {
        [self.centerImageView removeFromSuperview];
        self.centerImageView = nil;
    }
    
    self.centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width / 2 ) - (CenterImageWidth / 2.0f),
                                                                         (self.frame.size.height / 2 ) - (CenterImageHeight / 2.0f),
                                                                         CenterImageWidth,
                                                                         CenterImageHeight)];
    self.centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.centerImageView];
    
    if (self.progressView) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - ProgressWidth,
                                                                 self.centerImageView.frame.size.height + self.centerImageView.frame.origin.y + 18,
                                                                 95,
                                                                 7)];
    self.progressView.backgroundColor = UIColorHex(0x8f8f8f);
    [self addSubview:self.progressView];
}



-(void)setupProgress
{
    CGFloat value = self.progress * ProgressOffsetValue;
    NSInteger count = (NSInteger)(value / 0.1);
    if (!self.isVolume) {
        if (count == 0) {
            count = 1;
        }
    }
    CGFloat posx = 0;
    for (int i = 0; i < count; i++) {
        UIView *view = [[UIView alloc ] initWithFrame:CGRectMake( i * 1 + (ProgressItemWidth * i), 1, 5, 5)];
        view.backgroundColor = UIColorHex(0xE6E6E6);
        [self.progressView addSubview:view];
        posx = posx + (ProgressItemWidth * i) + (i * 1);
    }
    
}

-(void)cancelDeylayDismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAnimate) object:nil];
}

+ (void)showWithIsVolumen:(BOOL)isVolumne
             withProgress:(CGFloat)progress
{
    DFVolumeBrightnessHUDView *dfView = [DFVolumeBrightnessHUDView sharedInstance];
    dfView.alpha = 1.0f;
    [dfView cancelDeylayDismiss];
    [dfView dismiss];
    dfView.isVolume = isVolumne;
    dfView.progress = progress;
    CGRect mainRc = [UIScreen mainScreen].bounds;
    [dfView setFrame:CGRectMake(mainRc.size.width / 2 - (VolumeBrightnessViewWidth / 2),
                                mainRc.size.height / 2 - (VolumeBrightnessViewHeight / 2),
                                VolumeBrightnessViewWidth,
                                VolumeBrightnessViewHeight)];
    [dfView setupUI];
    [dfView setupProgress];
    if (isVolumne) {
        dfView.titleLabel.text = @"Volume";
        dfView.centerImageView.image = [UIImage imageNamed:@"setting_sound"];
        if (dfView.progress <= 0) {
            dfView.centerImageView.image = [UIImage imageNamed:@"setting_selince"];
        }
    }
    else
    {
        dfView.titleLabel.text = @"Brightness";
        dfView.centerImageView.image = [UIImage imageNamed:@"setting_brighting"];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:dfView];
    [dfView performSelector:@selector(dismissAnimate) withObject:nil afterDelay:2.0f];
}

- (void)dismiss
{
    
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
    [self.centerImageView removeFromSuperview];
    self.centerImageView = nil;
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    [self removeFromSuperview];
}


-(void)dismissAnimate
{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self dismiss];
    }];
}

//-(void)rotate
//{
//    UIDevice *device = [UIDevice currentDevice];
//    switch (device.orientation) {
//        case UIDeviceOrientationLandscapeLeft:
//            self.transform  = CGAffineTransformMakeRotation((CGFloat)(-90 * M_PI / 180.0));
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            self.transform  = CGAffineTransformMakeRotation((CGFloat)(90 * M_PI / 180.0));
//            break;
//        case UIDeviceOrientationPortrait:
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//            break;
//        default:
//            break;
//    }
//}


@end
