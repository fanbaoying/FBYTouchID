//
//  ViewController.m
//  FBYTouchID
//
//  Created by 范保莹 on 2017/12/25.
//  Copyright © 2017年 FBYTouchID. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property(strong,nonatomic)UIButton *nameBtn;
@property(strong,nonatomic)UILabel *nameLab;

@property(strong,nonatomic)UIButton *touchIDBtn;
@property(strong,nonatomic)UILabel *reminderLab;

@property(strong,nonatomic)UILabel *touchIDLab;
@property(strong,nonatomic)UISwitch *touchIDSwitch;

@property(strong,nonatomic)UIButton *setOutBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"个人中心";
    
    [self content];
}

- (void)content {
    
    self.nameBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-35, 85, 70, 70)];
    [self.nameBtn setImage:[UIImage imageNamed:@"head"] forState:0];
    self.nameBtn.layer.borderWidth = 1.0;
    self.nameBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nameBtn.layer.cornerRadius = 35.0;
    self.nameBtn.clipsToBounds = YES;
    [self.view addSubview:_nameBtn];
    
    self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 165, SCREEN_WIDTH, 20)];
    self.nameLab.text = @"未登录";
    self.nameLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nameLab];
    
    self.touchIDBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, SCREEN_HEIGHT/2-40, 90, 90)];
    [self.touchIDBtn setImage:[UIImage imageNamed:@"touchID"] forState:0];
    [self.touchIDBtn addTarget:self action:@selector(touchIDBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.touchIDBtn.layer.cornerRadius = 45.0;
    self.touchIDBtn.clipsToBounds = YES;
    [self.view addSubview:_touchIDBtn];
    
    self.reminderLab = [[UILabel alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2+50, SCREEN_WIDTH, 20)];
    self.reminderLab.text = @"点击进行指纹登录";
    self.reminderLab.textColor = [UIColor colorWithRed:127/255.0 green:175/255.0 blue:212/255.0 alpha:1];
    self.reminderLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_reminderLab];
    
    self.setOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/5, SCREEN_HEIGHT-150, SCREEN_WIDTH*3/5, 50)];
    self.setOutBtn.hidden = YES;
    self.setOutBtn.backgroundColor = [UIColor redColor];
    [self.setOutBtn addTarget:self action:@selector(setOutBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.setOutBtn setTitle:@"退出登录" forState:0];
    [self.view addSubview:_setOutBtn];
    
}

- (void)touchIDBtn:(UIButton *)sender {
    
//    指纹登录
    [self touchID];
    
}

- (void)setOutBtn:(UIButton *)sender {
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否退出登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nameLab.text = @"未登录";
            self.setOutBtn.hidden = YES;
        });
    }];
    
    [alert addAction:action];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)touchID {
    
    //创建LAContext
    LAContext *context = [LAContext new];
    
    //这个属性是设置指纹输入失败之后的弹出框的选项
    context.localizedFallbackTitle = @"没有忘记密码";
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
//        NSLog(@"支持指纹识别");
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按home键指纹登录" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"登录成功" preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:nil];
                    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
                    
                    self.nameLab.text = @"FBY展菲";
                    self.setOutBtn.hidden = NO;
                });
                
            }else{
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"系统取消授权，如其他APP切入");
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"用户取消验证Touch ID");
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        NSLog(@"授权失败");
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        NSLog(@"系统未设置密码");
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        NSLog(@"设备Touch ID不可用，例如未打开");
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        NSLog(@"设备Touch ID不可用，用户未录入");
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"用户选择输入密码，切换主线程处理");
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"其他情况，切换主线程处理");
                        }];
                        break;
                    }
                }
            }
        }];
    }else{
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"不支持指纹识别" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
        
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
    
}

- (void)dismiss:(UIAlertController *)alert{
    
    [alert dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
