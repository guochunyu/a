//
//  PersonInfoViewController.m
//  e企
//
//  Created by royaMAC on 14-11-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "MineOrgViewController.h"
#import "SqlAddressData.h"
#import "CreateHttpHeader.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "DepartmentLevelViewController.h"
#import "MainNavigationCT.h"

#define HEADHIGHT   10
#define FOOTHIGHT   0.5
#define CELLHIGHT   44
#define FirstHIGHT  60
#define CELL_CONTENT_WIDTH 290  //tableView行宽
#define DEFAULT_CELL_HEIGHT 44      //tableView默认行高
#define exit_alert_tag 20//退出登录
#define update_alert_tag 21//更新




@interface PersonInfoViewController ()<UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    MBProgressHUD *_progressHUD;    ///<指示器
    NSString *headStr;
    NSInteger reqTimes;
    UIImageView * headImg;
    UIImageView * bigImageView;
    UIView *overView ;
    AFHTTPRequestOperationManager *manager;
    //    UIButton *leftButton;
    UIImageView*imagev;
    UILabel*label;
}

@end

@implementation PersonInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //将个人中心标题隐藏
    //self.title = @"个人中心";
    reqTimes = 0;
    /*
     if (!IS_IOS_7) {
     //self.table.backgroundColor=[UIColor whiteColor];
     self.table.backgroundView=nil;
     }
     if (IS_IOS_7) {
     //self.table.sectionIndexBackgroundColor = [UIColor clearColor];
     self.table.sectionIndexColor = [UIColor grayColor];
     self.automaticallyAdjustsScrollViewInsets = YES;
     [self setExtendedLayoutIncludesOpaqueBars:YES];
     }
     */
    
    _table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _table.backgroundColor = UIColorFromRGB(0xebebeb);
    //    NSString *shortnum = [ConstantObject sharedConstant].userInfo.shortnum;
    //    if(shortnum.length == 0 || shortnum == nil) {
    //        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FirstHIGHT + 5*CELLHIGHT + 2*HEADHIGHT + 3*FOOTHIGHT) style:UITableViewStyleGrouped];
    //    }
    //else
    //    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FirstHIGHT + 6*CELLHIGHT + 2*HEADHIGHT + 3*FOOTHIGHT) style:UITableViewStyleGrouped];
    
    _table.delegate=self;
    _table.dataSource=self;
    _table.scrollEnabled = NO;
    _table.sectionFooterHeight = 1;
    [self.view addSubview:_table];
    
    [self quitMethod];
    
    //    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    _back = [[UIButton alloc]init];
    _back.frame = CGRectMake(0, 19, 80, 45);
    //[_back setBackgroundImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    //_back.backgroundColor = [UIColor lightGrayColor];
    [_back addTarget:self action:@selector(backff) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_back];
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 90, 20);
    label.text = @"个人中心";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:label];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}


