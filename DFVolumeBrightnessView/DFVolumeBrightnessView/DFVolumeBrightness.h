//
//  DFVolumeBrightness.h
//  DFVolumeBrightnessView
//
//  Created by DevilFinger on 10/18/16.
//  Copyright © 2016 DevilFingerTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFVolumeBrightness : NSObject
+ (instancetype)sharedInstance;
- (void)initSwipWithTargetView:(UIView *)targetView;
- (void)handleSwipe:( UIPanGestureRecognizer *)gesture;
@end
