//
//  LoginViewController.m
//  ddt
//
//  Created by allen on 15/10/14.
//  Copyright (c) 2015年 Light. All rights reserved.
//
#import "LoginViewController.h"
#define InputViewHeight 60.0
#define UserIconWidth 10
#import "FindBackPasswordViewController.h"
#import "RegisterViewController.h"
@interface LoginViewController ()<UITextFieldDelegate>

@end

@implementation LoginViewController
@synthesize phoneNumTextField;
@synthesize passwordTextField;
@synthesize remeberPasswordandPhone;
@synthesize autoLoginNextime;
@synthesize loginBtn;
@synthesize regesterBtn;
@synthesize findPasswordBtn;
@synthesize mainView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"登录";
    [self createLeftBarItemWithBackTitle];
    mainView.layer.borderColor = [RGBA(207, 207, 207, 1)CGColor];
    mainView.layer.borderWidth = 1;
    remeberPasswordandPhone.checked = YES;
    autoLoginNextime.checked = YES;
    [self initViews];
    //注册键盘收起的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    [UIView animateWithDuration:1.0 animations:^{
        for (UIView *sview in self.view.subviews)
        {
            sview.transform=CGAffineTransformMakeTranslation(0, -46);
        }
    } completion:^(BOOL finished) {
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:1.0 animations:^{
        for (UIView *sview in self.view.subviews)
        {
            sview.transform=CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
    }];
}
-(void)goback:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)initViews{
    phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextField.font = [UIFont systemFontOfSize:14];
    [phoneNumTextField setReturnKeyType:UIReturnKeyNext];
    phoneNumTextField.delegate = self;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.font = [UIFont systemFontOfSize:14];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([phoneNumTextField isFirstResponder]) {
        [phoneNumTextField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
    }
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([phoneNumTextField isFirstResponder]) {
        [phoneNumTextField resignFirstResponder];
    }
    if ([passwordTextField isFirstResponder]) {
        [passwordTextField resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginBtnClick:(id)sender {
    //    jsondata={"mobile":"15136216190","pwd":"111","token":"15136216190(!)*^*1446701200"
    NSDate *localDate = [NSDate date]; //获取当前时间
    NSString *timeString = [NSString stringWithFormat:@"%lld", (long long)[localDate timeIntervalSince1970]];  //转化为UNIX时间戳
    NSString *token = [NSString stringWithFormat:@"18016373660(!)*^*%@",timeString];
    //...test
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"18016373660",@"mobile", @"123456789www",@"pwd",token,@"token",nil];
    NSString *jsonStr = [NSString jsonStringFromDictionary:dic1];
    
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:jsonStr,@"jsondata", nil];
    [SVProgressHUD showWithStatus:@"正在提交"];
    RequestTaskHandle *_task = [RequestTaskHandle taskWithUrl:NSLocalizedString(@"url_login", @"") parms:dic2 andSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"...responseObject  :%@",responseObject);
        
        if ([[responseObject objectForKey:@"result"]integerValue] == 0) {
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"message"]];
        }
    } faileBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"请求服务器失败,请重试"];
    }];
    
    [HttpRequestManager doPostOperationWithTask:_task];
}

- (IBAction)registerBtnClick:(id)sender {
    RegisterViewController *registerVC = [[MySharetools shared]getViewControllerWithIdentifier:@"registerView" andstoryboardName:@"me"];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)findBackBtnClick:(id)sender {
    FindBackPasswordViewController *find = [[FindBackPasswordViewController alloc]init];
    [self.navigationController pushViewController:find animated:YES];
}
@end
