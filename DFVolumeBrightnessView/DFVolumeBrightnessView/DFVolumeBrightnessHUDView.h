//
//  DFVolumeBrightnessView.h
//  DFVolumeBrightnessView
//
//  Created by DevilFinger on 10/18/16.
//  Copyright © 2016 DevilFingerTeam. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DFVolumeBrightnessHUDView : UIView
+ (instancetype)sharedInstance;
+ (void)showWithIsVolumen:(BOOL)isVolumne
             withProgress:(CGFloat)progress;
-(void)dismiss;
@end
