//
//  SecondViewController.m
//  flutter_ios
//
//  Created by 小琦 on 2020/8/1.
//  Copyright © 2020 单琦. All rights reserved.
//

#import "SecondViewController.h"
#import "BaseFlutterRouter.h"
@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupButton];
}

-(void)setupButton{
    [self setButton:@"原生跳转Flutter" action:@selector(nativeToFlutter) height:300];
}

-(void)setButton:(NSString *)title action:(SEL )action height:(CGFloat)height{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
              action:action
    forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    button.frame = CGRectMake((375 - 160) / 2, height, 160.0, 40);
    [self.view addSubview:button];
}

-(void)nativeToFlutter{
    [BaseFlutterRouter.sharedRouter open:@"first" urlParams:@{} exts:@{@"animated":@(YES),@"title":@"原生进入的页面"} completion:^(BOOL f){}];
}

@end