-(void)backff{
    [self dismissViewControllerAnimated:NO completion:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    if (leftButton) {
    //        [self.navigationController.navigationBar addSubview:leftButton];
    //    }
    _back.hidden = NO;
    imagev.hidden = NO;
    label.hidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    if (leftButton) {
    //        [leftButton removeFromSuperview];
    //    }
    
}
#pragma mark----返回上一级页面
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    static float height=1.0;
    if (section==0) {
        height=10;
    }else{
        height=HEADHIGHT;
    }
    return height;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 2)
//    {
//        return 2;
//    }
//    return FOOTHIGHT;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return FirstHIGHT;
    else
        return CELLHIGHT;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger rows=0;
    if (section==0) {
        rows=1;
    }if(section==1)
    {
        rows = 2;
    }if (section == 2) {
        NSString *shortnum = [ConstantObject sharedConstant].userInfo.shortnum;
        if(shortnum.length == 0 || shortnum == nil) {
            rows = 2;
        }
        else
            rows = 3;
    }
    
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell * cell_person=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell_person==nil)
    {
        cell_person=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell_person.textLabel.font=[UIFont boldSystemFontOfSize:14];
        cell_person.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section==0) {
        //        cell_person.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell_person.textLabel.text=@"头像";
        cell_person.textLabel.font = size14;
        cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
        
        headImg=[[UIImageView alloc]initWithFrame:CGRectMake(cell_person.frame.size.width-60, 5 , 50, 50)];
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = headImg.frame.size.width * 0.5;
        NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
        EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
        //
        //        NSString * str=[ConstantObject sharedConstant].userInfo.avatar;
        NSURL * strUrl=[NSURL URLWithString:model.avatarimgurl];
        
        NSDictionary * dic=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
        DDLogInfo(@"dict=%@",dic);
        NSString * uid=[dic[@"data"] isKindOfClass:[NSDictionary class]]?(dic[@"data"][@"uid"]):@"";
        NSString * gid=[[NSUserDefaults standardUserDefaults]objectForKey:myGID];
        NSString * filename=[NSString stringWithFormat:@"/%@%@.image11.txt",uid,gid];
        NSArray *directoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [directoryPath objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingString:filename];
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:filePath];
        if (savedImage) {
            headImg.image = savedImage;
        [headImg setImageWithURL:strUrl placeholderImage:savedImage];
        }
        else{
            [headImg setImageWithURL:strUrl placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
        }
        //headImg.image=[UIImage imageNamed:@"address_icon_person"];
        [cell_person addSubview:headImg];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigHeadImg:)];
        headImg.userInteractionEnabled = YES;
        [headImg addGestureRecognizer:tap];
    }
    if (indexPath.section==1)
    {
        if (indexPath.row==0)
        {
            cell_person.textLabel.text=@"姓名";
            cell_person.detailTextLabel.text = [ConstantObject sharedConstant].userInfo.name;
            //            cell_person.textLabel.font = [UIFont systemFontOfSize:14];
            cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
            
        }if (indexPath.row==1) {
            cell_person.textLabel.text=@"部门及职位";
            //            cell_person.textLabel.font = [UIFont systemFontOfSize:14];
            cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
            cell_person.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            //            NSArray *duty = [ConstantObject sharedConstant].userInfo.duty;
            //            if([duty count] > 0)
            //            {
            //                cell_person.detailTextLabel.text = [duty objectAtIndex:0];
            //            }
        }
        //        if (indexPath.row==2) {
        //            cell_person.textLabel.text=@"部门";
        //            NSArray *department = [ConstantObject sharedConstant].userInfo.department;
        //            if([department count] > 0)
        //            {
        //                cell_person.detailTextLabel.text = [department objectAtIndex:0];
        //            }
        //        }
        
    }
    if(indexPath.section==2)
    {
        NSString *shortnum = [ConstantObject sharedConstant].userInfo.shortnum;
        if(shortnum == nil || shortnum.length == 0){
            if (indexPath.row==0) {
                cell_person.textLabel.text=@"手机";
                //                cell_person.textLabel.font = [UIFont systemFontOfSize:14];
                cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
                cell_person.detailTextLabel.text = [ConstantObject sharedConstant].userInfo.phone;
                
            }if (indexPath.row==1) {
                cell_person.textLabel.text=@"邮箱";
                //                cell_person.textLabel.font = [UIFont systemFontOfSize:14];
                cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
                cell_person.detailTextLabel.text = [ConstantObject sharedConstant].userInfo.email;
            }
        }
        else{
            
            if (indexPath.row==0) {
                cell_person.textLabel.text=@"短号";
                //                cell_person.textLabel.font = [UIFont systemFontOfSize:14];
                cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
                cell_person.detailTextLabel.text = shortnum;
                
            }if (indexPath.row==1) {
                cell_person.textLabel.text=@"手机";
                //                cell_person.textLabel.font = [UIFont systemFontOfSize:14];
                cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
                cell_person.detailTextLabel.text = [ConstantObject sharedConstant].userInfo.phone;
                
            }if (indexPath.row==2) {
                cell_person.textLabel.text=@"邮箱";
                //                cell_person.textLabel.font = [UIFont systemFontOfSize:14];
                cell_person.textLabel.textColor = UIColorFromRGB(0x333333);
                cell_person.detailTextLabel.text = [ConstantObject sharedConstant].userInfo.email;
                
            }
        }
        
    }
    
    [cell_person.textLabel setFont:size14];
    [cell_person.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    
    return cell_person;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        [self updateHeadImg];
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        DepartmentLevelViewController *departmentLevelVC = [[DepartmentLevelViewController alloc] initWithNibName:@"DepartmentLevelViewController"
                                                                                                           bundle:nil];
        _back.hidden = YES;
        imagev.hidden = YES;
        label.hidden = YES;
        departmentLevelVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:departmentLevelVC animated:YES];
    }
    
}

