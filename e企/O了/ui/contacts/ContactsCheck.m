//
//  ContactsCheck.m
//  e企
//
//  Created by shawn on 14/12/5.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ContactsCheck.h"
#import "CreateHttpHeader.h"

@implementation ContactsCheck{
    NSThread *checkThread;
    NSString *headStr;
    NSInteger reqtimes;
}

static ContactsCheck *_sharedInstance=nil;
//单例
+(ContactsCheck*) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ContactsCheck alloc] init];
    });
//    if (_sharedInstance == nil) {
//        _sharedInstance = [[ContactsCheck alloc] init];
//    }
    return _sharedInstance;
}

-(void)execute{
    reqtimes = 0;
    if (self.executeStatus == 0) {
        checkThread = [[NSThread alloc] initWithTarget:self selector:@selector(doExecute) object:nil];
        self.executeStatus = 1;
        [checkThread start];
    }
}

-(void)doExecute{
    if (![SqlAddressData queryContactIsNull]) {
        if(self.contactsCheckDelegate != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                [self.contactsCheckDelegate beginUpdate];
            });
        }
    }else{
        self.executeStatus = 2;
        if(self.contactsCheckDelegate != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                [self.contactsCheckDelegate endUpdate:NO];
            });
        }
    }
    
    reqtimes ++;
    AFClient * client=[AFClient sharedClient];
    NSString *gid = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];

    NSString * lastupdatetime=[[NSUserDefaults standardUserDefaults]objectForKey:LATESTUPDATETIME];
    
    if (![SqlAddressData queryContactIsNull]) {
        //如果表中没有数据,设置更新时间为0
        lastupdatetime=@"0";
    }

    NSDictionary * parameters=@{@"lastupdatetime":lastupdatetime?lastupdatetime:@"0"};
    //      修改
    [client getPath:[NSString stringWithFormat:@"eas/contact?gid=%@&cid=%@",gid,cid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [NSThread detachNewThreadSelector:@selector(executeDone:) toTarget:self withObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger stateCode = operation.response.statusCode;
        DDLogInfo(@"%d",stateCode);
        if(stateCode == 401  && reqtimes<=10)
        {
            NSDictionary *ddd=operation.response.allHeaderFields;
            if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                NSString *nonce=[ddd objectForKey:@"Www-Authenticate"];
                headStr = [CreateHttpHeader createHttpHeaderWithNoce:nonce];
                NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
                [client setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
                [self doExecute];
                
            }
        }else
        {
            reqtimes = 0;
            [self executeDone:nil];
            DDLogInfo(@"通讯录error==%@",operation.responseString);
        }

    }];
}

-(void)executeDone:(id)responseObject{
    BOOL update = NO;
    if(responseObject){
       
        NSDictionary *dic=[DataToDict dataToDict:responseObject];
        //DDLogInfo(@"-----------%@",dic);
       
        update=[dic[@"update"]boolValue];
        BOOL upload=[dic[@"upload"]boolValue];
        NSString *lastupdatetime=dic[@"latestUpdateTime"];
        [[NSUserDefaults standardUserDefaults]setObject:lastupdatetime forKey:LATESTUPDATETIME];
        [[NSUserDefaults standardUserDefaults]synchronize];
        if (update) {
            // upload字段是用来处理是否增量添加（false）或者批量增加（true）
            if (upload) {
//                DDLogInfo(@"%@",[NSDate date]);
                NSArray *dataArray=dic[@"contacts"];
                [SqlAddressData deleTableData];
                [SqlAddressData addContactsInfo:dataArray];
                [SqlAddressData addPersonInfo:dataArray];
                
                //联系人表中添加属性,已经优化在添加在添加联系人的时候添加
                //                    [SqlAddressData addContactOfAttribute];
                //                    [SqlAddressData updateContactNewAttribute];
                //插入完数据之后，需要添加数据库中表的属性
                //                    [SqlAddressData updateContactOfOrgName];
                //更新部门中父节点的属性
                [SqlAddressData updateBranchTable];
              
            }else{
                //               以增量的形式更新通讯录
                NSArray *dataArray=dic[@"contacts"];
                [SqlAddressData addContactsInfo:dataArray];
                [SqlAddressData addPersonInfo:dataArray];
            }
        }
        [self requestAdressBookVisible];

    }else{
        if(self.contactsCheckDelegate != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                [self.contactsCheckDelegate endUpdate:NO];
            });
        }
        self.executeStatus = 0;
    }
    
}


-(void)requestAdressBookVisible
{
    AFClient * client=[AFClient sharedClient];
    NSString * jssion=[[NSUserDefaults standardUserDefaults]objectForKey:JSSIONID];
    [client setHeaderValue:@"Cookie" headerKey:jssion];
    [client getPath:@"eas/visibility" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       [NSThread detachNewThreadSelector:@selector(updateAdressBookVisible:) toTarget:self withObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DDLogInfo(@"获取的通讯录可见性error===%@",operation.responseString);
        if(self.contactsCheckDelegate != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                [self.contactsCheckDelegate endUpdate:YES];
            });
        }
        self.executeStatus = 0;
    }];
}

