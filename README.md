## iOS 指纹识别登录功能实现

#### 简介
Touch ID是苹果公司的一种指纹识别技术，从iPhone 5s开始，早已为人们所熟知。

Touch ID不存储用户的任何指纹图像，只保存代表指纹的数字字符。苹果公司提供Touch ID给第三方应用程序使用，程序只会收到认证是否成功的通知，而无法访问 Touch ID 或与已注册指纹相关的数据，这一点对安全而言尤为重要。

现在有很多银行类APP、涉及到支付类的APP都集成了指纹、手势等二次验证功能，从而使APP获得更高的安全性。今天我们就来分析一下指纹识别登录功能的具体实现。

#### 源码

[GitHub-demo](https://github.com/fanbaoying/GesturePassword)

#### 实现步骤

1.首先引入指纹解锁的库文件
```
#import <LocalAuthentication/LocalAuthentication.h>
```
2.两个主要方法

* 这个方法是判断设备是否支持TouchID的
```
- (BOOL)canEvaluatePolicy:(LAPolicy)policy error:(NSError * __autoreleasing *)
error __attribute__((swift_error(none)));
```
* 这个是用来验证TouchID的，会有弹出框出来
```
- (void)evaluatePolicy:(LAPolicy)policy
       localizedReason:(NSString *)localizedReason
                 reply:(void(^)(BOOL success, NSError * __nullable error))reply;
```

3.核心源码
在demo中touchID函数是实现指纹识别的核心代码，源码如下：
```
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
```
核心代码只要分为两部分，一部分是设备支持指纹识别，另一部分是设备不支持指纹识别

![指纹识别.gif](http://upload-images.jianshu.io/upload_images/2829694-1c560f064f47fd9b.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
