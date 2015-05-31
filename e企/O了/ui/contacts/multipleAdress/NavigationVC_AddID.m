//
//  NavigationVC_AddID.m
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "NavigationVC_AddID.h"
#import "QunLiaoListViewController.h"

static NSString *const haveSendMessage=@"haveSendMessage";

@interface NavigationVC_AddID (){
    NSMutableArray *addIdArray;///<选择的人员列表
    UIButton *_leftButt;
}

@end

@implementation NavigationVC_AddID
@synthesize delegate_addID = _delegate_addID,addScrollOkButtTitle,isSmsInvitation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //bar set
    [self.navigationBar setBackgroundImage:[self imageWithColor:UIColorFromRGB(0x408af4)] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = NO;
    
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.8];
  //  [self.navigationBar setBackgroundImage:[UIImage imageNamed:IS_IOS_7 ? @"top_ios7.png" : @"top.png"] forBarMetrics:UIBarMetricsDefault];
 
    //新版1
//    [self.navigationBar setBackgroundColor:[UIColor colorWithRed:64 green:138 blue:244 alpha:1]];
    [self.toolbar setTintColor:[UIColor whiteColor]];
    
	// Do any additional setup after loading the view.
    [[addScrollView_messege sharedInstanse] releaseInstanse];
    _addscroll = [addScrollView_messege sharedInstanse];
    _addscroll.okButtonTitle=addScrollOkButtTitle;
    _addscroll.navCT = self;
    _addscroll.delegate = self;
    _addscroll.isSmsInvitation=isSmsInvitation;
    _addscroll.nowcount=[_phoneArray count];
    [_addscroll.array_addcontact arrayByAddingObjectsFromArray:self.Array_addedID];
    [_addscroll show];
    
    
  //    DDLogInfo(@"%@",self.str);
}

-(UIImage*) imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - 选择一个群聊开始回话
-(void)selectOneRoom:(RoomInfoModel *)roomModel{
    if (roomModel) {
        
        NSArray *tempArray=[roomModel.roomMemberListStr componentsSeparatedByString:@";"];
        NSMutableArray *emArray=[[NSMutableArray alloc] init];
        for (NSString *imacc in tempArray) {
            EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:imacc];
            if (em.imacct == nil) {
                continue;
            }
            [emArray addObject:em];
        }
        roomModel.roomMemberList=emArray;
        [self.delegate_addID GetArrayID:roomModel];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}