-(void) updateAdressBookVisible:(id) responseObject{
//    DDLogInfo(@"2.51");
    NSMutableArray * sameOrg=[NSMutableArray arrayWithCapacity:0];

    NSDictionary *dic=[DataToDict dataToDict:responseObject];
//    DDLogInfo(@"通讯录可见性===%@",dic);
    NSDictionary * leaderVisibilityDic=dic[@"leaderVisibility"];
    BOOL leader_allVisibility=[leaderVisibilityDic[@"leaderVisibility"]boolValue];
    BOOL leader_phone=[leaderVisibilityDic[@"leaderPhoneVisibility"]boolValue];
    
    NSArray * personVisibilityArray=dic[@"personVisibility"];
    for (NSDictionary * personVisibility in personVisibilityArray) {
        
        VisibilityContactModel * model=[[VisibilityContactModel alloc]init];
        NSArray * visibilityListArrray=personVisibility[@"visibilityList"];
        //找到需要屏蔽掉的部门id，还需要确定是屏蔽这个部门的员工还是领导，或者都需要屏蔽掉
        if (visibilityListArrray.count==0) {
            NSArray * arrray=[SqlAddressData selectAllOrgID];
            for (int i=0; i<arrray.count; i++) {
                model.visibilityList_orgId=[NSString stringWithFormat:@"%@",[arrray objectAtIndex:i]];
                model.visibilityList_leadView=1;
                model.visibilityList_staffView=1;
                [SqlAddressData addNewVisibility:model];
            }
        }else{
            for (NSDictionary * orgIdDic in visibilityListArrray) {
                
                model.visibilityList_orgId=[NSString stringWithFormat:@"%@",orgIdDic[@"orgId"]];
                model.visibilityList_leadView=[orgIdDic[@"leadView"]boolValue];
                model.visibilityList_staffView=[orgIdDic[@"staffView"]boolValue];
                //  查询可见性表是否为空，yes不为空
                BOOL filterArray=[SqlAddressData queryVisibilityContact];
                if (filterArray) {
                    //  插入数据之前查询原来的表,有值说明存在相同部门的设置的屏蔽性
                    NSArray * see_array=[SqlAddressData selectNewVisibilityTable:model.visibilityList_orgId];
                    
                    if (see_array.count>0) {
                        VisibilityContactModel * model1=[see_array objectAtIndex:0];
                        NSString *see_orgId=model.visibilityList_orgId;
                        [sameOrg addObject:model.visibilityList_orgId];
                        //           如果数据进行的操作
                        model.visibilityList_leadView=(model1.visibilityList_leadView||model.visibilityList_leadView);
                        model.visibilityList_staffView=(model1.visibilityList_staffView||model.visibilityList_staffView);
                        [SqlAddressData deleteVisilityInfo:see_orgId];
                        [SqlAddressData addNewVisibility:model];
                        
                    }else{
                        [SqlAddressData addNewVisibility:model];
                    }
                }
                else{
                    [SqlAddressData addNewVisibility:model];
                }
            }
        }

    }
    VisibilityContactModel  * deleModel=[[VisibilityContactModel alloc]init];
    NSMutableArray * allVisiArray=[NSMutableArray arrayWithCapacity:0];
    NSArray * deleOrg=[SqlAddressData checkOutAll];
    for (int i=0; i<deleOrg.count; i++) {
        deleModel=[deleOrg objectAtIndex:i];
        [allVisiArray addObject:deleModel.visibilityList_orgId];
    }
    NSArray *differentArray=[[NSArray alloc]init];
    if (sameOrg.count>0) {
        //                  谓词删除不同数组中相同的元素
        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", sameOrg];
        differentArray= [allVisiArray filteredArrayUsingPredicate:thePredicate];
        DDLogInfo(@"不同的屏蔽部门===%d",differentArray.count);
    }
    //               删除不同的屏蔽部门
    for (int i=0; i<differentArray.count; i++) {
        NSString * not_see=[differentArray objectAtIndex:i];
        [SqlAddressData deleteVisilityInfo:not_see];
    }

        [SqlAddressData deleteLeadertable];
        //           在领导人可见性表中加数据
        [SqlAddressData addLeaderVisibilityLeader:leader_allVisibility leaderPhone:leader_phone];
//    }
    if(self.contactsCheckDelegate != nil){
        dispatch_async(dispatch_get_main_queue(),^{
            [self.contactsCheckDelegate endUpdate:YES];
        });
    }
    self.executeStatus = 0;
//     DDLogInfo(@"2.52");
}



@end