- (void)quitMethod
{
    UIView *viewQuit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [_table setTableFooterView:viewQuit];
    
    CGRect rectButton=CGRectMake((self.view.frame.size.width-CELL_CONTENT_WIDTH)/2, (100-DEFAULT_CELL_HEIGHT)/2, CELL_CONTENT_WIDTH, DEFAULT_CELL_HEIGHT);
    UIButton * quitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    quitBtn.frame=rectButton;
    quitBtn.tag=2001;
    [quitBtn setBackgroundColor:[UIColor colorWithRed:0.987 green:0.224 blue:0.273 alpha:1.000]];
    quitBtn.layer.cornerRadius=3;
    [quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [quitBtn addTarget:self action:@selector(quitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewQuit addSubview:quitBtn];
}

#pragma mark - UIAlertViewDelegate
-(void)quitButtonClick:(UIButton*)sender
{
    if (sender.tag==2001) {
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"退出后不会删除任何历史数据，下次登录仍然可以使用本账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出登录", nil];
        alertView.tag = exit_alert_tag;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
        case update_alert_tag:{
            
            UIView *overView_1 = [[UIView alloc]initWithFrame:self.view.window.frame];
            overView_1.backgroundColor = [UIColor colorWithHex:0xbebebe alpha:0.4];
            [self.view.window addSubview:overView_1];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.plistUrl]];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:HUD];
            HUD.labelText = @"正在更新...";
            [HUD show:YES];
            
            
            break;
        }
        case exit_alert_tag:{
            
            if (buttonIndex==0) {
                [alertView removeFromSuperview];
            }if (buttonIndex==1) {
                //关闭推送计数
                [[QFXmppManager shareInstance]closeMessageCount];
                
                //要把openfire下线
                [[QFXmppManager shareInstance] goOffline];
                //                   更新一次可见性表
                //                ContactsViewController * updateSee=[[ContactsViewController alloc]init];
                
                [SqlAddressData deleteLeadertable];
                [SqlAddressData deleteVisilityContact];
                //                [updateSee  requestAdressBookVisible];
                
                UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:keyWindow];
                [keyWindow addSubview:HUD];
                HUD.labelText = @"正在退出登录...";
                [HUD showAnimated:YES whileExecutingBlock:^{
                    
                    [[ConstantObject sharedConstant] releaseAllValue];
                    [[AFClient sharedClient] releaseAFClient];
                    [[SqliteDataDao sharedInstanse] releaseData];
                    [SqlAddressData releaseDataQueue];
                    [[QFXmppManager shareInstance] releaseXmppManager];

                    
                    
                    //       删除登录标识
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:[LOGIN_FLAG filePathOfCaches] error:nil];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:myPassWord];
                    //[[NSUserDefaults standardUserDefaults]removeObjectForKey:JSSIONID];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:MyUserInfo];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:MOBILEPHONE];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:myGID];
                    //                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:isSeeView];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    //                  退出登录把通知栏的未读消息数置为0
                    [self cancleApplicationNotification];
                    //该段会导致崩溃
//                    MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
//                    MainViewController *maivc = (MainViewController *)mainct.mainVC;
//                    [maivc.tabbarButt3 setRemindNum:0];
                   [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"未读个数"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                } completionBlock:^{
                    AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
                    app.mainVC.tabbarButt3.remindNum=0;
                    [app login];
                }];
            }
            break;
        }
        default:
            break;
            
    }
    
}

-(void)cancleApplicationNotification
{
    
    [ConstantObject app].unReadNum=0;
    
}

-(CGSize)lableSize:(NSString*)str
{
    CGSize size = [str boundingRectWithSize:CGSizeMake(167.0f, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size;
    return size;
}

-(void)showBigHeadImg:(UITapGestureRecognizer *)headerTap
{
    MJPhoto *photo = [[MJPhoto alloc] init];
    
    //   NSString * str=[ConstantObject sharedConstant].userInfo.avatar;
    NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
    EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
    NSString * str = model.avatarimgurl;
    str = [str stringByReplacingOccurrencesOfString:@"middle" withString:@"original"];
    str = [str stringByReplacingOccurrencesOfString:@"_original" withString:@""];
    if ([str length] > 0)
    {
        NSURL * strUrl = [NSURL URLWithString:str];
        photo.url = strUrl;
    }
    else
    {
        photo.image = [UIImage imageNamed:@""];
    }
    
    photo.srcImageView = (UIImageView *)headerTap.view;
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = [NSArray arrayWithObject:photo];
    [photoBroser show];
}


#pragma mark----更换头像
-(void)updateHeadImg
{
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [action showInView:self.view];
}


#pragma mark---打开摄像头的调用----打开相册调用统一方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        DDLogInfo(@"拍照");
        
        CustomImagePickerController *picker = [[CustomImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [picker setCustomDelegate:self];
            //  self.hidesBottomBarWhenPushed = YES;
        }else{
            // [picker setIsSingle:YES];
            //如果没有提示用户
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alert show];
        }
        
        [self presentViewController:picker animated:YES completion:^{
            self.hidesBottomBarWhenPushed = YES;
        }];
        
    }if (buttonIndex==1) {
        DDLogInfo(@"相册");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
        
    }if(buttonIndex == 3)
    {
        
    }
    
}
- (void)cameraPhoto:(UIImage *)image  //选择完图片
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    ImageFilterProcessViewController *fitler = [[ImageFilterProcessViewController alloc] init];
    [fitler setDelegate:self];
    fitler.currentImage = image;
    
    //[self presentModalViewController:fitler animated:YES];
    [self presentViewController:fitler animated:YES completion:nil];
    // [fitler release];
}