#pragma mark-------选择多人聊天的确定按钮
#pragma mark addScrollView_messege delegate
#warning ---------------------少用户自己的原因在这里-------
-(void)SendArrayID:(NSMutableArray *)array_addId{
//  添加自己的信息
    NSMutableArray * roomMember=[[NSMutableArray alloc]initWithArray:array_addId];
    EmployeeModel * model=[[EmployeeModel alloc]init];
    model.imacct=[ConstantObject sharedConstant].userInfo.imacct;
    model.name=[ConstantObject sharedConstant].userInfo.name;
    model.avatarimgurl=[ConstantObject sharedConstant].userInfo.avatar;
    model.phone=[ConstantObject sharedConstant].userInfo.phone;
    model.email=[ConstantObject sharedConstant].userInfo.email;
    model.shotNum=[ConstantObject sharedConstant].userInfo.shortnum;
    
    //[roomMember insertObject:model atIndex:0];

    addIdArray=roomMember;
    if (self.addScrollType==AddScrollTypeCreatGroup || self.addScrollType==AddScrollTypeCreatGroupFromOneChat ||self.addScrollType==AddScrollTypeTransmit) {
        
        if (array_addId.count==1 && (self.addScrollType==AddScrollTypeCreatGroup || self.addScrollType==AddScrollTypeTransmit)) {
//           群聊id发送到其他页面
            [self.delegate_addID sendMassMessage:array_addId];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            return;
        }
        
        DDLogInfo(@"创建群时，人员数量%d",[addIdArray count]);
        if([addIdArray count]>200){
            UIAlertView *toomuch=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"群成员数量不能超过200" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [toomuch show];
            return ;
        }
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作确认" message:@"请输入群聊名称:" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        UITextField *alertTextField=[alert textFieldAtIndex:0];
        alertTextField.delegate=self;
        alertTextField.placeholder=@"最多30个字";
        [alert show];
    }else if (self.addScrollType==AddScrollTypeInvite ){
        [self addHUD:@"正在邀请联系人加入群聊"];
        QFXmppManager *xmppManager=[QFXmppManager shareInstance];
        XMPPRoom *room=[xmppManager.roomDict objectForKey:self.roomInfoModel.roomJid];
        
        if (!room) {
            [self hudWasHidden];
            [[ConstantObject app] showWithCustomView:nil detailText:@"邀请失败,请稍后重试" isCue:1 delayTime:1 isKeyShow:NO];
            return;
        }
        
        room.groupState=1;
        room.roomName=self.roomInfoModel.roomName;
        room.roomMemberList=self.roomInfoModel.roomMemberList;
        [xmppManager addMemberJidToRoom:room jids:array_addId compltion:^(BOOL ret) {
            [self hudWasHidden];
            if (ret) {
                
                NSMutableString *mutableMemberListStr=[[NSMutableString alloc] init];
                [mutableMemberListStr appendFormat:@"%@;",self.roomInfoModel.roomMemberListStr];
                for (EmployeeModel  *em in addIdArray) {
                    //                DDLogInfo(@"%@",[strt stringValue]);
                    NSString *imacc=em.imacct;
                    [mutableMemberListStr appendFormat:@"%@;",imacc];
                }
                
                NSMutableArray *memberList=[NSMutableArray arrayWithArray:self.roomInfoModel.roomMemberList];
                [memberList addObjectsFromArray:array_addId];
                
                NSString *memberListStr=[mutableMemberListStr substringToIndex:mutableMemberListStr.length-1];
                RoomInfoModel *roomInfo=[[RoomInfoModel alloc] init];
                roomInfo.roomName=room.roomName;
                roomInfo.roomJid=[room.roomJID.user deleteOpenFireName];
                roomInfo.roomMemberList=memberList;
                roomInfo.roomMemberListStr=memberListStr;
                [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:roomInfo];
                //发送创建群聊成功的消息
                [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.delegate_addID GetArrayID:roomInfo];
                }];
            }else{
                [[ConstantObject app] showWithCustomView:nil detailText:@"邀请失败,请稍后重试" isCue:1 delayTime:1 isKeyShow:NO];
            }
        }];
        
    }else if (self.addScrollType==AddScrollTypeSendMessage){
        //发送消息
        [self.delegate_addID sendMassMessage:array_addId];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }else if (self.addScrollType==AddScrollTypeCC || self.addScrollType==AddScrollTypeRecv){
      
        //[roomMember removeObjectAtIndex:0];
        [self.delegate_addID contactSelected:self.addScrollType member:roomMember];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
#pragma mark 任务流
    }else if (self.addScrollType == AddScrollTypeTask) {
        [self.delegate_addID GetTaskArray:array_addId];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else if (self.addScrollType == AddScrollTypeCreateConf)
    {
        [self.delegate_addID createConf:array_addId];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else if (self.addScrollType == AddScrollTypeCreateConfFromGroup)
    {
        [self.delegate_addID createConffromGroupChat:array_addId];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self.delegate_addID contactSelected:self.addScrollType member:roomMember];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            //取消
            DDLogInfo(@"取消");
            break;
        }
        case 1:
        {
            UITextField *alertTextField=[alertView textFieldAtIndex:0];
            
            NSString *str=alertTextField.text;
            str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
//            if (alertTextField.text.length>0) {
            if(str.length>0){
                [self addHUD:@"创建群聊"];
                
                if (self.addScrollType==AddScrollTypeCreatGroupFromOneChat) {
                    NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:addIdArray];
                    [tempArray addObject:self.empModel];
                    addIdArray=tempArray;
                }

                [[QFXmppManager shareInstance] creatRoomWithName:alertTextField.text jids:addIdArray compltion:^(BOOL ret,XMPPRoom *sender) {
                    [self hudWasHidden];
                    if (ret) {
                        //创建成功
                        sender.groupState=0;
                        
                        
                        /*
                        [[QFXmppManager shareInstance] addMemberJidToRoom:sender jids:addIdArray compltion:^(BOOL ret) {
                            
                        }];
                        */
                        NSMutableString *mutableMemberListStr=[[NSMutableString alloc] init];
                        [mutableMemberListStr appendFormat:@"%@;",[ConstantObject sharedConstant].userInfo.imacct];
                        for (EmployeeModel  *em in addIdArray) {
                            //                DDLogInfo(@"%@",[strt stringValue]);
                            NSString *imacc=em.imacct;
                            [mutableMemberListStr appendFormat:@"%@;",imacc];
                        }
                        NSString *memberListStr=[mutableMemberListStr substringToIndex:mutableMemberListStr.length-1];
                        RoomInfoModel *roomInfo=[[RoomInfoModel alloc] init];
                        roomInfo.roomName=alertTextField.text;
                        roomInfo.roomJid=[sender.roomJID.user deleteOpenFireName];
                        
                        
                        EmployeeModel * model=[[EmployeeModel alloc]init];
                        model.imacct=[ConstantObject sharedConstant].userInfo.imacct;
                        model.name=[ConstantObject sharedConstant].userInfo.name;
                        model.avatarimgurl=[ConstantObject sharedConstant].userInfo.avatar;
                        model.phone=[ConstantObject sharedConstant].userInfo.phone;
                        model.email=[ConstantObject sharedConstant].userInfo.email;
                        model.shotNum=[ConstantObject sharedConstant].userInfo.shortnum;
                        [addIdArray insertObject:model atIndex:0];

                        roomInfo.roomMemberList=addIdArray;
                        roomInfo.roomMemberListStr=memberListStr;
                        [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:roomInfo];

                        
                        [self dismissViewControllerAnimated:YES completion:^{
                            //发送创建群聊成功的消息
                            [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
                            
                            [self.delegate_addID GetArrayID:roomInfo];
                        }];
                    }else{
                        //创建失败

                        [[ConstantObject app] showWithCustomView:nil detailText:@"创建失败,请重试" isCue:1 delayTime:1 isKeyShow:NO];
                    }
                }];
                  DDLogInfo(@"创建");
            }else{
                [[ConstantObject app] showWithCustomView:nil detailText:@"不能使用空的主题" isCue:1 delayTime:1 isKeyShow:NO];
            }
      
            
            break;
        }
        default:
            break;
    }
}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    
    UITextField *alertTextField=[alertView textFieldAtIndex:0];
    if (alertTextField.text.length==0) {
        return NO;
    }
    if (alertTextField.text.length>alert_text_length_max) {
        return NO;
    }
    
    BOOL isExistName=[[SqliteDataDao sharedInstanse] isExistGroupWithName:alertTextField.text];
    if (isExistName) {
        alertView.message=[NSString stringWithFormat:@"⚠️已经存在%@",alertTextField.text];
        return NO;
    }else{
        alertView.message=@"请输入群聊名称:";
    }
    
    return YES;
}
#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
//    if (textField.text.length>alert_text_length_max) {
//        return YES;
//    }
//    
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (toBeString.length>alert_text_length_max) {
//        return NO;
//    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - hud
- (void)hudWasHidden{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}

-(void)addHUD:(NSString *)labelStr{
    
    
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    _HUD=[[MBProgressHUD alloc] initWithView:keyWindow];
    _HUD.dimBackground = YES;
    _HUD.labelText = labelStr;
    _HUD.userInteractionEnabled=YES;
    _HUD.removeFromSuperViewOnHide=YES;
    [self.view addSubview:_HUD];
    [_HUD show:YES];
}
@end
