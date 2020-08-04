//
//  BaseFlutterViewController.m
//  flutter_ios
//
//  Created by 小琦 on 2020/8/3.
//  Copyright © 2020 单琦. All rights reserved.
//

#import "BaseFlutterViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface BaseFlutterViewController ()

@end

@implementation BaseFlutterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.fd_prefersNavigationBarHidden = YES;
}

@end