- (void)cancelCamera
{
    
}

- (void)imageFitlerProcessDone:(UIImage *)image //图片处理完
{
    UIImage * NewImage = [self imageWithImage:image scaledToSize:CGSizeMake(250,250)];
    [self uploadDataWithImage:NewImage];
    DDLogInfo(@"图片处理完");
}

#pragma mark---打开摄像头的调用
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //图片存入相册
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        if ([picker allowsEditing]) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if ([picker allowsEditing]) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];
        }
    }
    
    CGSize imageSize = image.size;
    imageSize.width = 250;
    imageSize.height = 250;
    
    
    image = [self imageWithImage:image scaledToSize:imageSize];
    [self uploadDataWithImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)useThePersoninfoImageChangeOther:(Myblock)myblock{
    self.myblock = myblock;
}

- (void)uploadDataWithImage:(UIImage *)image
{
    //初始化指示器
    
    if (!_progressHUD) {
        _progressHUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        _progressHUD.detailsLabelText=@"上传头像中...";
        _progressHUD.removeFromSuperViewOnHide=YES;
        
    }
    
    reqTimes ++;
    AFClient *client = [AFClient sharedClient];
    NSString *groupcode = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];
    [client setTimeoutInterval:30.0];
    [client postPath:[NSString stringWithFormat:@"eas/updateavatar?cid=%@&gid=%@&version=%@",cid,groupcode,nowVersion]parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>formData)
     {
         // NSData *imageData = UIImagePNGRepresentation(image);
         NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
         DDLogInfo(@"image data length%d",[imageData length]);
         //添加图片，并对其进行压缩（0.0为最大压缩率，1.0为最小压缩率）
         //        NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"test"], 1.0);
         //        image/jpeg
         [formData appendPartWithFileData:imageData name:@"file" fileName:@"test.png" mimeType:@"image/png"];
         //添加要上传的文件，此处为图片
         //        [formData appendPartWithFileData:imageData name:@"" fileName:@"图片名字" mimeType:@"image/png"];
         
     }success:^(AFHTTPRequestOperation *operation, id responseObject){
         [_progressHUD hide:YES];
         _progressHUD = nil;
         DDLogInfo(@"%@",responseObject);
         NSInteger status = [[responseObject objectForKey:@"status"]integerValue];
         NSString *msg = [NSString stringWithString:[responseObject objectForKey:@"msg"]];
         switch (status) {
             case 0:
             {
                 [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:msg isCue:1 delayTime:1 isKeyShow:NO];
                 
                 break;
             }
             case 1:
             {
                 [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:msg isCue:0 delayTime:1 isKeyShow:NO];
                 NSString *avatar = [[responseObject objectForKey:@"data"]objectForKey:@"middle_link"];
                 NSString *original = [[responseObject objectForKey:@"data"]objectForKey:@"original_link"];
                 
                 [ConstantObject sharedConstant].userInfo.avatar = avatar;
                 
                 //    [SqlAddressData updateCommenContactImage:avatar WithUserPhone:[ConstantObject sharedConstant].userInfo.phone];
                 
                 [SqlAddressData upDateAvatarimgurl:avatar WithUserPhone:[ConstantObject sharedConstant].userInfo.phone];
                 
                 
                 //   [SqlAddressData updateCommenContact:avatar];
                 headImg.image=image;
                 if (self.myblock) {
                     self.myblock(image);
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
                 
                 break;
                 
             }
             default:
                 break;
         }
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
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
                 
                 [self uploadDataWithImage:image];
                 
             }
         }else
         {
             [_progressHUD hide:YES];
             _progressHUD = nil;
             
             reqTimes = 0;
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"修改头像失败!" isCue:1 delayTime:1 isKeyShow:NO];
             
         }
         
         
     }];
    
}

//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)backGroundSingleTap
{
    [overView removeFromSuperview];
    //[overView removeFromSuperview];
}
#pragma mark - Navigation
/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
