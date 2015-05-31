//
//  NavigationVC_AddID.h
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addScrollView_messege.h"

#define alert_text_length_max 30///<弹出框上的textField最大长度

typedef enum {
    AddScrollTypeNomal,             //添加会议成员时用这个
    AddScrollTypeSmsInvitation,
    AddScrollTypeTask,        //任务流
    AddScrollTypeCreatGroup,///<创建群聊
    AddScrollTypeCreatGroupFromOneChat,///<从单聊创建群聊
    AddScrollTypeSendMessage,///<发送消息
    AddScrollTypeInvite,///<邀请
    AddScrollTypeTransmit,///<转发
    AddScrollTypeRecv,//发送邮件
    AddScrollTypeCC,  // 抄送
    AddScrollTypeCreateConf, //创建电话会议
    AddScrollTypeCreateConfFromGroup,   //从群聊创建电话会议
}AddScrollType;

@protocol navigation_addIDDelegaet <NSObject>
@optional
-(void)GetArrayID:(RoomInfoModel *)roomModel;

-(void)sendMassMessage:(NSArray *)memberArray;

-(void)contactSelected:(AddScrollType)type member:(NSArray *)memberArray;
#pragma mark 任务流
- (void)GetTaskArray:(NSArray *)memberArray;

-(void)createConf:(NSArray*)memberArray;

-(void)createConffromGroupChat:(NSArray*)memberArray;

@end

@interface NavigationVC_AddID : UINavigationController<addscrollViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>{
    addScrollView_messege *_addscroll;
    MBProgressHUD *_HUD;
}

@property (strong, nonatomic)NSMutableArray *Array_addedID;

@property(copy,nonatomic)NSString *addScrollOkButtTitle;

@property (weak, nonatomic) id<navigation_addIDDelegaet>delegate_addID;
@property (strong, nonatomic)NSString *str;

@property(nonatomic,assign)BOOL isSmsInvitation;

@property(nonatomic,assign)AddScrollType addScrollType;///<类型

@property(nonatomic,strong)NSMutableArray *memberArray;

@property(nonatomic,strong)NSArray *phoneArray;///<存放手机号,如果是房间里的人,显示灰色不可点
@property(nonatomic,strong)RoomInfoModel *roomInfoModel;///<房间对象

@property(nonatomic,strong)EmployeeModel *empModel;///<如果是从单聊创建回话,会传入这个属性

@property(nonatomic, strong)NSString* roomIdOfCreateConf;//创建会议的群id

#pragma mark - 选择一个群聊开始回话
-(void)selectOneRoom:(RoomInfoModel *)roomModel;
@end
