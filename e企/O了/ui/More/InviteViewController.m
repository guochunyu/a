//
//  InviteViewController.m
//  e企
//
//  Created by xuxue on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "InviteViewController.h"
#import "CreateHttpHeader.h"

@interface InviteViewController ()
{
    NSString *headStr;
    NSInteger reqTimes;
}

@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"邀请体验";
    reqTimes = 0;
}

#pragma mark  SMS

-(IBAction)inviteFriend:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *phone = [_text_phone.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([phone length] != 11)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请输入正确的手机号!" isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }
    
    reqTimes ++;

    //      MFMessageComposeViewController API.
    AFClient *client = [AFClient sharedClient];
    NSDictionary *dict=@{@"phone": phone};
    NSString *gid = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];

    [client postPath:[NSString stringWithFormat:@"eas/invite?gid=%@&cid=%@",gid,cid] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogInfo(@"userinforData===%@",operation.responseString);
         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
         DDLogInfo(@"dic====%@",dic);
         
         if([[dic objectForKey:@"status"]integerValue] == 1)
         {
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:0 delayTime:1 isKeyShow:NO];
             [self.navigationController popViewControllerAnimated:YES];

         }
         else
         {
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:1 delayTime:1 isKeyShow:NO];
             
         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSInteger stateCode = operation.response.statusCode;
         DDLogInfo(@"%d",stateCode);
         if(stateCode == 401 && reqTimes <= 10)
         {
             NSDictionary *ddd=operation.response.allHeaderFields;
             if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                 NSString *nonce=[ddd objectForKey:@"Www-Authenticate"];
                 headStr = [CreateHttpHeader createHttpHeaderWithNoce:nonce];
                 NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
                 [client setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
                 
                 [self inviteFriend:sender];
                 
             }
         }else
         {
             reqTimes = 0;
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"邀请失败!" isCue:1 delayTime:1 isKeyShow:NO];
         }
         

     }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (string.length > 0) {
        if (textField.text.length == 3) {
            textField.text = [NSString stringWithFormat:@"%@ ",textField.text];
        }
        if (textField.text.length == 8) {
            textField.text = [NSString stringWithFormat:@"%@ ",textField.text];
        }
        else if(textField.text.length == 12){
            textField.text = [textField.text stringByAppendingString:string];
            [self.view endEditing:YES];
            return NO;
        }
        else if (textField.text.length ==13) {
            [self.view endEditing:YES];
            return NO;
        }
    }
    return YES;
    
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

@end
