//
//  MessageChatViewController.m
//  O了
//
//  Created by 化召鹏 on 14-1-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "MessageChatViewController.h"
#import "RYMessageChatTag.h"
#import "VoiceConverter.h"
#import "CBG.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"
#import "VoIPViewController.h"
#import "MessageUserDetailViewController.h"
#import "CreateHttpHeader.h"
#import "BulletinModel.h"
#import "ContextDetilControllerViewController.h"
#define AnnounceType 123
#define inputTopMargin 7
#define inputHeight 30
#define inputMinu 14
#define onePageCount 10
#define contextType 4
@interface MessageChatViewController (){
    
    NSMutableArray *chatArray;
    int socketTag;
    RYAssetsPickerController * assetsPicker;
    AFURLConnectionOperation *sqliteOperation;
    MBProgressHUD * _hud;
    
    NSArray *_arrayMenu;            ///<服务号菜单
    CGFloat _widthForServiceNum;    ///<工具栏宽度 服务号
    NSInteger _subMenuTagCurrent;   ///<服务号子菜单的tag
    CGFloat _widthAddButt;          ///<消息工具栏“＋”按钮
    CGFloat _widthVoiceBtn;         ///<消息工具栏“声音”按钮
    
    NotesData *_selectNotesData;    //当前选择的数据
    int _selectIndex;               //当前选择数据的索引
    
    NSMutableString *head_number;
    
    NSString * lastTime;             //上一个显示消息的时间
    BOOL isDelet;
    
    NSMutableArray *imageUrlArray;//存放所有的图片url
    
    
    NSMutableDictionary *cellDict;///<存放cell
    NSMutableDictionary *selectCellDict;///<存放选中的cell
    
    UIView *multipleView;///<多选时的工具条
    
    UIView *bigView;///<双击显示的view
    
    AppDelegate *myApp;
    
    NSString *_toUserId;
    
    NSMutableArray *uuidArray;///<存放uuid uuid为消息唯一标示符
    
    UIButton *telButt;
    BOOL _original;             ///<YES发送原图，NO不发送
    BOOL _isPlay;///<yes 播放 no为未播放
    int dbPageIndex;//聊天记录分页请求 页面下标，从0开始
    NSDate * callsucceedTime;
    NSString *confPhone; //总机号
    NSString *confID;    //会议id
    UIView *voice_tip_view;
    
    
    NSString *headStr;
    NSInteger reqtimes;
    UIMyTextView *inputTextView;
}
-(void)downLoadCompleted:(NSDictionary *)dict;

@end

@implementation MessageChatViewController
@synthesize isService;
@synthesize player;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.tabBarController.tabBar.hidden = YES;
        
    }
    return self;
}
#pragma mark-
#pragma mark NotificationCenter

-(void)menuHide:(NSNotification *)notification{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:nil];
    [menu setMenuVisible:NO animated:NO];
}


-(void)keyboardShow:(NSNotification *)notification{
    //获取键盘的高度,随输入法的切换而改变
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    keyboadHeight=keyboardRect.size.height;
    
    
    //没有用到
    //    int numIos7=0;
    //    if (IS_IOS_7) {
    //        numIos7=0;
    //    }else{
    //        numIos7=0;
    //    }
    
    CGFloat duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    DDLogInfo(@"%d",keyboadHeight);
    UITextView *textView=(UITextView *)[self.view viewWithTag:text_input_tag];
    CGSize size =textView.frame.size;
    
    __block typeof(self) block_self=self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        //键盘隐藏,响应的view改变位置
        _chatTable.frame=CGRectMake(0, 0, 320, block_self.view.frame.size.height-_inputView.frame.size.height-keyboadHeight);
        
        if (size.height<=inputHeight) {
            inputTextView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin,225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, inputHeight);
            _inputView.frame=CGRectMake(0, self.view.frame.size.height-44-keyboadHeight, 320, 44);
        }else{
            if (size.height<100) {
                inputTextView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin,225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, size.height);
                _inputView.frame=CGRectMake(0, self.view.frame.size.height-inputMinu-size.height-keyboadHeight, 320,size.height+inputMinu);
            }else{
                inputTextView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin, 225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, 96);
                _inputView.frame=CGRectMake(0, self.view.frame.size.height-(96+inputMinu)-keyboadHeight, 320, 96+inputMinu);
            }
        }
        //滚动到最后一行。
        if ([chatArray count]>0) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0];
            [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }completion:^(BOOL finished) {
        
    }];
}
-(void)keyboardHid:(NSNotification *)notification{
    //没有用到
    //    int numIos7=0;
    //    if (IS_IOS_7) {
    //        numIos7=0;
    //    }else{
    //        numIos7=0;
    //    }
    UITextView *textView=(UITextView *)[self.view viewWithTag:text_input_tag];
    CGSize size =textView.frame.size;
    
    
    CGFloat duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    __block typeof(self) block_self=self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        //键盘隐藏,响应的view改变位置
        _chatTable.frame=CGRectMake(0, 0, 320, block_self.view.frame.size.height-44);
        if (size.height<100.0) {
            if (size.height<27) {
                textView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin, 225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, inputHeight);
                _inputView.frame=CGRectMake(0, block_self.view.frame.size.height-44, 320, 44);
            }else{
                textView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin,225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, size.height);
                _inputView.frame=CGRectMake(0, block_self.view.frame.size.height-inputMinu-size.height, 320, inputMinu+size.height);
            }
            
        }else{
            textView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin, 225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, 96);
            _inputView.frame=CGRectMake(0, block_self.view.frame.size.height-(96+inputMinu), 320, 96+inputMinu);
        }
    }completion:^(BOOL finished) {
        
    }];
}


#pragma mark - 通知回调方法
#pragma mark 群聊电话
-(void)groupcall
{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    
    MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainct.mainVC;
    if (maivc.isiOSInCall)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"正在通话中..." detailText:@"请结束通话后重试!" isCue:1.5 delayTime:3 isKeyShow:NO];
        DDLogWarn(@"current iPhone is on calling, can not create conf!");
        return;
    }
    
    nav_add.addScrollType = AddScrollTypeCreateConfFromGroup;
    nav_add.roomIdOfCreateConf = self.roomInfoModel.roomJid;
    // MessageViewController为root view controller
    nav_add.delegate_addID = self;
    [maivc presentViewController:nav_add animated:YES completion:^{
        
    }];
}

- (void)createConffromGroupChat:(NSArray *)memberArray
{
    NSString *caller = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
    NSString *callee = nil;
    
    DDLogInfo(@"当前呼叫数量%d",[memberArray count]);
    for ( EmployeeModel *member in memberArray )
    {
        if (nil == callee)
        {
            callee = member.phone;
        }
        else
        {
            callee = [callee stringByAppendingString:@";"];
            callee = [callee stringByAppendingString:member.phone];
        }
        
        
    }
    
    reqtimes ++;
    AFClient *client = [AFClient sharedClient];
    
    NSDictionary *dict=@{@"caller": caller,
                         @"callee": callee? callee : @""
                         };
    //    DDLogInfo(@"电话会议字典%@",dict);
    NSString *gid = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];
    [client postPath:[NSString stringWithFormat:@"eas/createConf?gid=%@&cid=%@",gid,cid]parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogInfo(@"电话会议回执%@",operation.responseString);
         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
         int status=[[dic objectForKey:@"status"] intValue];
         NSString *str=[dic objectForKey:@"msg"];
         
         if(status==1){
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:0 delayTime:1 isKeyShow:NO];
         }else{
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:1 delayTime:1 isKeyShow:NO];
         }
         
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
                 [self createConffromGroupChat:memberArray];
                 
             }
         }else
         {
             reqtimes = 0;
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"呼出失败，请稍后再试" isCue:1 delayTime:1 isKeyShow:NO];
         }
         
     }];
    
}
//-(void)createConf:(NSArray*)memberArray
//{
//    if(callsucceedTime){
//        float aaa=[[NSDate date] timeIntervalSinceDate:callsucceedTime];
//        if(aaa<20){
//            //[(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"创建会议已成功，请等待系统回拨" isCue:0 delayTime:1 isKeyShow:NO];
//            //return ;
//            [self addMemberJoinConf];
//        }
//    }else{
//        DDLogInfo(@"时间允许");
//    }
//
//    NSString *caller = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
//    NSString *callee = nil;
//    NSMutableArray *memberarray=[[NSMutableArray alloc]init];
//    RoomInfoModel *ttroomModel = [[SqliteDataDao sharedInstanse]getRoomInfoModelWithroomJid:self.roomInfoModel.roomJid];
//    DDLogInfo(@"当前呼叫数量%d",[ttroomModel.roomMemberList count]);
//    for ( EmployeeModel *member in ttroomModel.roomMemberList ) {
//        if ([member.phone isEqualToString:caller])
//        {
//            continue;
//        }
//        if (nil == callee)
//        {
//            callee = member.phone;
//        }
//        else
//        {
//            callee = [callee stringByAppendingString:@";"];
//            callee = [callee stringByAppendingString:member.phone];
//        }
//
//
//    }
//
////    UIAlertView *aaa=[UIAlertView alloc]initWithTitle:@"提醒" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    NSDictionary *dict=@{@"caller": caller,
//                         @"callee": callee? callee : @""
//                         };
////    DDLogInfo(@"电话会议字典%@",dict);
//    AFClient *client = [AFClient sharedClient];
//
//    [client postPath:[NSString stringWithFormat:@"eas/createConf"]parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         DDLogInfo(@"电话会议回执%@",operation.responseString);
//         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
//         int status=[[dic objectForKey:@"status"] intValue];
//         NSString *str=[dic objectForKey:@"msg"];
//
//         if(status==1){
//             callsucceedTime=[NSDate date];
//             confPhone = [dic objectForKey:@"phone"];
//             confID = [dic objectForKey:@"conferenceId"];
//             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:0 delayTime:1 isKeyShow:NO];
//         }else{
//             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:1 delayTime:1 isKeyShow:NO];
//         }
//
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"呼出失败，请稍后再试" isCue:1 delayTime:1 isKeyShow:NO];
//
//     }];
//}

//#pragma mark 添加电话会议人员
//- (void)addMemberJoinConf
//{
//    NSString *myPhone = [ConstantObject sharedConstant].userInfo.phone;
//    NSDictionary *dict=@{@"confId": confID,
//                         @"phone": confPhone,
//                         @"caller": myPhone,
//                         @"callee": [NSString stringWithFormat:@"%@;%@",@"18867101270",@"18867102003"]};
//    //    DDLogInfo(@"电话会议字典%@",dict);
//    AFClient *client = [AFClient sharedClient];
//
//    [client postPath:[NSString stringWithFormat:@"eas/joinConf"]parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         DDLogInfo(@"电话会议回执%@",operation.responseString);
//         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
//         int status=[[dic objectForKey:@"status"] intValue];
//         NSString *str=[dic objectForKey:@"msg"];
//
//         if(status==1){
//             callsucceedTime=[NSDate date];
//             confPhone = [dic objectForKey:@"phone"];
//             confID = [dic objectForKey:@"conferenceId"];
//             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:0 delayTime:1 isKeyShow:NO];
//         }else{
//             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:1 delayTime:1 isKeyShow:NO];
//         }
//
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"呼出失败，请稍后再试" isCue:1 delayTime:1 isKeyShow:NO];
//
//     }];
//
//}

#pragma mark -开启音视频会话

- (void)voiceCall
{
    [self callWithVideo:NO];
}

- (void)videoCall
{
    [self callWithVideo:YES];
}

- (void)callWithVideo:(BOOL)isVideo
{
    NSString *version = [NSString stringWithUTF8String:Zmf_GetVersion()];
    DDLogInfo(@"音视频SDK版本%@",version);
    
    if (![Reachability isNetWorkReachable])
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        return;
    }
    NSString *imacct = _member_userInfo.imacct;
    NSString *headImageurl = _member_userInfo.avatarimgurl;
    ZUINT callId = Mtc_Call((ZCHAR *)[imacct UTF8String], 0, ZTRUE, isVideo);
    VoIPViewController *callingViewController = [[VoIPViewController alloc] init];
    callingViewController.callId = callId;
    callingViewController.isVideo = isVideo;
    callingViewController.emodel = _member_userInfo;
    callingViewController.phoneNumber = _member_userInfo.phone;
    callingViewController.headImageUrl = headImageurl;
    callingViewController.isIncoming = NO;
    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDele.callState = CALLSTATE_CALLING;
    [self presentViewController:callingViewController animated:YES completion:nil];
}

#pragma mark 选择拍照
-(void)selectCameraWithPhoto{
    
    //选择拍照
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //从摄像头获取图片
        is_select_imagePicker=YES;
        //        UIImagePickerController * imagePicker
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
        
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = NO;
        //        imagePicker.showsCameraControls=NO;
        
        //       自定义拍照画面
        //        UIToolbar* tool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-55, self.view.frame.size.width, 75)];
        //        tool.barStyle = UIBarStyleBlackTranslucent;
        //        UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCamera)];
        //        [cancel setTitle:@"取消"];
        //
        //        UIBarButtonItem* add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePhoto)];
        //        [add setTitle:@"拍照"];
        //        [tool setItems:[NSArray arrayWithObjects:cancel,add, nil]];
        //        //把自定义的view设置到imagepickercontroller的overlay属性中
        
        //        imagePicker.cameraOverlayView = tool;
        MoreButton * bt = (MoreButton *)[self.view viewWithTag:butt_add_tag];
        bt.selected=NO;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"照相机不可用" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - 拍照发送 ####
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    NSString * str = info[UIImagePickerControllerMediaType];
    //视频
    if ([str isEqualToString:(NSString *)kUTTypeMovie]) {
        NSString * url = [[info[UIImagePickerControllerMediaURL] copy] absoluteString];
        [self encodeVideoWithUrl:[NSURL URLWithString:url]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else{//图片
        // Recover the snapped image
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize image_size=image.size;
        
        //屏幕尺寸
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        //分辨率
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        
        float scaling =(width*scale_screen)/image_size.width;
        
        UIImage *newImage=[image imageByScalingToSize:CGSizeMake(width*scale_screen, scaling*image_size.height)];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        //指定文件保存路径
        float iwidth=100;
        float iheight=120;
        if(image.size.width>image.size.height){
            //宽图
            iwidth=100;
            iheight=iwidth/image.size.width*image.size.height;
            if (iheight<20) {
                iheight=20;
            }
        }else{
            //长图
            iheight=120;
            iwidth=iheight/image.size.height*image.size.width;
            if(iwidth<20)
                iwidth=20;
        }
        //文件保存的URL
        CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        NSString *dataName=[NSString stringWithFormat:@"%@.jpg",cfuuidString];
        
        NSString *imagePath=[NSString stringWithFormat:@"%@%@",image_path,dataName];
        
        
        NSString *newFilePath=[imagePath filePathOfCaches];
        //判断目录是否存在，不存在则创建目录
        NSString *fileDictionary = [newFilePath stringByDeletingLastPathComponent];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:fileDictionary]) {
            [fileManager createDirectoryAtPath:fileDictionary withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSData *imageData=UIImageJPEGRepresentation(newImage, 0.1);
        
        if ([imageData writeToFile:newFilePath atomically:YES]) {
            imageData=nil;
            NSString *from_str = [NSString stringWithFormat:@"%@",[ConstantObject sharedConstant].userInfo.imacct];
            
            NSDate *date=[NSDate date];
            NSString *_time=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
            
            NotesData *nd=[[NotesData alloc] initWihtMessageUuid:cfuuidString content:nil fromUserName:[ConstantObject sharedConstant].userInfo.name fromUserId:from_str typeMessage:@"1" serverTime:_time middleLink:nil originalLink:nil smallLink:nil imageName:dataName imagePath:imagePath imageWidth:iwidth imageHeight:iheight];
            
            ActivituViewBg *activityBg=[[ActivituViewBg alloc] initWithGetActivityView:nd];
            activityBg.sendMessageAgain=^(NotesData *nd){
                [self sendMessageAgainWithNotesData:nd];
            };
            ChatView *v=[self getChatView:nd from:YES activityViewV:activityBg];
            DDLogInfo(@"插入contentUuid++++++++++++++++++++++++%@",v.nd.contentsUuid);
            [chatArray addObject:v];
            [_chatNotesDataArray addObject:nd];
            MessageModel *mm = [[MessageModel alloc] init];
            mm.chatType=self.chatType;
            mm.fileType=1;
            mm.messageID=cfuuidString;
            mm.receivedTime=_time;
            mm.msg =@" ";
            mm.from = [ConstantObject sharedConstant].userInfo.imacct;
            mm.to  = _toUserId;
            mm.thread=@"";
            
            mm.imageChatData=nd.imageCHatData;
            
            [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
            [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
            
            [self uploadImage:dataName imagePath:imagePath uuid:cfuuidString avtivtyView:activityBg noteData:nd];
            
            [self reloadChatTabel];
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"写入文件失败\n请重新尝试操作!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alert show];
        }
        
    }
    
    
}

#pragma mark-
#pragma mark viewDisappear
- (void)viewWillDisappear:(BOOL)animated{
    callsucceedTime=nil;
    [super viewWillDisappear:YES];
    if (!is_select_imagePicker) {
        if (player) {
            [player stop];
        }
    }
    
    if (_leftButt) {
        [_leftButt removeFromSuperview];
    }
    
    [_rightButt removeFromSuperview];
    [self hideNoNetworkView];
    if (telButt) {
        [telButt removeFromSuperview];
    }
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //键盘上去下午的通知 移除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 网络断开的定时器
-(void)noNetworkTimer:(id)sender{
    [self hideNoNetworkView];
}
//隐藏网络断开提醒
-(void)hideNoNetworkView{
    [noNetworkTimer invalidate];
    noNetworkTimer=nil;
    if(noNetworkView){
        [UIView animateWithDuration:0.5 animations:^{
            noNetworkView.frame=CGRectMake(20, -40, 280, 40);
            noNetworkViewLabel.frame=CGRectMake(20, -40, 280, 40);
        } completion:^(BOOL finished) {
            [noNetworkView removeFromSuperview];
            [noNetworkViewLabel removeFromSuperview];
        }];
        
    }
}
#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    socketTag=1;
    //声音状态
    _isReadFlag=[[NSMutableDictionary alloc]init];
    
    myApp=[ConstantObject app];
    myApp.showReceivedDelegate=self;
    
    //选择拍照
    head_number=[[NSMutableString alloc] initWithCapacity:0];
    
    if (!uuidArray) {
        uuidArray=[[NSMutableArray alloc] init];
    }
    //        self.navigationController.delegate=self;
#pragma mark 选择视频
    
    //视频播放器退出全屏通知 貌似以全屏模式初始化后，点击done，触发不了该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChange:) name: MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    //MPMoviePlayerPlaybackDidFinishNotification 视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name: MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    //UIMenuController消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    //数组初始化
    _imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing) name:@"hideBoardWhenMoreButtonClicked" object:nil];
    
    //声音下载完成
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceDownload:) name:shengyinxiazaiwancheng object:nil];
    NSString *titleStr;
    NSString *ssstr;
    if (self.chatType==1) {
        _toUserId=self.roomInfoModel.roomJid;
        ssstr=self.roomInfoModel.roomName;
        if (ssstr.length>10) {
            titleStr=[ssstr substringToIndex:8];
            titleStr=[NSString stringWithFormat:@"%@...",titleStr];
            self.title=titleStr;
        }else{
            self.title=self.roomInfoModel.roomName;
        }
    }else if (self.chatType==0){
        ssstr=self.member_userInfo.name;
        if (ssstr.length>8) {
            titleStr=[ssstr substringToIndex:6];
            titleStr=[NSString stringWithFormat:@"%@...",titleStr];
            self.title=titleStr;
        }else{
            self.title=self.member_userInfo.name;
        }
        _toUserId=self.member_userInfo.imacct;
    }else if(self.chatType==3){
        NSMutableString *imaccStr=[[NSMutableString alloc] init];
        NSMutableString *memberNameStr=[[NSMutableString alloc] init];
        
        for (EmployeeModel *emp in self.member_infoArray) {
            
            [imaccStr appendFormat:@"%@;",emp.imacct];
            
            [memberNameStr appendFormat:@"%@,",emp.name];
        }
        _toUserId=[imaccStr substringToIndex:imaccStr.length-1];
        NSString *titleStr;
        if (memberNameStr.length>13) {
            titleStr=[memberNameStr substringToIndex:13];
            if ([[titleStr substringFromIndex:titleStr.length-1] isEqualToString:@","]) {
                titleStr=[titleStr substringToIndex:titleStr.length-1];
                titleStr=[NSString stringWithFormat:@"%@...",titleStr];
            }else{
                titleStr=[NSString stringWithFormat:@"%@...",titleStr];
            }
        }else{
            titleStr=[memberNameStr substringToIndex:memberNameStr.length-1];
        }
        self.title=titleStr;
    }else if(self.chatType==4){
        _toUserId=@"EMS_BIZ_NOTIFY_PUSH";
        self.title=@"公告";
        
    }else if (self.chatType==5){
        _toUserId=@"EEC_DEVTEAM_NOTIFY_PUSH";
        self.title=@"和企录团队";
    }else if (self.chatType){
        self.title=self.publicModel.name;
        _toUserId=self.publicModel.pa_uuid;
    }
    
    //tableview内容数据
    imageUrlArray=[[NSMutableArray alloc] init];
    chatArray=[[NSMutableArray alloc] init];
    self.chatNotesDataArray=[[NSMutableArray alloc] init];
    dbPageIndex=0;
    if(self.chatType==4){
        NSArray *temp=[[NSArray alloc]initWithArray:[[SqliteDataDao sharedInstanse]queryBulletinDataWithlocation:0 length:onePageCount]];
        for(int i=0;i<temp.count;i++){
            BulletinModel *nd=[temp objectAtIndex:i];
            NotesData *ttt=[[NotesData alloc]init];
            ttt.typeMessage=@"4";
            ttt.BulletinModel=nd;
            ttt.serverTime=nd.receiveTime;
            ttt.sendContents=nd.bulletinID;
            ttt.contentsUuid=nd.bulletinID;
            [self.chatNotesDataArray insertObject:ttt atIndex:0];
        }
    }else{
        NSArray *temp=[[NSArray alloc]initWithArray:[[SqliteDataDao sharedInstanse]queryChatDataWithToUserId:_toUserId location:0 length:onePageCount]];
        for (NotesData *nd in temp) {
            [self.chatNotesDataArray insertObject:nd atIndex:0];
        }
    }
    
    
    
    //左侧按钮
    _leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
    _leftButt.frame=CGRectMake(0, 0, 100, 44);
    //        [_leftButt setTitle:@"返回" forState:UIControlStateNormal];
    //        [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    //        [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
    //为下级界面的返回按钮添加文字
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    //右侧按钮
    if (self.chatType!=3) {
        _rightButt=[UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButt setImage:[UIImage imageNamed:self.chatType==0?@"user-information.png":@"user-information-group.png"] forState:UIControlStateNormal];
        _rightButt.frame=CGRectMake(320-44-3, 0, 44, 44);
        [_rightButt addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.chatType==4||self.chatType==5) {
        //            [_rightButt setImage:[UIImage imageNamed:@"user-information.png"] forState:UIControlStateNormal];
        [_rightButt setHidden:YES];
    }
    
    if (self.chatType==0) {
        telButt=[UIButton buttonWithType:UIButtonTypeCustom];
        telButt.frame=CGRectMake(320-44-4-44, 0, 44, 44);
        [telButt addTarget:self action:@selector(telButt) forControlEvents:UIControlEventTouchUpInside];
        [telButt setImage:[UIImage imageNamed:@"telephone.png"] forState:UIControlStateNormal];
    }
    self.view.backgroundColor=bgcor3;
    
    //聊天气泡表格
    int chatTableIos=IS_IOS_7 ? 0 : 20;
    int inputheight;
    if(self.chatType==5||self.chatType==4){
        inputheight=0;
    }else{
        inputheight=44;
    }
    _chatTable=[[TouchTable alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-inputheight-64+chatTableIos-0) style:UITableViewStylePlain];
    _chatTable.delegate=self;
    _chatTable.dataSource=self;
    _chatTable.backgroundColor=[UIColor clearColor];
    _chatTable.backgroundView=nil;
    _chatTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    //        [_chatTable setSeparatorColor:[UIColor redColor]];
    //         [_chatTable setSeparatorInset:UIEdgeInsetsMake(0, 72, 0, 0)];
    _chatTable.touchDelegate=self;
    _chatTable.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_chatTable];
    
    
    
    if (!_headTableView) {
        _headTableView=[[UIView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
        _headTableView.backgroundColor=[UIColor clearColor];
        
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 20, 20, 20)];
        activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
        [activityView startAnimating];
        [_headTableView addSubview:activityView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 45, 200, 15)];
        label.textAlignment=NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font=[UIFont systemFontOfSize:12];
        label.textColor=cor3;
        label.text = @"加载数据";
        [_headTableView addSubview:label];
    }
    
    if (_headTableView.superview != _chatTable) {
        [_chatTable addSubview:_headTableView];
    }
    
    int numIos7=0;
    if (IS_IOS_7) {
        numIos7=64;
    }else{
        numIos7=44;
    }
    
    //输入框背景
    _inputView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44-numIos7, 320, 44)];
    _inputView.tag=inputText_tag;
    _inputView.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.view addSubview:_inputView];
    UIImageView *textinput_bcview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [textinput_bcview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textinput_bcview setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *img=[UIImage imageNamed:@"msg_input_bg.png"];
    UIImage *newImage=[img stretchableImageWithLeftCapWidth: 15  topCapHeight:10];
    textinput_bcview.image=newImage;
    //        [textinput_bcview setBackgroundColor:[UIColor colorWithPatternImage:newImage]];
    textinput_bcview.layer.cornerRadius=4;
    [_inputView addSubview:textinput_bcview];
    
    voice_tip_view=[[UIView alloc]initWithFrame:CGRectMake(320-132, self.view.bounds.size.height-44-numIos7-29, 128, 35)];
    [voice_tip_view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"voice_tip.png"]]];
    [self.view addSubview:voice_tip_view];
    [voice_tip_view setHidden:YES];
    
    
#pragma mark 服务号初始化
    _subMenuTagCurrent=0;
    _widthForServiceNum=0;
    //服务号
    if (1>2) {
        
        
        _widthForServiceNum=44;
        //button Message
        UIButton *buttonMessage=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonMessage.frame=CGRectMake(0, 0, _widthForServiceNum, _inputView.bounds.size.height);
        buttonMessage.highlighted=NO;
        [buttonMessage setImage:[UIImage imageNamed:@"chat_service_order.png"] forState:UIControlStateNormal];
        buttonMessage.tag=MessageChatTypeCommon;
        [buttonMessage addTarget:self action:@selector(butonSwithToolBar:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:buttonMessage];
        //工具栏 服务号视图
        _viewServiceNumber=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44-numIos7, 320, 44)];
        _viewServiceNumber.backgroundColor=[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
        [self.view addSubview:_viewServiceNumber];
        //button Service
        UIButton *buttonService=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonService.frame=CGRectMake(0, 0, _widthForServiceNum, _inputView.bounds.size.height);
        buttonService.highlighted=NO;
        [buttonService setImage:[UIImage imageNamed:@"chat_service_keyboard.png"] forState:UIControlStateNormal];
        buttonService.tag=MessageChatTypeServiceNumber;
        [buttonService addTarget:self action:@selector(butonSwithToolBar:) forControlEvents:UIControlEventTouchUpInside];
        [_viewServiceNumber addSubview:buttonService];
        //_viewServiceNumber设置
        long snCount=_arrayMenu.count;
        CGFloat widthSN=(_viewServiceNumber.bounds.size.width-_widthForServiceNum)/snCount;
        for (int i=0; i<snCount; i++) {
            UIButton *buttonSN=[UIButton buttonWithType:UIButtonTypeCustom];
            buttonSN.tag=SERVICE_MAINMENU_TAG_BASE+i;
            //imageview的tag标记的是菜单类别
            //titlelabel的tag标记的是一级菜单或是二级菜单的序号
            buttonSN.titleLabel.tag=SERVICE_MAINMENU_TAG_BASE;
            buttonSN.frame=CGRectMake(_widthForServiceNum+widthSN*i, 0, widthSN, _viewServiceNumber.bounds.size.height);
            [buttonSN setBackgroundImage:[UIImage imageNamed:@"chat_service_background.png"] forState:UIControlStateNormal];
            buttonSN.titleLabel.font=[UIFont systemFontOfSize:13];
            [buttonSN setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            buttonSN.contentEdgeInsets=UIEdgeInsetsMake(0, 5, 0, 5);
            [buttonSN addTarget:self action:@selector(buttonServiceMain:) forControlEvents:UIControlEventTouchUpInside];
            [_viewServiceNumber addSubview:buttonSN];
        }
        
        //_inputView设置
        _inputView.transform=CGAffineTransformTranslate(_inputView.transform, 0, _inputView.bounds.size.height);
        _inputView.hidden=YES;
    }
    
    _widthAddButt=0;
    _widthVoiceBtn=32;
    //为群发消息时，不显示“＋”按钮
    if (self.chatType!=3 &&self.chatType!=2){
        //加号按钮
        
        NSArray *titleArray;
        if(_roomInfoModel.roomJid){
            titleArray=@[@"拍照",@"图片",@"电话会议"];
        }
        else{
            if([_member_userInfo.imacct isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]){
                titleArray=@[@"拍照",@"图片"];
            }else{
                titleArray=@[@"拍照",@"图片",@"免费电话",@"视频聊天"];
            }
        }
        
        MoreButton *addButt=[[MoreButton alloc]initWithFrame:CGRectMake(2+_widthForServiceNum, 0, 44, 44) isgroup:_roomInfoModel.roomJid?YES:NO titleary:titleArray];
        [addButt setTranslatesAutoresizingMaskIntoConstraints:NO];
        [addButt setBackgroundImage:[UIImage imageNamed:@"chat_add.png"] forState:UIControlStateNormal];
        addButt.tag=butt_add_tag;
        [addButt addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:addButt];
        [_inputView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:addButt
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_inputView
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1
                                   constant:0]];
        [_inputView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:addButt
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_inputView
                                   attribute:NSLayoutAttributeLeft
                                   multiplier:1
                                   constant:2+_widthForServiceNum]];
        //声音按钮
        //            UIButton *voiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
        ButtonAudioRecorder *voiceButton=[ButtonAudioRecorder buttonWithType:UIButtonTypeCustom];
        voiceButton.delegate=self;
        voiceButton.frame=CGRectMake(320-44, 0, 44, 44);
        [voiceButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_Sound-Onp.png"] forState:UIControlStateNormal];
        //            [voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_keybord.png"] forState:UIControlStateSelected];
        voiceButton.tag=butt_voice_tag;
        [voiceButton addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:voiceButton];
        
        [_inputView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:voiceButton
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_inputView
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1
                                   constant:0]];
        [_inputView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:voiceButton
                                   attribute:NSLayoutAttributeRight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_inputView
                                   attribute:NSLayoutAttributeRight
                                   multiplier:1
                                   constant:0]];
        _widthAddButt=32;
        _widthVoiceBtn=0;
        
    }
    
    //        if (self.chatType==3) {
    //            _widthAddButt=32;
    //            _widthVoiceBtn=0;
    //        }
    inputTextView=[[UIMyTextView alloc] initWithFrame:CGRectMake(48+_widthForServiceNum-_widthVoiceBtn, inputTopMargin, 225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, inputHeight)];
    inputTextView.layer.cornerRadius=4;
    inputTextView.returnKeyType=UIReturnKeySend;
    inputTextView.tag=text_input_tag;
    //        inputTextView.scrollEnabled = NO;
    inputTextView.font=[UIFont systemFontOfSize:14];
    //        inputTextView.backgroundColor=[UIColor blueColor];
    inputTextView.text=[[SqliteDataDao sharedInstanse]queryTempstrWithtoUserId:_toUserId];
    [[SqliteDataDao sharedInstanse] deleteTempstr:_toUserId];
    
    if(inputTextView.text.length>0){
        
        UILabel *ttlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, inputTextView.frame.size.height)];
        ttlabel.font=[UIFont systemFontOfSize:14];
        ttlabel.lineBreakMode = NSLineBreakByWordWrapping;
        ttlabel.numberOfLines = 0;//上面两行设置多行显示
        ttlabel.text=inputTextView.text;
        [ttlabel sizeToFit];
        inputTextView.frame=CGRectMake(inputTextView.frame.origin.x, inputTextView.frame.origin.y, ttlabel.frame.size.width, ttlabel.frame.size.height);
        [inputTextView becomeFirstResponder];
    }
    //        inputView.canBecomeFirstResponder=YES;
    inputTextView.delegate=self;
    
    [inputTextView scrollRectToVisible:CGRectMake(0, inputTextView.contentSize.height-15, inputTextView.contentSize.width, 10) animated:NO];
    //添加到录音按钮的下面
    UIView *audioButton=[self.view viewWithTag:butt_voice_tag];
    if (audioButton!=nil) {
        [_inputView insertSubview:inputTextView belowSubview:audioButton];
    }else{
        [_inputView addSubview:inputTextView];
    }
    [_inputView addSubview:inputTextView];
    [_inputView addConstraint:[NSLayoutConstraint
                               constraintWithItem:textinput_bcview
                               attribute:NSLayoutAttributeBottom
                               relatedBy:NSLayoutRelationEqual
                               toItem:inputTextView
                               attribute:NSLayoutAttributeBottom
                               multiplier:1
                               constant:2]];
    [_inputView addConstraint:[NSLayoutConstraint
                               constraintWithItem:textinput_bcview
                               attribute:NSLayoutAttributeRight
                               relatedBy:NSLayoutRelationEqual
                               toItem:inputTextView
                               attribute:NSLayoutAttributeRight
                               multiplier:1
                               constant:32]];
    [_inputView addConstraint:[NSLayoutConstraint
                               constraintWithItem:textinput_bcview
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:inputTextView
                               attribute:NSLayoutAttributeTop
                               multiplier:1
                               constant:-2]];
    [_inputView addConstraint:[NSLayoutConstraint
                               constraintWithItem:textinput_bcview
                               attribute:NSLayoutAttributeLeft
                               relatedBy:NSLayoutRelationEqual
                               toItem:inputTextView
                               attribute:NSLayoutAttributeLeft
                               multiplier:1
                               constant:-2]];
    
    //表情按钮
    FaceButton *biaoqingButt=[FaceButton buttonWithType:UIButtonTypeCustom];
    biaoqingButt.frame=CGRectMake(320-44-3*2-_widthAddButt, 0, 44, 44);
    biaoqingButt.tag=butt_face_tag;
    biaoqingButt.delegate=self;
    [biaoqingButt setTranslatesAutoresizingMaskIntoConstraints:NO];
    [biaoqingButt addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
    [biaoqingButt setBackgroundImage:[UIImage imageNamed:@"chat_smile.png"] forState:UIControlStateNormal];
    [biaoqingButt setBackgroundImage:[UIImage imageNamed:@"chat_keybord.png"] forState:UIControlStateSelected];
    [_inputView addSubview:biaoqingButt];
    
    [_inputView addConstraint:[NSLayoutConstraint
                               constraintWithItem:biaoqingButt
                               attribute:NSLayoutAttributeBottom
                               relatedBy:NSLayoutRelationEqual
                               toItem:_inputView
                               attribute:NSLayoutAttributeBottom
                               multiplier:1
                               constant:0]];
    [_inputView addConstraint:[NSLayoutConstraint
                               constraintWithItem:biaoqingButt
                               attribute:NSLayoutAttributeRight
                               relatedBy:NSLayoutRelationEqual
                               toItem:_inputView
                               attribute:NSLayoutAttributeRight
                               multiplier:1
                               constant:-48]];
    __block typeof(self) mySelf=self;
    biaoqingButt.faceClick=^(id sender){
        //            [mySelf textChanged:nil];
        [mySelf textViewDidChange:inputTextView];
    };
    
    
    if (self.messageChatType==MessageChatTypePublicCountHistory) {
        _inputView.hidden=YES;
        CGRect rect=_chatTable.frame;
        rect.size.height=_chatTable.frame.size.height+_inputView.frame.size.height;
        _chatTable.frame=rect;
        _rightButt.hidden=YES;
        [self.chatNotesDataArray removeAllObjects];
        [self.chatNotesDataArray addObjectsFromArray:self.historyArray];
        [self loadNotesData];
        myApp.showReceivedDelegate=nil;
        return;
    }
    if(self.chatType==4||self.chatType==5){
        _inputView.hidden=YES;
    }
    [self loadNotesData];
    if (self.isTranmist) {
        if (self.tranmistMessageArray.count>0) {
            for (NotesData *tranmistNd in self.tranmistMessageArray) {
                
                [self sendMessage:nil messageType:tranmistNd.typeMessage message:tranmistNd.sendContents withNotesData:tranmistNd];
            }
            self.isTranmist=NO;
        }
    }
}

-(void)deleteSelectedFile:(id)sender{
    if ([sender isMemberOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer * longGesture = (UILongPressGestureRecognizer *)sender;
        CGPoint p = [longGesture locationInView:_chatTable];
        NSIndexPath * indexPath = [_chatTable indexPathForRowAtPoint:p];
        UITableViewCell * cell = [_chatTable cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            if ((p.y > (cell.frame.origin.y + cell.frame.size.height))) {
                return;
            }
        }
        if(longGesture.state == UIGestureRecognizerStateBegan){
            
        }
    }
}

#pragma mark-
#pragma mark 从数据库加载数据
-(void)loadNotesData{
    [chatArray removeAllObjects];
    for (NotesData *nd in self.chatNotesDataArray) {
        if(self.chatType!=4){
            @try {
                [uuidArray addObject:nd.contentsUuid];
            }
            @catch (NSException *exception) {
                DDLogInfo(@"uuid为空");
            }
            @finally {
                
            }
        }
        
        if ([nd.typeMessage isEqualToString:@"1"]) {
            [imageUrlArray addObject:nd];
        }
        BOOL isSelf=NO;
        
        if ([nd.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct] && nd.contentsUuid.length>0) {
            //自己给自己发消息
            
            NSString *str=[nd.contentsUuid substringToIndex:4];
            if ([str isEqualToString:@"self"]) {
                isSelf=NO;
            }else{
                isSelf=YES;
            }
        }else{
            if ([nd.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
                isSelf=YES;
            }else{
                isSelf=NO;
            }
            
        }
        
        ChatView *v=nil;
        v=[self getChatView:nd from:isSelf activityViewV:nil];
        if (!v) {
            continue;
        }
        [chatArray addObject:v];
        [_chatTable reloadData];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0];
        [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    //    else{
    //        for (BulletinModel *nd in self.chatNotesDataArray) {
    //
    //            if ([nd.typeMessage isEqualToString:@"1"]) {
    //                [imageUrlArray addObject:nd];
    //            }
    //            BOOL isSelf=NO;
    //
    //            if ([nd.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct] && nd.contentsUuid.length>0) {
    //                //自己给自己发消息
    //
    //                NSString *str=[nd.contentsUuid substringToIndex:4];
    //                if ([str isEqualToString:@"self"]) {
    //                    isSelf=NO;
    //                }else{
    //                    isSelf=YES;
    //                }
    //            }else{
    //                if ([nd.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
    //                    isSelf=YES;
    //                }else{
    //                    isSelf=NO;
    //                }
    //
    //            }
    //
    //            ChatView *v=nil;
    //            v=[self getChatView:nd from:isSelf activityViewV:nil];
    //            if (!v) {
    //                continue;
    //            }
    //            [chatArray addObject:v];
    //            [_chatTable reloadData];
    //
    //            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0];
    //            [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //        }
    //    }
}
-(void)insertChat:(NSMutableArray *)source withArray:(NSArray *)temparray{
    int insertcount=0;
    lastTime=nil;
    NSMutableArray *temp=[[NSMutableArray alloc]init];
    for (NotesData *nd in temparray) {
        if(insertcount>=onePageCount){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timeStr=nd.serverTime;
            NSDate * theDate = [dateFormatter dateFromString:timeStr];
            NSString * messageTime=[dateFormatter stringFromDate:theDate];
            lastTime=messageTime;
            break;
        }
        [source insertObject:nd atIndex:0];
        insertcount++;
    }
    for(int i=0;i<insertcount;i++){
        NotesData *nd=[source objectAtIndex:i];
        if(self.chatType!=4){
            @try {
                [uuidArray addObject:nd.contentsUuid];
            }
            @catch (NSException *exception) {
                DDLogInfo(@"uuid为空");
            }
            @finally {
                
            }
        }
        if ([nd.typeMessage isEqualToString:@"1"]) {
            [imageUrlArray addObject:nd];
        }
        BOOL isSelf=NO;
        if ([nd.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct] && nd.contentsUuid.length>0) {
            //自己给自己发消息
            
            NSString *str=[nd.contentsUuid substringToIndex:4];
            if ([str isEqualToString:@"self"]) {
                isSelf=NO;
            }else{
                isSelf=YES;
            }
        }else{
            if ([nd.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
                isSelf=YES;
            }else{
                isSelf=NO;
            }
        }
        ChatView *v=nil;
        //准备插入聊天记录，先判断是否要生成时间cell
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr=nd.serverTime;
        NSDate * theDate = [dateFormatter dateFromString:timeStr];
        NSDate * lastDate=nil;
        NSTimeInterval timeDifference;
        if (lastTime!=nil) {
            lastDate = [dateFormatter dateFromString:lastTime];
            timeDifference=[theDate timeIntervalSinceDate:lastDate];
        }
        ChatView *timeView;
        if (lastTime==nil || timeDifference>60*5){
            //为空或者为60*5就显示时间
            NSString * messageTime=[dateFormatter stringFromDate:theDate];
            lastTime=messageTime;
            timeView=[self timeView:messageTime];
            timeView.nd=nd;
            [temp addObject:timeView];
        }
        v=[self getChatViewonly:nd from:isSelf activityViewV:nil];
        if (!v) {
            continue;
        }
        [temp addObject:v];
    }
    [chatArray insertObjects:temp atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [temp count])]];
    [_chatTable reloadData];
}
#pragma mark- 收到消息
//收到消息
-(void)showReceivedMsgByOwnerType:(MessageModel *)mm{
    
    if(mm.isOffline)
    {
        DDLogInfo(@"离线 " );
        if(self.chatType==4){
            [[SqliteDataDao sharedInstanse] updateReadStateWithToUserId:_toUserId];
            [self.chatNotesDataArray removeAllObjects];
            [chatArray removeAllObjects];
            NSArray *temp=[[NSArray alloc]initWithArray:[[SqliteDataDao sharedInstanse]queryBulletinDataWithlocation:0 length:onePageCount]];
            for(int i=0;i<temp.count;i++){
                BulletinModel *nd=[temp objectAtIndex:i];
                DDLogCInfo(@"%@",nd);
                NotesData *ttt=[[NotesData alloc]init];
                ttt.typeMessage=@"4";
                ttt.BulletinModel=nd;
                ttt.serverTime=nd.receiveTime;
                ttt.sendContents=nd.bulletinID;
                ttt.contentsUuid=nd.bulletinID;
                [self.chatNotesDataArray insertObject:ttt atIndex:0];
            }
        }else{
            [[SqliteDataDao sharedInstanse] updateReadStateWithToUserId:_toUserId];
            [self.chatNotesDataArray removeAllObjects];
            NSMutableArray *temp=[[NSMutableArray alloc]initWithArray:[[SqliteDataDao sharedInstanse]queryChatDataWithToUserId:_toUserId location:0 length:onePageCount]];
            [chatArray removeAllObjects];
            [self insertChat:self.chatNotesDataArray withArray:temp];
        }
        return;
    }
    
    if (![mm.to isEqualToString:_toUserId]) {
        //如果不是自己的消息,忽略
        return;
    }
    
    if ([uuidArray containsObject:mm.messageID]) {
        DDLogInfo(@" 有中断");
        return;
    }
    
    NotesData * notesData=[[NotesData alloc] init];
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    long long int dateTime=(long long int) nowTime;
    
    notesData.contentsUuid=mm.messageID;
    
    [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
    if(self.chatType==4){
        BulletinModel *nd=[[SqliteDataDao sharedInstanse]queryBulletinDataWithBuID:mm.messageID];
        notesData.typeMessage=@"4";
        notesData.BulletinModel=nd;
        notesData.serverTime=nd.receiveTime;
        notesData.sendContents=nd.bulletinID;
        //            notesData.contentsUuid=nd.bulletinID;
    }else if(self.chatType==5){
        notesData.sendContents=mm.msg;
        notesData.fromUserName=mm.from;
        notesData.fromUserId=mm.from;
        notesData.teamMsgModel=mm.teamMsgModel;
        notesData.typeMessage=[NSString stringWithFormat:@"%d",mm.fileType];
        if([notesData.typeMessage isEqualToString:@"1"]){
            ImageChatData *icd=[[ImageChatData alloc] init];
            icd.middleLink=mm.teamMsgModel.notify_picUrl;
            icd.originalLink=mm.teamMsgModel.notify_picUrl;
            icd.smallLink=mm.teamMsgModel.notify_picUrl;
            icd.imageName=@"";
            icd.imagePath=@"";
            icd.imagewidth=[mm.teamMsgModel.with_pic floatValue];
            icd.imageheight=[mm.teamMsgModel.height_pic floatValue];
            mm.imageChatData=icd;
        }
    }else{
        notesData.sendContents=mm.msg;
        notesData.fromUserName=mm.from;
        notesData.fromUserId=mm.from;
        notesData.typeMessage=[NSString stringWithFormat:@"%d",mm.fileType];
    }
    switch (mm.fileType) {
        case 0:
        {
            break;
        }
        case 1:
        {
            notesData.imageCHatData=mm.imageChatData;
            [imageUrlArray addObject:notesData];
            break;
        }
        case 2:
        {
            notesData.chatVoiceData=mm.chatVoiceData;
            break;
        }
        case 4:
        {
            notesData.chatVideoModel=mm.chatVideoModel;
            break;
        }
        default:
            break;
    }
    
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString=[dateFormatter stringFromDate:time];
    notesData.serverTime=destDateString;
    
    ChatView *v=nil;
    if([mm.from isEqualToString:[ConstantObject sharedConstant].userInfo.imacct])
    {
        v=[self getChatView:notesData from:YES activityViewV:nil];
    }else
    {
        v=[self getChatView:notesData from:NO activityViewV:nil];
    }
    if (!v) {
        return;
    }
    
    [chatArray addObject:v];
    [_chatNotesDataArray addObject:notesData];
    
    [self reloadChatTabel];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
}

-(void)reloadChatTabel{
    float scrollflag=YES;
    if((_chatTable.contentOffset.y+750)<_chatTable.contentSize.height){
        scrollflag=NO;
    }
    [_chatTable reloadData];
    if(self.chatType==4||scrollflag){
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0];
        [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - 下载文件
-(void)downVideoWithPath:(NSString *)path fileUrl:(NSURL *)url type:(int)type{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *file_path=path;
    
    //从网络下载
    //判断目录是否存在不存在则创建
    NSString *pathDirectories = [[file_path filePathOfCaches] stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:pathDirectories]) {
        [fileManager createDirectoryAtPath:pathDirectories withIntermediateDirectories:YES attributes:nil error:nil];
    }
    AFHTTPRequestOperation *down_operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
    
    //添加下载请求（获取服务器的输出流）
    down_operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[file_path filePathOfCaches] append:NO];
    
    MBProgressHUD *HUD;
    HUD=[[MBProgressHUD alloc] initWithView:self.view];
    HUD.removeFromSuperViewOnHide=YES;
    HUD.mode=MBProgressHUDModeDeterminateHorizontalBar;
    HUD.dimBackground = YES;
    HUD.labelText=@"正在下载视频文件";
    [self.view bringSubviewToFront:HUD];
    [self.view addSubview:HUD];
    [HUD show:YES];
    
    //设置下载进度条
    [down_operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        //显示下载进度
        CGFloat progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        HUD.detailsLabelText=[NSString stringWithFormat:@"%.2f%%",progress * 100];
        HUD.progress=progress;
        if (progress == 1) {
            [HUD hide:YES];
        }
        
    }];
    
    //请求管理判断请求结果
    [down_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //请求成功
        NSURL * fileUrl = [NSURL fileURLWithPath:[file_path filePathOfCaches] isDirectory:NO];
        [self playVideo:fileUrl];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //请求失败
        [HUD hide:YES];
        
        MBProgressHUD *errorHud=[[MBProgressHUD alloc] initWithView:self.view];
        errorHud.labelText=@"下载失败,请重试";
        errorHud.mode=MBProgressHUDModeText;
        [errorHud hide:YES afterDelay:1];
        DDLogInfo(@"Error: %@",error);
    }];
    [down_operation start];
}
#pragma mark - 收到声音文件并且下载完成
-(void)voiceDownload:(NSNotification *)notification{
    
}


-(void)downLoadCompleted:(NSDictionary *)dict{
    
}
#pragma mark - notification 点击视频或图片按钮的通知
-(void)endEditing{
    [self.view endEditing:YES];
}
#pragma mark 选择本地相册
-(void)presentRYAssetsPicker{
    
    is_select_imagePicker=YES;
    MoreButton * bt = (MoreButton *)[self.view viewWithTag:butt_add_tag];
    bt.selected=NO;
    [bt endEditing:YES];
    RYAssetsPickerController * rpc ;
    rpc = [[RYAssetsPickerController alloc]initPhotosPicker];
    rpc.delegate = self;
    [self presentViewController:rpc animated:YES completion:nil];
}

#pragma mark - notification 视频播放结束通知
-(void)exitFullScreen:(NSNotification *)nfc{
    int reason = [[[nfc userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason) {
        case MPMovieFinishReasonPlaybackEnded:
            DDLogInfo(@"视频播放结束");
            break;
        case MPMovieFinishReasonPlaybackError:
            DDLogInfo(@"出现异常");
            [self.moviePlayer.view removeFromSuperview];
            break;
            //点击done退出
        case MPMovieFinishReasonUserExited:
            [self.moviePlayer stop];
            [self.moviePlayer.view removeFromSuperview];
            break;
        default:
            break;
    }
}

#pragma mark - notification 视频回放状态改变通知
-(void)playbackStateChange:(NSNotification *)nfc{
    
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStateSeekingForward:
            DDLogInfo(@"前进");
            [[LogRecord sharedWriteLog] writeLog:@"聊天视频播放,前进"];
            break;
        case MPMoviePlaybackStateSeekingBackward:
            DDLogInfo(@"后退");
            [[LogRecord sharedWriteLog] writeLog:@"聊天视频播放,后退"];
            break;
        case MPMoviePlaybackStateStopped:
            DDLogInfo(@"停止");
            [[LogRecord sharedWriteLog] writeLog:@"聊天视频播放,停止"];
            [self.moviePlayer stop];
            [self.moviePlayer.view removeFromSuperview];
            break;
        case MPMoviePlaybackStatePlaying:
            DDLogInfo(@"播放");
            [[LogRecord sharedWriteLog] writeLog:@"聊天视频播放,播放"];
            break;
        case MPMoviePlaybackStatePaused:
            DDLogInfo(@"暂停");
            [[LogRecord sharedWriteLog] writeLog:@"聊天视频播放,暂停"];
            break;
        case MPMoviePlaybackStateInterrupted:
            DDLogInfo(@"中断");
            [[LogRecord sharedWriteLog] writeLog:@"聊天视频播放,中断"];
            [self.moviePlayer stop];
            [self.moviePlayer.view removeFromSuperview];
            break;
        default:
            DDLogInfo(@"播放出现异常，当前状态：%d",self.moviePlayer.playbackState);
            break;
    }
}

#pragma mark - 上传图片

-(void)uploadImage:(NSString *)imageName imagePath:(NSString *)path uuid:(NSString *)cfuuidString avtivtyView:(ActivituViewBg *)activityBg noteData:(NotesData *)nd{
    
    [imageUrlArray addObject:nd];
    NSData *imageData=[NSData dataWithContentsOfFile:[path filePathOfCaches]];
    
    UIImage *testImage = [UIImage imageWithData: imageData];
    float iwidth=100;
    float iheight=120;
    if(testImage.size.width>testImage.size.height){
        //宽图
        iwidth=100;
        iheight=iwidth/testImage.size.width*testImage.size.height;
        if (iheight<20) {
            iheight=20;
        }
    }else{
        //长图
        iheight=120;
        iwidth=iheight/testImage.size.height*testImage.size.width;
        if(iwidth<20)
            iwidth=20;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:file_update_url parameters:@{@"newimagetype":@"0",@"fileName":imageName} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:imageName fileName:imageName mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *resultDict=[DataToDict dataToDict:responseObject];
        
        NSDictionary *_dict=@{key_messageImage_image_name: imageName,
                              key_messageImage_middle_link:resultDict[@"middle_link"],
                              key_messageImage_original_link:resultDict[@"original_link"],
                              key_messageImage_small_link:resultDict[@"small_link"],
                              key_messageImage_image_width:[NSString stringWithFormat:@"%d",(int)iwidth],
                              key_messageImage_image_height:[NSString stringWithFormat:@"%d",(int)iheight]};
        nd.imageCHatData.middleLink=resultDict[@"middle_link"];
        nd.imageCHatData.originalLink=resultDict[@"original_link"];
        nd.imageCHatData.smallLink=resultDict[@"small_link"];
        nd.imageCHatData.imagewidth=(int)iwidth;
        nd.imageCHatData.imageheight=(int)iheight;
        [[SqliteDataDao sharedInstanse] updateImageChatDataWithMessageId:nd.contentsUuid imageChatData:nd.imageCHatData];
        [[QFXmppManager shareInstance] sendMessage:_dict chatType:self.chatType withType:1 toUser:_toUserId messageId:cfuuidString withCompletion:^(BOOL ret, NSString *siID) {
            //            DDLogInfo(@"回调源头 %@ #### %@",siID,activityBg.nd.contentsUuid);
            if (ret) {
                DDLogInfo(@"发送图片成功");
                [activityBg sendsucceed];
                
            }else{
                DDLogInfo(@"发送图片失败");
                //把请求下来的值带上,再次发送的时候如果有这个数据就是,图片上传成功,但是消息没有发出去
                [activityBg addFailView:nd];
                activityBg.sendMessageAgain=^(NotesData *nd){
                    [self sendMessageAgainWithNotesData:nd];
                };
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //图片发送失败,
        [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:cfuuidString state:@"2"];
        [activityBg addFailView:nd];
        activityBg.sendMessageAgain=^(NotesData *nd){
            [self sendMessageAgainWithNotesData:nd];
        };
        //请求失败
        DDLogInfo(@"Error: %@", error);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:nil];
}

#pragma mark - delegate 视频或图片资源选择器完成选择后操作代理 ####

#pragma mark -发送图片时，消息处理
- (void)assetsPicker:(RYAssetsPickerController *)ap didFinishPickingMediaWithInfo:(NSArray *)info{
    NSString * fileName;
    NSData * videoData;
    NSString *isOriginal;
    //如果是图片资源
    
    if(ap.AssetType == RYAssetsPickerAssetPhoto){
        
        //        NSMutableArray *tempArray=[[NSMutableArray alloc] initWithCapacity:0];
        [_imageArray removeAllObjects];
        for (int i = 0;i<[info count];i++) {
            
            NSDictionary *dic=[info objectAtIndex:i];
            
            //指定文件保存路径
            
            //判断目录是否存在，不存在则创建目录
            CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
            NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
            
            //文件保存的URL
            
            NSString *dataName=[NSString stringWithFormat:@"%@.jpg",cfuuidString];
            
            NSString *imagePath=[NSString stringWithFormat:@"%@%@",image_path,dataName];
            NSString *newFilePath=[imagePath filePathOfCaches];
            
            NSString *fileDictionary = [newFilePath stringByDeletingLastPathComponent];
            NSFileManager *fileManager=[NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:fileDictionary]) {
                [fileManager createDirectoryAtPath:fileDictionary withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //判断是否是原图
            isOriginal = dic[AssetsPickerImageIsOriginl];
            
            NSData *imageData;
            
            if ([isOriginal isEqualToString:@"1"]) {
                imageData=UIImageJPEGRepresentation(dic[AssetsPickerImageOriginal], 1);
            }else if ([isOriginal isEqualToString:@"0"]){
                imageData=UIImageJPEGRepresentation(dic[AssetsPickerImageFullScreen], 1);
            }
            
            if ([imageData writeToFile:newFilePath atomically:YES]) {
                
                NSString *from_str = [NSString stringWithFormat:@"%@",[ConstantObject sharedConstant].userInfo.imacct];
                
                NSDate *date=[NSDate date];
                NSString *_time=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                UIImage *testImage = [UIImage imageWithData: imageData];
                float iwidth=100;
                float iheight=120;
                if(testImage.size.width>testImage.size.height){
                    //宽图
                    iwidth=100;
                    iheight=iwidth/testImage.size.width*testImage.size.height;
                    if (iheight<20) {
                        iheight=20;
                    }
                }else{
                    //长图
                    iheight=120;
                    iwidth=iheight/testImage.size.height*testImage.size.width;
                    if(iwidth<20)
                        iwidth=20;
                }
                NotesData *nd=[[NotesData alloc] initWihtMessageUuid:cfuuidString content:nil fromUserName:[ConstantObject sharedConstant].userInfo.name fromUserId:from_str typeMessage:@"1" serverTime:_time middleLink:nil originalLink:nil smallLink:nil imageName:dataName imagePath:imagePath imageWidth:iwidth imageHeight:iheight];
                
                ActivituViewBg *activityBg=[[ActivituViewBg alloc] initWithGetActivityView:nd];
                activityBg.sendMessageAgain=^(NotesData *nd){
                    [self sendMessageAgainWithNotesData:nd];
                };
                ChatView *v=[self getChatView:nd from:YES activityViewV:activityBg];
                
                [chatArray addObject:v];
                [_chatNotesDataArray addObject:nd];
                MessageModel *mm = [[MessageModel alloc] init];
                mm.chatType=self.chatType;
                mm.fileType=1;
                mm.messageID=cfuuidString;
                mm.receivedTime=_time;
                mm.msg =@" ";
                mm.from = [ConstantObject sharedConstant].userInfo.imacct;
                mm.to  = _toUserId;
                mm.thread=@"";
                
                mm.imageChatData=nd.imageCHatData;
                
                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
                
                [self uploadImage:dataName imagePath:imagePath uuid:cfuuidString avtivtyView:activityBg noteData:nd];
                
                
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"写入文件失败\n请重新尝试操作!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                
                [alert show];
            }
            
            
        }
        [self reloadChatTabel];
    }else if(ap.AssetType == RYAssetsPickerAssetVideo){
        //视频资源一次只包含一个
        NSDictionary * dic = info[0];
        fileName = [dic valueForKey:AssetsPickerMediaName];
        NSURL * url = [dic valueForKey:AssetsPickerVedioCompress];
        videoData = [NSData dataWithContentsOfURL:url];
        //        CGFloat videoLength = [VideoUtil getTimeWithURL:url];
        
    }
    
    
}

#pragma mark -


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
    
    self.tabBarController.tabBar.hidden = YES;
    if (_leftButt) {
        [self.navigationController.navigationBar addSubview:_leftButt];
    }
    
    [self.navigationController.navigationBar addSubview:_rightButt];
    
    if (telButt) {
        [self.navigationController.navigationBar addSubview:telButt];
    }
    
    //键盘上去下午的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHid:) name:UIKeyboardWillHideNotification object:nil];
    reqtimes = 0;
    is_select_imagePicker=NO;
    
    DDLogInfo(@"当前数量%d %d",[chatArray count],[_chatNotesDataArray count]);
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    is_select_imagePicker=NO;
}

-(void)viewDidUnload{
    
    [super viewDidUnload];
    //置为空
    _leftButt=nil;
    _rightButt=nil;
    socketTag=1;
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectCameraWithPhoto" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"chooseButtonOfMore" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideBoardWhenMoreButtonClicked" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:shengyinxiazaiwancheng object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    
}
#pragma mark - 上传资源后在聊天页面的后续操作
-(void)showNotesDataInChatViewAfterUpLoadTheAssets:(NSDictionary *)assets {
    
}
#pragma mark - 左右返回按钮
-(void)leftButtItemClick{
    UITextView *textView=(UITextView *)[self.view viewWithTag:text_input_tag];
    NSString *str=textView.text;
    str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(str.length>0){
        [[SqliteDataDao sharedInstanse] insertTempstr:_toUserId tempstr:textView.text];
    }
    
    if (isEdite) {
        
        [self hideMyltipleView];
        [selectCellDict removeAllObjects];
        return;
    }
    
    if ([player isPlaying]) {
        [player stop];
    }
    
    self.chatMemberArray=nil;
    myApp.showReceivedDelegate=nil;
    if (bigView) {
        bigView=nil;
    }
    if (self.chatType==2 || self.isFromGroupList || self.isNoToRootViewWhenBack) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)rightBarButtonClick{
    
    
    if (self.chatType==0) {
        
        MessageUserDetailViewController *userDetailVC=[[MessageUserDetailViewController alloc] init];
        userDetailVC.userInfo=self.member_userInfo;
        userDetailVC.hidesBottomBarWhenPushed=YES;
        userDetailVC.detailType=1;
        userDetailVC.clearChatData=^(){
            [chatArray removeAllObjects];
            [self.chatNotesDataArray removeAllObjects];
            lastTime=nil;
            [_chatTable reloadData];
        };
        [self.navigationController pushViewController:userDetailVC animated:YES];
        
    }else if (self.chatType==1){
        MessageGroupChatSetViewController *groupChatSetVC=[[MessageGroupChatSetViewController alloc] init];
        
        RoomInfoModel *roomModel = [[SqliteDataDao sharedInstanse]getRoomInfoModelWithroomJid:self.roomInfoModel.roomJid];
        self.roomInfoModel = roomModel;
        
        groupChatSetVC.imacc = [ConstantObject sharedConstant].userInfo.imacct;
        groupChatSetVC.chatType=self.chatType;
        groupChatSetVC.roomInfoModel=self.roomInfoModel;
        groupChatSetVC.hidesBottomBarWhenPushed=YES;
        groupChatSetVC.clearChatData=^(){
            [chatArray removeAllObjects];
            [self.chatNotesDataArray removeAllObjects];
            lastTime=nil;
            [_chatTable reloadData];
        };
        [self.navigationController pushViewController:groupChatSetVC animated:YES];
    }else if (self.chatType==2){
        ServiceNumberDetailViewController *detailVC=[[ServiceNumberDetailViewController alloc] init];
        detailVC.publicaccontModel=self.publicModel;
        detailVC.hidesBottomBarWhenPushed=YES;
        detailVC.subscribestatusType=1;
        detailVC.isFromMessage=YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}
-(void)telButt{
    if ((self.member_userInfo.tele.length == 0 || self.member_userInfo.tele == nil) && (self.member_userInfo.shotNum.length == 0 || self.member_userInfo.shotNum == nil)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.phone]]];
    }
    else if  ((self.member_userInfo.tele.length == 0 || self.member_userInfo.tele == nil) && (self.member_userInfo.shotNum.length != 0 || self.member_userInfo.shotNum != nil)){
        NSString * shortNumber = self.member_userInfo.shotNum;
        NSString * shortNumberStr = [NSString stringWithFormat:@"短号 %@",shortNumber];
        NSString * telePhone = self.member_userInfo.phone;
        NSString * telePhoneStr = [NSString stringWithFormat:@"手机 %@",telePhone];
        
        UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:telePhoneStr otherButtonTitles:shortNumberStr, nil];
        actionSheet.tag=actionSheet_Notele;
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    else if  ((self.member_userInfo.tele.length != 0 || self.member_userInfo.tele != nil) && (self.member_userInfo.shotNum.length == 0 || self.member_userInfo.shotNum == nil)){
        NSString * teleNumber = self.member_userInfo.tele;
        NSString * teleNumberStr = [NSString stringWithFormat:@"固话 %@",teleNumber];
        NSString * telePhone = self.member_userInfo.phone;
        NSString * telePhoneStr = [NSString stringWithFormat:@"手机 %@",telePhone];
        
        UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:telePhoneStr otherButtonTitles:teleNumberStr, nil];
        actionSheet.tag=actionSheet_NoshortNum;
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    else if  ((self.member_userInfo.tele.length != 0 || self.member_userInfo.tele != nil) && (self.member_userInfo.shotNum.length != 0 || self.member_userInfo.shotNum != nil)){
        NSString * teleNumber = self.member_userInfo.tele;
        NSString * teleNumberStr = [NSString stringWithFormat:@"固话 %@",teleNumber];
        NSString * shortNumber = self.member_userInfo.shotNum;
        NSString * shortNumberStr = [NSString stringWithFormat:@"短号 %@",shortNumber];
        NSString * telePhone = self.member_userInfo.phone;
        NSString * telePhoneStr = [NSString stringWithFormat:@"手机 %@",telePhone];
        
        UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:telePhoneStr otherButtonTitles:teleNumberStr,shortNumberStr, nil];
        actionSheet.tag=actionSheet_AllNumber;
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
        
    }
    //    if (self.member_userInfo.phone.length>0) {
    
    //    }
}
#pragma mark - 自定义的三个按钮的点击事件(声音、表情、加号)
CGRect textFrame;//记录输入框的frame
CGRect inputFrame;//记录inputView的frame
-(void)buttClick:(id)sender{
    UIButton *button=(UIButton *)sender;
    switch (button.tag) {
        case butt_face_tag:{
            UIMyTextView *t=(UIMyTextView *)[self.view viewWithTag:text_input_tag];
            FaceButton *butt=(FaceButton *)sender;
            butt.selected=!butt.selected;
            if(butt.selected){
                butt.inputTextView=t;
                [butt becomeFirstResponder];
            }else{
                [t becomeFirstResponder];
            }
            ButtonAudioRecorder *audioButt=(ButtonAudioRecorder *)[self.view viewWithTag:butt_make_voice_tag];
            
            
            audioButt.alpha=0;
            [voice_tip_view setHidden:YES];
            
            UIButton *voiceButton=(UIButton *)[self.view viewWithTag:butt_voice_tag];
            if (voiceButton.selected) {
                [voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_Sound-Onp.png"] forState:UIControlStateNormal];
                voiceButton.selected=!voiceButton.selected;
            }
            MoreButton *moreButt=(MoreButton *)[self.view viewWithTag:butt_add_tag];
            if (moreButt.selected) {
                [moreButt setBackgroundImage:[UIImage imageNamed:@"chat_add"] forState:UIControlStateNormal];
                moreButt.selected=!moreButt.selected;
            }
            break;
        }
        case butt_add_tag:{
            MoreButton *butt=(MoreButton *)sender;
            butt.selected=!butt.selected;
            UITextView *t=(UITextView *)[self.view viewWithTag:text_input_tag];
            if(butt.selected){
                butt.inputTextView=t;
                butt.inputView.delegate = self;
                [butt becomeFirstResponder];
            }else{
                [t becomeFirstResponder];
            }
            ButtonAudioRecorder *audioButt=(ButtonAudioRecorder *)[self.view viewWithTag:butt_make_voice_tag];
            
            UIButton *voiceButton=(UIButton *)[self.view viewWithTag:butt_voice_tag];
            if (voiceButton.selected) {
                [voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_Sound-Onp.png"] forState:UIControlStateNormal];
                voiceButton.selected=!voiceButton.selected;
            }
            FaceButton *faceButt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
            if (faceButt.selected) {
                [faceButt setBackgroundImage:[UIImage imageNamed:@"chat_smile"] forState:UIControlStateNormal];
                faceButt.selected=!faceButt.selected;
            }
            butt.inputView.moreButtClick=^(MoreButtType type){
                switch (type) {
                    case MoreButtTypePhoto:
                    {
                        [self presentRYAssetsPicker];
                        break;
                    }
                    case MoreButtTypeCamera:
                    {
                        [self selectCameraWithPhoto];
                        break;
                    }
                    case MoreButtTypeCall:{
                        [self groupcall];
                        break;
                    }
                    case MoreButtTypeVoice:{
                        DDLogInfo(@"单聊语音");
                        [self voiceCall];
                        break;
                    }
                    case MoreButtTypeVideo:{
                        DDLogInfo(@"单聊视频");
                        [self videoCall];
                        break;
                    }
                    default:
                        break;
                }
            };
            
            audioButt.alpha=0;
            [voice_tip_view setHidden:YES];
            
            break;
        }
        case butt_voice_tag:{
            break;
            [self.view endEditing:YES];
            button.selected=!button.selected;
            UITextView *t=(UITextView *)[self.view viewWithTag:text_input_tag];
            
            ButtonAudioRecorder *audioButt=(ButtonAudioRecorder *)[self.view viewWithTag:butt_make_voice_tag];
            if (button.selected) {
                audioButt.alpha=1;
                textFrame=t.frame;
                inputFrame=_inputView.frame;
                int numIos7=0;
                if (IS_IOS_7) {
                    numIos7=64;
                }else{
                    numIos7=44;
                }
                t.frame=CGRectMake(0, self.view.bounds.size.height-44-numIos7, 320, 44);
                _inputView.frame=CGRectMake(0, self.view.frame.size.height-44, 320, 10+34);
            }else{
                audioButt.alpha=0;
                [voice_tip_view setHidden:YES];
                
                [t becomeFirstResponder];
            }
            
            FaceButton *butt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
            if (butt.selected) {
                [butt setBackgroundImage:[UIImage imageNamed:@"chat_smile"] forState:UIControlStateNormal];
                butt.selected=!butt.selected;
            }
            
            break;
        }
            
        default:
            break;
    }
}
#pragma mark 为服务号时，工具条切换显示
- (void)butonSwithToolBar:(UIButton *)sender
{
    //移除子菜单
    [self removeSubmenu];
    [self.view endEditing:YES];
    UIView *currentViewHide=_inputView;
    UIView *currentViewShow=_viewServiceNumber;
    if (sender.tag==MessageChatTypeCommon) {
        UIView *viewTem=currentViewHide;
        currentViewHide=currentViewShow;
        currentViewShow=viewTem;
    }
    CGFloat duration=0.15;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        currentViewShow.transform=CGAffineTransformTranslate(currentViewShow.transform, 0, currentViewShow.frame.size.height);
        currentViewHide.hidden=NO;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            currentViewShow.hidden=YES;
            currentViewHide.transform=CGAffineTransformTranslate(currentViewHide.transform, 0, -currentViewHide.frame.size.height);
        } completion:nil];
    }];
}
#pragma mark 服务号菜单按钮
- (void)buttonServiceMain:(UIButton *)sender
{
    
}
#pragma mark 移除子菜单view
- (void)removeSubmenu
{
    if (_subMenuTagCurrent!=0) {
        UIView *viewSub=[self.view viewWithTag:_subMenuTagCurrent];
        [UIView animateWithDuration:SERVICE_SUBMENU_ANM_DUR animations:^{
            viewSub.transform=CGAffineTransformTranslate(viewSub.transform, 0, viewSub.bounds.size.height+2);
        } completion:^(BOOL finished) {
            [viewSub removeFromSuperview];
            _subMenuTagCurrent=0;
        }];
    }
}
#pragma mark - delegate 录制视频
-(void)selectCamera:(CameraType)type{
    is_select_imagePicker=YES;
    DDLogInfo(@"录制视频");
    [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"录制视频"]];
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if (availableMedia.count > 1) {
        imagePicker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePicker.videoMaximumDuration = 30;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        DDLogInfo(@"不支持");
    }
}
-(void)encodeVideoWithUrl:(NSURL *)url{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    [[LogRecord sharedWriteLog] writeLog:@"压缩视频"];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"正在压缩。。。";
        _hud.removeFromSuperViewOnHide = YES;
        [_hud show:YES];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        
        NSString * fileName = [NSString stringWithFormat:@"output%@.mp4",cfuuidString];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * fileDoc = [@"andron_video" filePathOfCaches];
        if (![fileManager fileExistsAtPath:fileDoc]) {
            [fileManager createDirectoryAtPath:fileDoc withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString * mp4Path = [[NSString stringWithFormat:@"/andron_video/%@",fileName] filePathOfCaches];
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:mp4Path,@"filePath",fileName,AssetsPickerMediaName, nil];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    _hud.labelText = @"转码失败";
                    [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"视频转码失败"]];
                    [_hud hide:YES afterDelay:1];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    DDLogInfo(@"Export canceled");
                    _hud.labelText = @"转码取消";
                    [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"视频转码取消"]];
                    [_hud hide:YES afterDelay:1];
                    break;
                case AVAssetExportSessionStatusCompleted:
                    DDLogInfo(@"Successful!");
                    [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"视频转码成功"]];
                    [self performSelectorOnMainThread:@selector(convertFinish:) withObject:dict waitUntilDone:YES];
                    break;
                default:
                    break;
            }
            
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)convertFinish:(NSDictionary *)dict{
    NSString * mp4Path = [dict valueForKey:@"filePath"];
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = @"转码成功";
    [_hud hide:YES afterDelay:1];
    CGFloat mp4Time = [VideoUtil getTimeWithURL:[NSURL URLWithString:[@"file://" stringByAppendingString:mp4Path]]];
    NSData * data = [NSData dataWithContentsOfFile:mp4Path];
    
    NSMutableDictionary * videoDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [videoDict setValue:[NSNumber numberWithFloat:mp4Time] forKey:@"videoLength"];
    [videoDict setValue:data forKey:@"videoData"];
    
    NSArray * tempArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[dict valueForKey:AssetsPickerMediaName] forKey:AssetsPickerMediaName]];
    NSDictionary *tempDict=[[NSDictionary alloc] initWithObjectsAndKeys:[dict valueForKey:AssetsPickerMediaName],@"fileName",@"5",@"type",tempArray,@"imageArray",videoDict,@"videoDict",nil];
    [self showNotesDataInChatViewAfterUpLoadTheAssets:tempDict];
}

#pragma mark --------------------------录制声音
//由ButtonAudioRecorder录制完语音后回调，进行语音的上传及发送
- (void)buttonAudioRecorder:(ButtonAudioRecorder *)audioRecorder didFinishRcordWithAudioInfo:(NSDictionary *)audioInfo sendFlag:(BOOL)flag{
    [[LogRecord sharedWriteLog] writeLog:@"录制声音"];
    if (flag) {
        
        NSString *fileName=audioInfo[AudioRecorderName];
        //声音
        NSString *filePath=audioInfo[AudioRecorderPath];
        
        NSString *voiceLenth=audioInfo[AudioRecorderDuration];
        //        NSData *voiceData=[NSData dataWithContentsOfFile:[filePath filePathOfCaches]];
        
        NSDate *date=[NSDate date];
        NSString *_time=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        
        NotesData *nd=[[NotesData alloc] initWihtMessageUuid:[fileName stringByDeletingPathExtension] content:@"" fromUserName:[ConstantObject sharedConstant].userInfo.name fromUserId:[ConstantObject sharedConstant].userInfo.imacct typeMessage:@"2" serverTime:_time voicePath:filePath voiceUrl:@"" voiceLength:voiceLenth voiceName:fileName];
        ActivituViewBg *activityBg=[[ActivituViewBg alloc] initWithGetActivityView:nd];
        activityBg.sendMessageAgain=^(NotesData *nd){
            [self sendMessageAgainWithNotesData:nd];
        };
        ChatView *v=[self getChatView:nd from:YES activityViewV:activityBg];
        
        [chatArray addObject:v];
        [_chatNotesDataArray addObject:nd];
        [self reloadChatTabel];
        
        MessageModel *mm = [[MessageModel alloc] init];
        mm.chatType=self.chatType;
        mm.fileType=2;
        mm.messageID=[fileName stringByDeletingPathExtension];
        mm.receivedTime=_time;
        mm.msg =@" ";
        mm.from = [ConstantObject sharedConstant].userInfo.imacct;
        mm.to  = _toUserId;
        mm.thread=@"";
        
        mm.chatVoiceData=nd.chatVoiceData;
        
        [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
        [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
        [self uploadVoice:fileName imagePath:filePath uuid:mm.messageID avtivtyView:activityBg noteData:nd];
        
    }else{
        DDLogInfo(@"发送语音取消");
    }
}
-(void)buttonAudioRecorder:(ButtonAudioRecorder *)audioRecorder begintouch:(BOOL)flag{
    if(!flag){
        [voice_tip_view setHidden:NO];
        [self performSelector:@selector(hidevoice_tip) withObject:nil afterDelay:2.0];
        DDLogInfo(@"语音按钮单击");
    }
    [self.view endEditing:YES];
    UITextView *t=(UITextView *)[self.view viewWithTag:text_input_tag];
    textFrame=t.frame;
    inputFrame=_inputView.frame;
    int numIos7=0;
    if (IS_IOS_7) {
        numIos7=64;
    }else{
        numIos7=44;
    }
    _inputView.frame=CGRectMake(0, self.view.frame.size.height-inputFrame.size.height, inputFrame.size.width, inputFrame.size.height);
    FaceButton *butt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
    if (butt.selected) {
        [butt setBackgroundImage:[UIImage imageNamed:@"chat_smile"] forState:UIControlStateNormal];
        butt.selected=!butt.selected;
    }
    //    self.window.layer ;
    //    DDLogInfo(@"rect1: %@", NSStringFromCGRect(self.view.frame));
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    //    CGRect rect = CGRectMake(166, 211, 426, 320);//这里可以设置想要截图的区域
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    audioRecorder.image=[sendImage applyLightEffect];
    //    DDLogInfo(@"####%f  %f ",sendImage.size.width,sendImage.size.height);
}
-(void)hidevoice_tip{
    [voice_tip_view setHidden:YES];
}

-(void)uploadVoice:(NSString *)voiceName imagePath:(NSString *)path uuid:(NSString *)cfuuidString avtivtyView:(ActivituViewBg *)activityBg noteData:(NotesData *)nd{
    NSData *voiceData=[NSData dataWithContentsOfFile:[path filePathOfCaches]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:file_update_url parameters:@{@"newimagetype":@"5",@"fileName":voiceName} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        //            [formData appendPartWithFormData:voiceData name:fileName];
        [formData appendPartWithFileData:voiceData name:voiceName fileName:voiceName mimeType:@"application/octet-stream"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //            {"duration":"0",
        //                "original_link":"http://218.205.81.33/
        //                upload/sound/
        //                8c6a1b2052e2449ca4f21a1f18f24381.MP3"}
        
        
        NSDictionary *resultDict=[DataToDict dataToDict:responseObject];
        
        NSDictionary *_dict=@{key_messageVoice_name: voiceName,
                              key_messageVoice_url:resultDict[@"original_link"],
                              key_messageVoice_length:nd.chatVoiceData.voiceLenth};
        //把请求下来的值带上,再次发送的时候如果有这个数据就是,图片上传成功,但是消息没有发出去
        nd.chatVoiceData.voiceUrl=resultDict[@"original_link"];
        [[SqliteDataDao sharedInstanse] updateVoiceMessageDataWithMessageId:nd.contentsUuid voiceChatData:nd.chatVoiceData];
        [[QFXmppManager shareInstance] sendMessage:_dict chatType:self.chatType withType:kMsgVoice toUser:_toUserId messageId:cfuuidString withCompletion:^(BOOL ret, NSString *siID) {
            
            if (ret) {
                DDLogInfo(@"发送语音成功");
                [activityBg sendsucceed];
                
            }else{
                DDLogInfo(@"发送语音失败");
                [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:nd.contentsUuid state:@"2"];
                [activityBg addFailView:nd];
                activityBg.sendMessageAgain=^(NotesData *nd){
                    [self sendMessageAgainWithNotesData:nd];
                };
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //图片发送失败,
        //            [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:cfuuidString state:@"2"];
        [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:nd.contentsUuid state:@"2"];
        [activityBg addFailView:nd];
        activityBg.sendMessageAgain=^(NotesData *nd){
            [self sendMessageAgainWithNotesData:nd];
        };
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:nil];
}
#pragma mark-
#pragma mark http

BOOL is_send_message_again = NO;//是否是再次发送
#pragma mark - 发送消息
-(void)sendFace:(UITextView *)textView{
    if(textView.text.length==0){
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"不能发送空文本！" isCue:1 delayTime:1 isKeyShow:YES];
        return ;
    }
    if(textView.text.length>900){
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"文本消息字数过长！" isCue:1 delayTime:1 isKeyShow:YES];
        return ;
    }
    if (textView.text.length>0) {
        is_send_message_again=NO;
        [self sendMessage:textView messageType:@"0" message:textView.text withNotesData:nil];
    }
    
}

-(void)sendMessage:(UITextView *)textView messageType:(NSString *)messageType message:(NSString *)content withNotesData:(NotesData *)nd{
    //发送消息
    
#pragma mark 发送消息
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *contentsStr=content;
    //    if (contentsStr) {
    //        contentsStr=[[ConstantObject sharedConstant] originalFaceText:contentsStr];
    //    }
    //    contentsStr=[contentsStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    BOOL isKongGe;
    for (int i=0; i<contentsStr.length; i++) {
        NSString *tempStr=[contentsStr substringWithRange:NSMakeRange(i, 1)];
        if (![tempStr isEqualToString:@" "]) {
            isKongGe=NO;
            break;
            
        }
        isKongGe=YES;
    }
    if (![messageType isEqualToString:@"0"]) {
        isKongGe=NO;
    }
    if (isKongGe) {
        [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"发送的内容全部为空格,内容为:%@",contentsStr]];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"不能发送空白信息" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
        return;
    }
    
    //    int length=[CalculateCharLength convertToInt:contentsStr];
    if (contentsStr.length>6000) {
        //字数
        
        [myApp showWithCustomView:nil detailText:@"内容太长了！" isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }
    
    NotesData * notesData=[[NotesData alloc] init];
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    long long int dateTime=(long long int) nowTime;
    
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    
    if(nd.contentsUuid){
        cfuuidString=nd.contentsUuid;
    }
    notesData.contentsUuid=cfuuidString;
    notesData.sendContents=contentsStr;
    notesData.fromUserName=[ConstantObject sharedConstant].userInfo.name;
    notesData.fromUserId=[ConstantObject sharedConstant].userInfo.imacct;
    notesData.typeMessage=messageType;
    
    
    NSDictionary *msgDict;
    
    int message_type=0;
    if ([messageType isEqualToString:@"1"]) {
        message_type=1;
        msgDict=@{key_messageImage_image_name: nd.imageCHatData.imageName,
                  key_messageImage_middle_link:nd.imageCHatData.middleLink,
                  key_messageImage_original_link:nd.imageCHatData.originalLink,
                  key_messageImage_small_link:nd.imageCHatData.smallLink,
                  key_messageImage_image_width:[NSString stringWithFormat:@"%d",nd.imageCHatData.imagewidth],key_messageImage_image_height:[NSString stringWithFormat:@"%d",nd.imageCHatData.imageheight]};
        notesData.imageCHatData=nd.imageCHatData;
        [imageUrlArray addObject:notesData];
    }else if ([messageType isEqualToString:@"2"]){
        NSString *voiceName=nd.chatVoiceData.voiceName;
        message_type=2;
        if (voiceName.length<=0) {
            //                pathExtension
            voiceName=[nd.chatVoiceData.voicePath lastPathComponent];
            voiceName=[NSString stringWithFormat:@"%@_%@.%@",[voiceName stringByDeletingPathExtension],nd.chatVoiceData.voiceLenth,[voiceName pathExtension]];
        }
        
        msgDict=@{key_messageVoice_name: voiceName,
                  key_messageVoice_url:nd.chatVoiceData.voiceUrl,
                  key_messageVoice_length:nd.chatVoiceData.voiceLenth};
        notesData.chatVoiceData=nd.chatVoiceData;
    }else if ([messageType isEqualToString:@"0"]){
        msgDict=@{key_messageText: contentsStr};
    }
    
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString=[dateFormatter stringFromDate:time];
    notesData.serverTime=destDateString;
    
    MessageModel *mm = [[MessageModel alloc] init];
    mm.chatType=self.chatType;
    mm.fileType=[messageType integerValue];
    mm.messageID=cfuuidString;
    mm.receivedTime=destDateString;
    mm.msg = contentsStr;
    mm.from = [ConstantObject sharedConstant].userInfo.imacct;
    mm.to  = _toUserId;
    mm.thread=@"";
    
    mm.imageChatData=nd.imageCHatData;
    mm.chatVoiceData=nd.chatVoiceData;
    
    [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
    [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
    
    ChatView *v=nil;
    //菊花
    ActivituViewBg *activityViewBackgroundView=[[ActivituViewBg alloc] initWithGetActivityView:notesData];
    activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
        [self sendMessageAgainWithNotesData:nd];
    };
    v=[self getChatView:notesData from:YES activityViewV:activityViewBackgroundView];
    [chatArray addObject:v];
    [_chatNotesDataArray addObject:notesData];
    
    if (self.chatType==3) {
        [SendMassMessage sendMassMessageWithMemberList:self.member_infoArray message:contentsStr messageId:cfuuidString complition:^(BOOL ret) {
            if (ret) {
                DDLogInfo(@"发送成功");
                [activityViewBackgroundView sendsucceed];
                [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:cfuuidString state:@"1"];
            }else{
                DDLogInfo(@"发送失败");
                [activityViewBackgroundView addFailView:notesData];
                activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                    DDLogInfo(@"再次发送");
                    [self sendMessageAgainWithNotesData:nd];
                };
            }
        }];
    }else{
        UserModel *um=[[UserModel alloc] init];
        um.jid=_toUserId;
        
        if (self.chatType==2) {
            msgDict=@{key_messageText: contentsStr,
                      key_public_pa_uuid:self.publicModel.pa_uuid,
                      key_public_creat_time:destDateString,
                      key_public_sip_uri:self.publicModel.sip_uri};
        }
        
        [[QFXmppManager shareInstance] sendMessage:msgDict chatType:self.chatType withType:message_type toUser:_toUserId messageId:cfuuidString withCompletion:^(BOOL ret, NSString *siID) {
            if (ret) {
                DDLogInfo(@"发送成功");
                [activityViewBackgroundView sendsucceed];
            }else{
                DDLogInfo(@"发送失败");
                [activityViewBackgroundView addFailView:notesData];
                activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                    DDLogInfo(@"再次发送");
                    [self sendMessageAgainWithNotesData:nd];
                };
            }
        }];
    }
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:notesData];
    
    if (self.isTranmist) {
        [self reloadChatTabel];
        return;
    }
    
    if (!is_send_message_again){
        _chatTable.frame=CGRectMake(0, 0, 320, self.view.frame.size.height-44-keyboadHeight);
    }
    
    
    CGRect fram=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin, 225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, 26);
    textView.frame=fram;
    
    int numIos7=0;
    if (IS_IOS_7) {
        numIos7=0;
    }else{
        numIos7=0;
    }
    if (!is_send_message_again) {
        _inputView.frame=CGRectMake(0, self.view.frame.size.height-44-keyboadHeight-numIos7, 320, 10+34);
    }
    
    [textView setText:@""];
    //    [self textviewChangeFrame:@""];
    inputTextView.frame=CGRectMake(inputTextView.frame.origin.x, inputTextView.frame.origin.y, inputTextView.frame.size.width, inputHeight);
    [self reloadChatTabel];
    
    
}
-(void)sendMessageAgain:(id)sender{
    //再次发送
    MenuButton *butt=(MenuButton *)sender;
    
    [self sendMessageAgainWithNotesData:butt.nd];
    
    
    
}
-(void)sendMessageAgainWithNotesData:(NotesData *)nd{
    _selectNotesData=nd;
    UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重新发送", nil];
    actionSheet.tag=actionSheet_message_send_again;
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
#pragma mark-
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    //设置
    DDLogInfo(@"beging%f %f %@",textView.frame.size.width,textView.frame.size.height,textView.text);
    //    [self textChanged:nil];
    [self textviewChangeFrame:textView.text];
    DDLogInfo(@"结束%f %f ",textView.frame.size.width,textView.frame.size.height);
    
    FaceButton *butt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
    if (butt.selected) {
        butt.selected=!butt.selected;
    }
    MoreButton *morebtn=(MoreButton *)[self.view viewWithTag:butt_add_tag];
    morebtn.selected=NO;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (toBeString.length>6000) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"文本消息字数过长！" isCue:1 delayTime:1 isKeyShow:YES];
        return NO;
    }
    if ([text isEqualToString:@"@"]) {
        
    }
    if ([text isEqualToString:@"\n"]) {
        if(textView.text.length==0){
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"不能发送空文本！" isCue:1 delayTime:1 isKeyShow:YES];
            return NO;
        }
        if(textView.text.length>6000){
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"文本消息字数过长！" isCue:1 delayTime:1 isKeyShow:YES];
            return NO;
        }
        is_send_message_again=NO;
        [self sendMessage:textView messageType:@"0" message:textView.text withNotesData:nil];
        return NO;
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    
    [self textviewChangeFrame:textView.text];
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    //    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    [textView scrollRectToVisible:CGRectMake(0, line.origin.y+7, inputTextView.contentSize.width, 15) animated:NO];
    //    DDLogCInfo(@"#####%f----%f-----%f",line.origin.y,line.size.height,textView.contentSize.height);
    //    [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height+overflow-4, textView.contentSize.width, 15) animated:NO];
    //
    //    if ( overflow > 0 ) {
    //
    //        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
    //
    //        // Scroll caret to visible area
    //
    //        CGPoint offset = textView.contentOffset;
    //
    //        offset.y += overflow + 7; // leave 7 pixels margin
    //
    //        // Cannot animate with setContentOffset:animated: or caret will not appear
    //
    //        [UIView animateWithDuration:.2 animations:^{
    //            [textView setContentOffset:offset];
    //        }];
    //    }
    //
    
}

-(void)textviewChangeFrame:(NSString *)textstr{
    float height;
    //    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    //    CGSize maxSize=CGSizeMake(inputTextView.frame.size.width, 99999);
    //    CGSize retSize = [textstr boundingRectWithSize:maxSize
    //                                             options:NSStringDrawingUsesLineFragmentOrigin|
    //                                                        NSStringDrawingUsesFontLeading
    //                                          attributes:attribute
    //                                             context:nil].size;
    //    height=retSize.height+11;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect textFrame=[[inputTextView layoutManager]usedRectForTextContainer:[inputTextView textContainer]];
        height = textFrame.size.height+11;
        
    }else {
        height = inputTextView.contentSize.height+11;
    }
    
    //    DDLogInfo(@"调整后%f--%@ ",height,textstr);
    if (height<=inputHeight) {
        inputTextView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin,225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, inputHeight);
        _inputView.frame=CGRectMake(0, self.view.frame.size.height-44-keyboadHeight, 320, 44);
    }else{
        if (height<100) {
            inputTextView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin,225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, height);
            _inputView.frame=CGRectMake(0, self.view.frame.size.height-inputMinu-height-keyboadHeight, 320,height+inputMinu);
        }else{
            inputTextView.frame=CGRectMake(46+_widthForServiceNum-_widthVoiceBtn, inputTopMargin, 225-_widthForServiceNum-_widthAddButt+_widthVoiceBtn, 96);
            _inputView.frame=CGRectMake(0, self.view.frame.size.height-(96+inputMinu)-keyboadHeight, 320, 96+inputMinu);
        }
    }
    
    _chatTable.frame=CGRectMake(0, 0, 320, self.view.frame.size.height-_inputView.frame.size.height-keyboadHeight-0);
    if ([chatArray count]>0) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0];
        [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


/*
 生成泡泡UIView
 */
#pragma mark - 生成泡泡UIView
#pragma mark 聊天记录气泡时间部分
//创建一个气泡view 要点是：对image进行边帽设置，然后对内容进行动态读取大小，通过内容的大小设置view等的大小
-(ChatView *)getChatView:(NotesData *)notesData from:(BOOL)isMyself activityViewV:(UIView *)activityView{
    //最终的返回View
    //    ChatView *returnView=[[ChatView alloc] initWithFrame:CGRectZero];
    //    returnView.nd=notesData;
    //    returnView.chatViewType=isMyself?MyChatViewTypeR:MyChatViewTypeL;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr=notesData.serverTime;
    NSDate * theDate = [dateFormatter dateFromString:timeStr];
    NSDate * lastDate=nil;
    NSTimeInterval timeDifference;
    
    //    BOOL isShowTime=NO;//是否显示时间,间隔大于60*5秒显示
    if (lastTime!=nil) {
        lastDate = [dateFormatter dateFromString:lastTime];
        timeDifference=[theDate timeIntervalSinceDate:lastDate];
    }
    
    ChatView *timeView;
    if (lastTime==nil || timeDifference>60*5){
        //为空或者为60*5就显示时间
        NSString * messageTime=[dateFormatter stringFromDate:theDate];
        lastTime=messageTime;
        
        NSArray * array = [messageTime componentsSeparatedByString:@" "];
        NSArray * dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSArray * timeArray =array.count>1?[array[1] componentsSeparatedByString:@":"]:nil;
        NSString * hour = timeArray?timeArray[0]:@"";
        NSString * minute = timeArray?timeArray[1]:@"";
        NSString *nowDateStr=[[NSDate date] nowDateStringWithFormatter:@"YYYY-MM-dd"];
        if ([nowDateStr isEqualToString:array[0]]) {
            messageTime = [NSString stringWithFormat:@"%@:%@",hour,minute];
        }
        timeView=[self timeView:messageTime];
        timeView.nd=notesData;
        
        //        DDLogInfo(@"时间cell的大小%@",NSStringFromCGRect(timeView.frame));
        [chatArray addObject:timeView];
    }
    return [self getChatViewonly:notesData from:isMyself activityViewV:activityView];
}
#pragma mark 聊天记录气泡实体部分
-(ChatView *)getChatViewonly:(NotesData *)notesData from:(BOOL)isMyself activityViewV:(UIView *)activityView{
    //最终的返回View
    ChatView *returnView=[[ChatView alloc] initWithFrame:CGRectZero];
    returnView.nd=notesData;
    returnView.chatViewType=isMyself?MyChatViewTypeR:MyChatViewTypeL;
    //    returnView.backgroundColor=[UIColor blueColor];
    //对于不同类型的聊天内容加载不同的气泡图片
    NSString *imageName= isMyself ? @"chat_to_bg_normal.9.png":@"chat_from_bg_normal.9.png";
    UIImage *img=[UIImage imageNamed:imageName];
    //对图片进行边帽设置，可以把图片分为4个部分，取大约值即可，将来放大的话 四个角不变，其余部分会自动有规则的填充
    UIImage *newImage=[img stretchableImageWithLeftCapWidth:isMyself ? 15 : 30 topCapHeight:26];
    //刚开始不能确定view的大小，所以设置为CGRectZero
    ChatView *bgView=[[ChatView alloc] initWithFrame:CGRectZero];
    //设置tag值的目的，是为了将来在单元格上删除view，避免单元格重用view的
    bgView.tag=101;
#pragma mark -------公告------
    if([notesData.typeMessage isEqualToString:@"4"]){
        bgView.backgroundColor=[UIColor whiteColor];
        
        UILabel *tttitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 500)];
        tttitle.text=notesData.BulletinModel.title;
        tttitle.font=[UIFont systemFontOfSize:16];
        tttitle.numberOfLines=2;
        tttitle.lineBreakMode=NSLineBreakByCharWrapping;
        [tttitle sizeToFit];
        float  titleheight=tttitle.frame.size.height;
        
        UILabel *titlelb=[[UILabel alloc]initWithFrame:CGRectMake(9, 13, 280, titleheight)];
        titlelb.textColor=cor1;
        titlelb.font=[UIFont systemFontOfSize:16];
        titlelb.text=notesData.BulletinModel.title;
        titlelb.numberOfLines=2;
        titlelb.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        [titlelb sizeToFit];
        [bgView addSubview:titlelb];
        UILabel *timelb=[[UILabel alloc]initWithFrame:CGRectMake(9, titlelb.frame.origin.y+titlelb.frame.size.height+7.5, 280, 11)];
        timelb.textColor=cor3;
        timelb.font=[UIFont systemFontOfSize:11];
        timelb.text=notesData.BulletinModel.receiveTime;
        [bgView addSubview:timelb];
        UIImageView *imageview;
        float imageheight;
        if(![notesData.BulletinModel.picUrl isEqualToString:@"(null)"]){
            imageview =[[UIImageView alloc]initWithFrame:CGRectMake(9, timelb.frame.origin.y+timelb.frame.size.height+10, 280, 140)];
            
            [imageview setImageWithURL:[NSURL URLWithString:notesData.BulletinModel.picUrl] placeholderImage:[UIImage imageNamed:@"FriendsSendsPicturesNo.png"]];
            imageview.contentMode=UIViewContentModeScaleAspectFill;
            imageview.clipsToBounds  = YES;
            imageheight=140;
            
        }else{
            imageview =[[UIImageView alloc]initWithFrame:CGRectMake(9, timelb.frame.origin.y+timelb.frame.size.height, 280, 0)];
            imageheight=0;
        }
        [bgView addSubview:imageview];
        UILabel *ttlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 500)];
        ttlabel.text=notesData.BulletinModel.msg_digest;
        ttlabel.font=[UIFont systemFontOfSize:12];
        ttlabel.numberOfLines=4;
        ttlabel.lineBreakMode=NSLineBreakByCharWrapping;
        [ttlabel sizeToFit];
        float  textheight=ttlabel.frame.size.height;
        UILabel *contentlb=[[UILabel alloc]initWithFrame:CGRectMake(9, imageview.frame.origin.y+imageview.frame.size.height+10, 280, textheight)];
        contentlb.textColor=cor3;
        contentlb.font=[UIFont systemFontOfSize:12];
        contentlb.text=notesData.BulletinModel.msg_digest;
        contentlb.lineBreakMode=NSLineBreakByWordWrapping|4;
        contentlb.numberOfLines=4;
        [contentlb sizeToFit];
        [bgView addSubview:contentlb];
        
        UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(9, contentlb.frame.origin.y+contentlb.frame.size.height+12, 280, 0.5)];
        lineview.backgroundColor=cor3;
        [bgView addSubview:lineview];
        
        UIButton *allbutton=[[UIButton alloc]initWithFrame:CGRectMake(9, contentlb.frame.origin.y+contentlb.frame.size.height+12.5, 280, 34)];
        allbutton.titleLabel.font=[UIFont systemFontOfSize:12];
        [allbutton setTitleColor:cor3 forState:UIControlStateNormal];
        [allbutton setTitle:@"查看全文 >>" forState:UIControlStateNormal];
        
        allbutton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
        //        allbutton.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
        allbutton.tag=[notesData.BulletinModel.bulletinID intValue];//  文章ID
        [allbutton addTarget:self action:@selector(contexttouch:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:allbutton];
        bgView.frame=CGRectMake(11, 11, 298, 98+textheight+titleheight+imageheight);
        
        UIButton *btn=[[UIButton alloc]initWithFrame:bgView.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        btn.tag=[notesData.BulletinModel.bulletinID intValue];
        [btn addTarget:self action:@selector(contexttouch:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
        returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height+11+18);
        [returnView addSubview:bgView];
        return returnView;
        
    }
#pragma mark -----和企录团队-----
    if(self.chatType==5){
        
        MenuButton *headImage=nil;
        UIImageView *headImageView=nil;
        UILabel *headNameLabel=nil;
        float totop=6;//cell间距的一半
        float toleft=12;
        if (notesData.fromUserId!=nil) {
            if(isMyself){
                toleft=320-36-toleft;
            }
            headImage=[[MenuButton alloc]initWithFrame:CGRectMake(toleft, totop, 36, 36)];
            headImage.nd=notesData;
            headImage.layer.cornerRadius = 18.0;
            headImage.layer.masksToBounds = YES;
            [headImage addTarget:self action:@selector(headClick:) forControlEvents:UIControlEventTouchUpInside];
            headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
            headImageView.image=[UIImage imageNamed:@"msg_icon_team"];
        }
        
        switch ([notesData.typeMessage intValue]) {
            case 0:
            {
                //文字
                //创建一个imageView
                notesData.sendContents=notesData.teamMsgModel.notify_summary;
                MenuButton *bubble=[MenuButton buttonWithType:UIButtonTypeCustom];
                bubble.nd=notesData;
                [bubble setBackgroundImage:newImage forState:UIControlStateNormal];
                [bubble addTarget:self action:@selector(bubbleButtClick:) forControlEvents:UIControlEventTouchUpInside];
                bubble.imageView.tag=isMyself ? 1 :2;
                
                UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(textLabelLongPress:)];
                [bubble addGestureRecognizer:longGesture];
                
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelTap:)];
                tapGesture.numberOfTapsRequired=2;
                [bubble addGestureRecognizer:tapGesture];
                
                MLEmojiLabel *label=[[MLEmojiLabel alloc] init];
                label.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
                label.emojiDelegate=self;
                label.isNeedAtAndPoundSign=NO;
                if([notesData.isSend isEqualToString:@"3"]){
                    
                    ActivituViewBg *activityViewBackgroundView=[[ActivituViewBg alloc] initWithGetActivityView:notesData];
                    activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                        [self sendMessageAgainWithNotesData:nd];
                    };
                    activityViewBackgroundView.frame=activityView.frame;
                    [[QFXmppManager shareInstance]updatejuhua:notesData.contentsUuid withCompletion:^(BOOL ret, NSString *siID) {
                        if (ret) {
                            [activityViewBackgroundView sendsucceed];
                        }else{
                            [activityViewBackgroundView addFailView:notesData];
                            activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                                [self sendMessageAgainWithNotesData:nd];
                            };
                        }
                    }];
                    activityView=activityViewBackgroundView;
                }
                
                MLChatView *mlChatView=[[MLChatView alloc] initWithData:notesData :bubble :isMyself :bgView :headImage :activityView :headNameLabel :headImageView :returnView :label isRoom:self.chatType==1?YES:NO];
                label.emojiLabelTouchEnd=^(id sender){
                    if ([self tagarWhenEditing:notesData]) {
                        return;
                    }
                };
                if (mlChatView.send_Failed_Butt) {
                    [mlChatView.send_Failed_Butt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
                }
                return mlChatView.chat_View;
                break;
            }
            case 1:
            {
                MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
                buttBubble.nd=notesData;
                [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
                [buttBubble setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
                [buttBubble addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                buttBubble.adjustsImageWhenHighlighted=NO;
                buttBubble.imageView.tag=isMyself ? 1 :2;
                MyImageView *chatImage=[[MyImageView alloc] init];
                chatImage.clipsToBounds=YES;
                chatImage.nd=notesData;
                chatImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imageLongPress:)];
                [buttBubble addGestureRecognizer:longGesture];
                [chatImage.layer setMasksToBounds:YES];
                chatImage.layer.cornerRadius=13;
                
                //需要从网络加载图片
                //                [chatImage setImageWithURL:[NSURL URLWithString:notesData.teamMsgModel.notify_picUrl] placeholderImage:[UIImage imageNamed:@"FriendsSendsPicturesNo.png"]];
                [chatImage setImageWithURL:[NSURL URLWithString:[self fixurl:notesData.teamMsgModel.notify_picUrl]] placeholderImage:[UIImage imageNamed:@"FriendsSendsPicturesNo.png"]];
                
                if(notesData.imageCHatData.imageheight<=0||notesData.imageCHatData.imagewidth<=0){
                    notesData.imageCHatData.imageheight=120;
                    notesData.imageCHatData.imagewidth=100;
                    DDLogInfo(@"接收的图片尺寸值缺失或异常");
                }
                float iwidth=100;
                float iheight=120;
                if(notesData.imageCHatData.imagewidth>notesData.imageCHatData.imageheight){
                    //宽图
                    iwidth=100;
                    iheight=iwidth/notesData.imageCHatData.imagewidth*notesData.imageCHatData.imageheight;
                    if (iheight<20) {
                        iheight=20;
                    }
                }else{
                    //长图
                    iheight=120;
                    iwidth=iheight/notesData.imageCHatData.imageheight*notesData.imageCHatData.imagewidth;
                    if(iwidth<20)
                        iwidth=20;
                }
                
                int  bubbletotop=6;             //|-d-气泡
                int  labelLeftMargin=2+1+9;
                int  labelRightMargin=2;
                int  labelTopMargin = 2;        //内容距气泡上边距
                int  bubbletoleft=(12+36+3);
                if(!self.chatType==1){
                    bubbletotop=6;
                }
                chatImage.frame=CGRectMake(9+2+1, 2,  iwidth,  iheight);
                buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, iwidth+labelRightMargin+labelLeftMargin, iheight+labelTopMargin*2);
                bgView.frame=CGRectMake(0, 0, 320, buttBubble.frame.size.height+bubbletotop+6);
                [bgView addSubview:headNameLabel];
                [headImage addSubview:headImageView];
                [buttBubble addSubview:chatImage];
                [bgView addSubview:headImage];
                [bgView addSubview:buttBubble];
                returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height+5);
                [returnView addSubview:bgView];
                return returnView;
                break;
            }
        }
    }
    if ([notesData.typeMessage isEqualToString:@"3"]) {
#pragma mark  服务号
        
        CGFloat widthScreen=[UIScreen mainScreen].bounds.size.width;
        NSError *error=nil;
        NSXMLElement *x_parse=[[NSXMLElement alloc] initWithXMLString:notesData.sendContents error:&error];
        
        if (error) {
            DDLogInfo(@"解析出错,error:%@",error);
        }
        NSString *pubulic_type=[[x_parse elementForName:@"media_type"] stringValue];
        
        if ([pubulic_type isEqualToString:@"50"]) {
            //图文消息
            NSArray *articleArray=[[x_parse elementForName:@"article"] elementsForName:@"mediaarticle"];
            if (articleArray.count>1) {
                //为新版本的服务号,多图文
                
                CustomViewServiceListView *customView=[[CustomViewServiceListView alloc] initWithFrame:CGRectMake(MIDDLE_MARGIN_LEFT, MIDDLE_MARGIN_TOP, widthScreen-MIDDLE_MARGIN_LEFT*2, 0)];
                customView.userInteractionEnabled=YES;
                customView.nd=notesData;
                [returnView addSubview:customView];
                /*
                 customView.menuClick=^(NSString *menuName){
                 _selectNotesData=notesData;
                 if ([menuName isEqualToString:myDelete]) {
                 //删除
                 //                    _selectNotesData=notesData;
                 [self myDelete:nil];
                 }else if ([menuName isEqualToString:myMore]){
                 //更多
                 
                 [self more:nil];
                 }else if ([menuName isEqualToString:myTransmit]){
                 //转发
                 [self myTransmit:nil];
                 }
                 };
                 */
                customView.tabelDidClick=^(UITableView *tableView,NSIndexPath *indexPath,NSXMLElement *serverNewElement){
                    UIMenuController *menu=[UIMenuController sharedMenuController];
                    [menu setMenuVisible:NO];
                    
                    if([self tagarWhenEditing:notesData]){
                        return;
                    }
                    
                    ServiceNumberMsgDetailViewController *snMsgDetail=[[ServiceNumberMsgDetailViewController alloc]init];
                    snMsgDetail.x_element=serverNewElement;
                    snMsgDetail.notesData=notesData;
                    snMsgDetail.hidesBottomBarWhenPushed=YES;
                    [self.navigationController pushViewController:snMsgDetail animated:YES];
                    
                };
                
                returnView.frame=CGRectMake(0, 0,(int) widthScreen, 0);
                
                CGRect bgViewFrame=returnView.frame;
                
                bgViewFrame.size.height=(int)customView.frame.size.height+MIDDLE_MARGIN_TOP*2;
                returnView.frame=bgViewFrame;
                return returnView;
                
            }else if(articleArray.count==1){
                //单图文
                
                NSXMLElement *dan_x=articleArray[0];
                
                NSString *plainText=[[dan_x elementForName:@"digest"] stringValue];
                
                CGFloat heightBG=HEIGHT_TITLE*(COUNT_DETAIL+2)+HEIGHT_IMAGE+PADDING*2;
                
                if ([notesData.sendContents length]<=0) {
                    heightBG=heightBG-HEIGHT_TITLE*0;
                    
                }else{
                    //                    CGSize size_buttonUrl_label=[plainText sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(widthScreen-MIDDLE_MARGIN_LEFT*2, 100) lineBreakMode:NSLineBreakByCharWrapping];
                    
                    NSDictionary * attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:13]};
                    CGSize size_buttonUrl_label= [plainText boundingRectWithSize:CGSizeMake(widthScreen-MIDDLE_MARGIN_LEFT*2-6*2, 100) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
                    
                    heightBG=heightBG-HEIGHT_TITLE*4+size_buttonUrl_label.height+10;
                    
                }
                bgView.frame=CGRectMake(0, 0, widthScreen, heightBG+40+MIDDLE_MARGIN_TOP*2);
                
                CustomButtonNewsDetail *buttonUrl=[[CustomButtonNewsDetail alloc]initWithFrame:CGRectMake(MIDDLE_MARGIN_LEFT, MIDDLE_MARGIN_TOP, widthScreen-MIDDLE_MARGIN_LEFT*2, heightBG+40)];
                [buttonUrl setDate:[[dan_x elementForName:@"createtime"] stringValue]];
                [buttonUrl setDetail:plainText];
                buttonUrl.contentMode=UIViewContentModeScaleToFill;
                [buttonUrl addTarget:self action:@selector(middleMsgClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonUrl setImageWithName:[[dan_x elementForName:@"original_link"] stringValue] placeholderImageName:@"FriendsSendsPicturesNo"];
                [buttonUrl setTitle:[[dan_x elementForName:@"title"] stringValue] forState:UIControlStateNormal];
                
                /*
                 UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(middleMsgLongPress:)];
                 [longRecognizer setMinimumPressDuration:0.8];
                 [buttonUrl addGestureRecognizer:longRecognizer];
                 */
                buttonUrl.nd=notesData;
                [bgView addSubview:buttonUrl];
                
            }
            
            //            if (isShowTime) {
            //                returnView=[self margeTimeView:bgView :timeView :returnView];
            //            }else{
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            returnView.chatViewType=MyChatViewTypeNormal;
            [returnView addSubview:bgView];
            //            }
            returnView.userInteractionEnabled=YES;
            return returnView;
        }else if ([pubulic_type isEqualToString:@"20"]){
            //图片消息
            
            NSXMLElement *pic_x=[x_parse elementForName:@"pic"];
            
            ImageChatData *imgCd=[[ImageChatData alloc] init];
            imgCd.middleLink=[[pic_x elementForName:@"thumb_link"] stringValue];
            imgCd.originalLink=[[pic_x elementForName:@"original_link"] stringValue];
            imgCd.smallLink=[[pic_x elementForName:@"small_link"] stringValue];
            notesData.imageCHatData=imgCd;
            notesData.typeMessage=@"1";
            [imageUrlArray addObject:notesData];
        }else if([pubulic_type isEqualToString:@"10"]){
            notesData.sendContents=[[x_parse elementForName:@"text"] stringValue];
            notesData.typeMessage=@"0";
        }else if ([pubulic_type isEqualToString:@"40"]){
            //声音
            notesData.typeMessage=@"2";
            
            NSXMLElement *voice_x=[x_parse elementForName:@"audio"];
            
            ChatVoiceData *chatVoiceData=[[ChatVoiceData alloc] init];
            chatVoiceData.voiceUrl=[[voice_x elementForName:@"original_link"] stringValue];
            chatVoiceData.voiceName=[[voice_x elementForName:@"title"] stringValue];
            
            NSString *voiceLength=[[voice_x elementForName:@"duration"] stringValue];
            chatVoiceData.voiceLenth=voiceLength;
            notesData.chatVoiceData=chatVoiceData;
        }
    }
    
#pragma mark  - 头像
    MenuButton *headImage=nil;
    UIImageView *headImageView=nil;
    UILabel *headNameLabel=nil;
    float totop=6;//cell间距的一半
    float toleft=12;
    if (notesData.fromUserId!=nil) {
        
        if(isMyself){
            toleft=320-36-toleft;
        }
        //        headImage=[MenuButton buttonWithType:UIButtonTypeCustom];
        headImage=[[MenuButton alloc]initWithFrame:CGRectMake(toleft, totop, 36, 36)];
        headImage.nd=notesData;
        headImage.layer.cornerRadius = 18.0;
        headImage.layer.masksToBounds = YES;
        [headImage addTarget:self action:@selector(headClick:) forControlEvents:UIControlEventTouchUpInside];
        //        [headImage.layer setMasksToBounds:YES];
        
        //        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        //        [longRecognizer setMinimumPressDuration:0.8];
        //        [headImage addGestureRecognizer:longRecognizer];
        
        headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        if (notesData.serviceMark==1) {
            [headImageView setImageWithURL:[NSURL URLWithString:@""]  placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
        }else{
            //如果没有头像,显示默认头像
            //如果有头像notesData.imageUrl,这个数组里边是字典,如果没有,为空,为NSString类型
            NSString *head_path=@"";
            if(isMyself) {
                head_path=[ConstantObject sharedConstant].userInfo.avatar;
            }else{
                if (self.chatType==0) {
                    head_path=self.member_userInfo.avatarimgurl;
                }else if (self.chatType==1){
                    EmployeeModel *eModel=[SqlAddressData queryMemberInfoWithImacct:notesData.fromUserId];
                    head_path=eModel.avatarimgurl;
                }else if(self.chatType==2){
                    head_path=self.publicModel.logo;
                }
            }
            
            //去掉空格
            head_path=[head_path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //            default_headImage
            [headImageView setImageWithURL:[NSURL URLWithString:head_path] placeholderImage:defaultHeadImage];
        }
        //姓名
        headNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(toleft+36+12.5, totop, 150, 10)];
        headNameLabel.backgroundColor=[UIColor clearColor];
        if (isMyself) {
            headNameLabel.hidden=YES;
        }else{
            if (self.chatType==1) {
                EmployeeModel *eModel=[SqlAddressData queryMemberInfoWithImacct:notesData.fromUserId];
                if(eModel.name){
                    headNameLabel.text=eModel.name;
                }else{
                    headNameLabel.text = [notesData.fromUserId substringToIndex:[notesData.fromUserId rangeOfString:@"_"].location];
                }
            }
        }
        headNameLabel.font=[UIFont systemFontOfSize:10];
        headNameLabel.textAlignment=NSTextAlignmentLeft;
        headNameLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    }
    
    switch ([notesData.typeMessage intValue]) {
        case 0:
        {
            //文字
#pragma mark  - 文字
            //创建一个imageView
            
            MenuButton *bubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            bubble.nd=notesData;
            [bubble setBackgroundImage:newImage forState:UIControlStateNormal];
            [bubble addTarget:self action:@selector(bubbleButtClick:) forControlEvents:UIControlEventTouchUpInside];
            bubble.imageView.tag=isMyself ? 1 :2;
            
            UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(textLabelLongPress:)];
            [bubble addGestureRecognizer:longGesture];
            
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelTap:)];
            tapGesture.numberOfTapsRequired=2;
            [bubble addGestureRecognizer:tapGesture];
            
            MLEmojiLabel *label=[[MLEmojiLabel alloc] init];
            //            if(isMyself){
            //                label.textColor=[UIColor whiteColor];
            //            }else{
            //                label.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            //            }
            label.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            label.emojiDelegate=self;
            
            label.isNeedAtAndPoundSign=NO;
            
            
            if([notesData.isSend isEqualToString:@"3"]){
                
                ActivituViewBg *activityViewBackgroundView=[[ActivituViewBg alloc] initWithGetActivityView:notesData];
                activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                    [self sendMessageAgainWithNotesData:nd];
                };
                activityViewBackgroundView.frame=activityView.frame;
                [[QFXmppManager shareInstance]updatejuhua:notesData.contentsUuid withCompletion:^(BOOL ret, NSString *siID) {
                    if (ret) {
                        [activityViewBackgroundView sendsucceed];
                    }else{
                        [activityViewBackgroundView addFailView:notesData];
                        activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                            [self sendMessageAgainWithNotesData:nd];
                        };
                    }
                }];
                activityView=activityViewBackgroundView;
            }
            
            MLChatView *mlChatView=[[MLChatView alloc] initWithData:notesData :bubble :isMyself :bgView :headImage :activityView :headNameLabel :headImageView :returnView :label isRoom:self.chatType==1?YES:NO];
            
            label.emojiLabelTouchEnd=^(id sender){
                
                
                if ([self tagarWhenEditing:notesData]) {
                    return;
                }
                
            };
            
            if (mlChatView.send_Failed_Butt) {
                [mlChatView.send_Failed_Butt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
            }
            return mlChatView.chat_View;
            break;
        }
        case 1:
        {
            //图片
#pragma mark - 图片
            MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            buttBubble.nd=notesData;
            [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
            [buttBubble setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            [buttBubble addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            buttBubble.adjustsImageWhenHighlighted=NO;
            buttBubble.imageView.tag=isMyself ? 1 :2;
            MyImageView *chatImage=[[MyImageView alloc] init];
            chatImage.clipsToBounds=YES;
            chatImage.nd=notesData;
            chatImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            //            NSArray *imagePathNameArray=[notesData.sendContents componentsSeparatedByString:@"#"];
            
            UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imageLongPress:)];
            [buttBubble addGestureRecognizer:longGesture];
            
            UIImage *image = nil;
            
            [chatImage.layer setMasksToBounds:YES];
            chatImage.layer.cornerRadius=13;
            if (isMyself) {
                //                NSString *path=notesData.imageCHatData.imagePath;
                
                NSString *self_image_path=notesData.imageCHatData.imagePath;
                if (self_image_path.length>0) {
                    NSString *path=[self_image_path filePathOfCaches];
                    
                    NSData *my_Self_Image_data=[NSData dataWithContentsOfFile:path];
                    
                    
                    image=[UIImage imageWithData:my_Self_Image_data scale:0.0001];
                    my_Self_Image_data=nil;
                    chatImage.image=image;
                }else{
                    
                    [chatImage setImageWithURL:[NSURL URLWithString:notesData.imageCHatData.middleLink] placeholderImage:[UIImage imageNamed:@"FriendsSendsPicturesNo.png"]];
                }
                //                DDLogInfo(@"收到图片大小%d %d",notesData.imageCHatData.imagewidth,notesData.imageCHatData.imageheight);
                if(notesData.imageCHatData.imageheight<=0||notesData.imageCHatData.imagewidth<=0){
                    notesData.imageCHatData.imageheight=120;
                    notesData.imageCHatData.imagewidth=100;
                    DDLogInfo(@"接收的图片尺寸值缺失或异常");
                }
                float iwidth=100;
                float iheight=120;
                if(notesData.imageCHatData.imagewidth>notesData.imageCHatData.imageheight){
                    //宽图
                    iwidth=100;
                    iheight=iwidth/notesData.imageCHatData.imagewidth*notesData.imageCHatData.imageheight;
                    if (iheight<20) {
                        iheight=20;
                    }
                }else{
                    //长图
                    iheight=120;
                    iwidth=iheight/notesData.imageCHatData.imageheight*notesData.imageCHatData.imagewidth;
                    if(iwidth<20)
                        iwidth=20;
                }
                
                
                
                int  bubbletotop=6;             //|-d-气泡
                int  labelLeftMargin=2;
                int  labelRightMargin=2+1+9;
                int  labelTopMargin = 2;        //内容距气泡上边距
                int  bubbletoleft=320-(12+36+3)-iwidth-labelRightMargin-labelLeftMargin;
                chatImage.frame=CGRectMake(2, 2,  iwidth,  iheight);
                buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, iwidth+labelRightMargin+labelLeftMargin, iheight+labelTopMargin*2);
                bgView.frame=CGRectMake(0, 0, 320, buttBubble.frame.size.height+bubbletotop+6);
                if (activityView==nil) {
                    //如果没有传进来这个view，创建一个
                    activityView=[[UIView alloc] init];
                    [activityView setBackgroundColor:[UIColor clearColor]];
                    
                }
                //                activityView.frame=CGRectMake(5, bgView.frame.size.height-38, 44, 44);
                activityView.frame=CGRectMake(bubbletoleft-20-8, bgView.frame.size.height/2-8, 15, 15);
                if ([notesData.isSend isEqualToString:@"2"]) {
                    //                    //发送失败
                    MenuButton *sendFailedButt=[MenuButton buttonWithType:UIButtonTypeCustom];
                    sendFailedButt.frame=CGRectMake(0, 0, 15, 15);
                    sendFailedButt.nd=notesData;
                    [sendFailedButt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
                    [sendFailedButt setImage:[UIImage imageNamed:@"icon_tip"] forState:UIControlStateNormal];
                    [activityView addSubview:sendFailedButt];
                    [bgView addSubview:activityView];
                }else if([notesData.isSend isEqualToString:@"3"]){
                    
                    ActivituViewBg *activityViewBackgroundView=[[ActivituViewBg alloc] initWithGetActivityView:notesData];
                    activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                        [self sendMessageAgainWithNotesData:nd];
                    };
                    activityViewBackgroundView.frame=CGRectMake(bubbletoleft-20-8, bgView.frame.size.height/2-8, 15, 15);
                    [[QFXmppManager shareInstance]updatejuhua:notesData.contentsUuid withCompletion:^(BOOL ret, NSString *siID) {
                        if (ret) {
                            [activityViewBackgroundView sendsucceed];
                        }else{
                            [activityViewBackgroundView addFailView:notesData];
                            activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                                [self sendMessageAgainWithNotesData:nd];
                            };
                        }
                    }];
                    [bgView addSubview:activityViewBackgroundView];
                }else{
                    [bgView addSubview:activityView];
                }
            }else{
                //                NSFileManager * fileManager = [[NSFileManager alloc]init];
                //                BOOL isExists = [fileManager fileExistsAtPath:[[imagePathNameArray objectAtIndex:0] filePathOfCaches] isDirectory:NO];
                BOOL isExists=NO;
                if (isExists) {
                    //                    NSString * filePath = [[imagePathNameArray objectAtIndex:0] filePathOfCaches];
                    //                    chatImage.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath] scale:0.0];
                    //
                    //                    if (chatImage.image == nil) {//文件损坏
                    //                        chatImage.image = [UIImage imageNamed:@"FriendsSendsPicturesNo.png"];
                    //                    }
                }else{
                    //需要从网络加载图片
                    [chatImage setImageWithURL:[NSURL URLWithString:notesData.imageCHatData.middleLink] placeholderImage:[UIImage imageNamed:@"FriendsSendsPicturesNo.png"]];
                }
                //                DDLogInfo(@"收到图片大小%d %d",notesData.imageCHatData.imagewidth,notesData.imageCHatData.imageheight);
                if(notesData.imageCHatData.imageheight<=0||notesData.imageCHatData.imagewidth<=0){
                    notesData.imageCHatData.imageheight=120;
                    notesData.imageCHatData.imagewidth=100;
                    DDLogInfo(@"接收的图片尺寸值缺失或异常");
                }
                float iwidth=100;
                float iheight=120;
                if(notesData.imageCHatData.imagewidth>notesData.imageCHatData.imageheight){
                    //宽图
                    iwidth=100;
                    iheight=iwidth/notesData.imageCHatData.imagewidth*notesData.imageCHatData.imageheight;
                    if (iheight<20) {
                        iheight=20;
                    }
                }else{
                    //长图
                    iheight=120;
                    iwidth=iheight/notesData.imageCHatData.imageheight*notesData.imageCHatData.imagewidth;
                    if(iwidth<20)
                        iwidth=20;
                }
                
                int  bubbletotop=6+10+5;             //|-d-气泡
                int  labelLeftMargin=2+1+9;
                int  labelRightMargin=2;
                int  labelTopMargin = 2;        //内容距气泡上边距
                int  bubbletoleft=(12+36+3);
                if(!self.chatType==1){
                    bubbletotop=6;
                }
                chatImage.frame=CGRectMake(9+2+1, 2,  iwidth,  iheight);
                buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, iwidth+labelRightMargin+labelLeftMargin, iheight+labelTopMargin*2);
                bgView.frame=CGRectMake(0, 0, 320, buttBubble.frame.size.height+bubbletotop+6);
                [bgView addSubview:headNameLabel];
            }
            //            headImageView.frame=CGRectMake(0, 0, headImage.frame.size.width, headImage.frame.size.height);
            [headImage addSubview:headImageView];
            [buttBubble addSubview:chatImage];
            [bgView addSubview:headImage];
            [bgView addSubview:buttBubble];
            
            
            //            if (isShowTime) {
            //                returnView=[self margeTimeView:bgView :timeView :returnView];
            //            }else{
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height+5);
            [returnView addSubview:bgView];
            //            }
            
            
            return returnView;
            break;
        }
        case 2:
        {
            //声音
#pragma mark - 声音
            //声音文件
            
            MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            buttBubble.nd=notesData;
            [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
            [buttBubble addTarget:self action:@selector(voiceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *voiceImage=[[UIImageView alloc] init];
            
            UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(voiceLongPress:)];
            [buttBubble addGestureRecognizer:longGesture];
            
            //            NSArray *voiceArray=[notesData.sendContents componentsSeparatedByString:@"#"];
            //          显示声音的lable
            UILabel *secondLabel = [[UILabel alloc] init];
            secondLabel.text =[NSString stringWithFormat:@"%@\"",notesData.chatVoiceData.voiceLenth];
            secondLabel.backgroundColor=[UIColor clearColor];
            secondLabel.font=[UIFont systemFontOfSize:14];
            secondLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
            //  显示红点
            UIView * readStateView=[[UIView alloc]init];
            int iwidth=12+10*[notesData.chatVoiceData.voiceLenth intValue];
            if(iwidth>112){
                iwidth=112;
            }
            
            if (isMyself) {
                
                int  bubbletotop=6;             //|-d-气泡
                int  labelLeftMargin=5;
                int  labelRightMargin=27;
                int  labelTopMargin = 10;        //内容距气泡上边距
                int  bubbletoleft=320-(12+36+3)-iwidth-labelRightMargin-labelLeftMargin;
                voiceImage.frame=CGRectMake(iwidth-6, labelTopMargin,  12,  19);
                buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, iwidth+labelRightMargin+labelLeftMargin, 19+labelTopMargin*2);
                bgView.frame=CGRectMake(0, 0, 320, buttBubble.frame.size.height+bubbletotop+6);
                secondLabel.frame=CGRectMake(buttBubble.frame.origin.x-35-5, bubbletotop+19-7, 35, 14);
                secondLabel.textAlignment=NSTextAlignmentRight;
                buttBubble.imageView.tag=1;
                [buttBubble setTitle:notesData.sendContents forState:UIControlStateNormal];
                buttBubble.titleLabel.alpha=0;
                [voiceImage setImage:[UIImage imageNamed:@"chat_voice_6_pre.png"]];
                //                headImage.frame=CGRectMake(bgView.frame.size.width-50, 5, 40, 40);
                /**
                 *  54,为菊花的宽度，5*2+44=54
                 */
                if (activityView==nil) {
                    //如果没有传进来这个view，创建一个
                    activityView=[[UIView alloc] init];
                    [activityView setBackgroundColor:[UIColor clearColor]];
                    
                }
                activityView.frame=CGRectMake(buttBubble.frame.origin.x-35-18, bgView.frame.size.height/2-8, 15, 15);
                
                if ([notesData.isSend isEqualToString:@"2"]) {
                    //发送失败
                    MenuButton *sendFailedButt=[MenuButton buttonWithType:UIButtonTypeCustom];
                    sendFailedButt.frame=CGRectMake(0, 0, 15, 15);
                    sendFailedButt.nd=notesData;
                    [sendFailedButt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
                    [sendFailedButt setImage:[UIImage imageNamed:@"icon_tip"] forState:UIControlStateNormal];
                    [activityView addSubview:sendFailedButt];
                    [bgView addSubview:activityView];
                }else if([notesData.isSend isEqualToString:@"3"]){
                    
                    ActivituViewBg *activityViewBackgroundView=[[ActivituViewBg alloc] initWithGetActivityView:notesData];
                    activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                        [self sendMessageAgainWithNotesData:nd];
                    };
                    activityViewBackgroundView.frame=CGRectMake(bubbletoleft-20-8, bgView.frame.size.height/2-8, 15, 15);
                    [[QFXmppManager shareInstance]updatejuhua:notesData.contentsUuid withCompletion:^(BOOL ret, NSString *siID) {
                        if (ret) {
                            [activityViewBackgroundView sendsucceed];
                        }else{
                            [activityViewBackgroundView addFailView:notesData];
                            activityViewBackgroundView.sendMessageAgain=^(NotesData *nd){
                                [self sendMessageAgainWithNotesData:nd];
                            };
                        }
                    }];
                    [bgView addSubview:activityViewBackgroundView];
                }else{
                    [bgView addSubview:activityView];
                }
            }else{
                int  bubbletotop=6+10+5;//|-d-名字-d-气泡
                int  labelLeftMargin=27;
                int  labelRightMargin=5;
                int  labelTopMargin = 10;        //内容距气泡上边距
                int  bubbletoleft=(12+36+3);
                if(!self.chatType==1){
                    bubbletotop=6;
                }
                voiceImage.frame=CGRectMake(labelLeftMargin, labelTopMargin,  12,  19);
                buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, iwidth+labelRightMargin+labelLeftMargin, 19+labelTopMargin*2);
                bgView.frame=CGRectMake(0, 0, 320, buttBubble.frame.size.height+bubbletotop+6);
                secondLabel.frame=CGRectMake(buttBubble.frame.origin.x+buttBubble.frame.size.width+10, bubbletotop+19-7, 35, 14);
                secondLabel.textAlignment=NSTextAlignmentLeft;
                readStateView.backgroundColor=[UIColor redColor];
                readStateView.frame=CGRectMake(secondLabel.frame.origin.x+2, secondLabel.frame.origin.y-8, 4, 4);
                readStateView.layer.cornerRadius=2;
                readStateView.clipsToBounds=YES;
                
                //            contentsUuid
                ChatVoiceData *voiceData=[[SqliteDataDao sharedInstanse]queryVoice_tableByMessageid:buttBubble.nd.contentsUuid];
                buttBubble.readStateView=readStateView;
                if (voiceData.isRead==0) {
                    buttBubble.readStateView=readStateView;
                }else{
                    buttBubble.readStateView.hidden=YES;
                }
                //                if (state==0) {
                //                    buttBubble.readStateView=readStateView;
                //                }else{
                //                    buttBubble.readStateView=nil;
                //                }
                buttBubble.imageView.tag=2;
                [voiceImage setImage:[UIImage imageNamed:@"chat_voice_6_1_pre.png"]];
                [bgView addSubview:headNameLabel];
            }
            //            headImageView.frame=CGRectMake(0, 0, headImage.frame.size.width, headImage.frame.size.height);
            [headImage addSubview:headImageView];
            [bgView  addSubview:secondLabel];
            [bgView addSubview:readStateView];
            [bgView addSubview:headImage];
            [buttBubble addSubview:voiceImage];
            buttBubble.voiceImageView=voiceImage;
            [bgView addSubview:buttBubble];
            //            if (isShowTime) {
            //                //                returnView.chatViewType=MyChatViewTypeTime;
            //                returnView=[self margeTimeView:bgView :timeView :returnView];
            //            }else{
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            [returnView addSubview:bgView];
            //            }
            
            
            return returnView;
            break;
        }
        case 4:
        {
            //视频
#pragma mark - 视频
            MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            buttBubble.nd=notesData;
            [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
            [buttBubble setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            [buttBubble addTarget:self action:@selector(camareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            buttBubble.imageView.tag=isMyself ? 1 :2;
            
            /*
             UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(videoLongPress:)];
             [buttBubble addGestureRecognizer:longGesture];
             */
            UIImageView *chatImage=[[UIImageView alloc] init];
            chatImage.tag = 10000+[self.chatNotesDataArray indexOfObject:notesData];
            
            //            NSArray *imagePathNameArray=[notesData.sendContents componentsSeparatedByString:@"#"];
            //            UIImage *image;
            //设置圆角
            //这句代码在这里不可注释掉
            [chatImage.layer setMasksToBounds:YES];
            chatImage.layer.cornerRadius=5;
            if (isMyself) {
                //
                //                NSString *path = [imagePathNameArray objectAtIndex:1];
                //
                //                NSURL * urlStr = [NSURL fileURLWithPath:[path filePathOfCaches]];
                //
                //                image=[VideoUtil thumbnailImageForVideo:urlStr atTime:1];
                //
                //                float imageScale = (175-21-10)/image.size.width;
                //
                //                chatImage.frame=CGRectMake(5, 7, 175-21-10, image.size.height*imageScale);
                //                chatImage.image=image;
                //
                //                buttBubble.frame=CGRectMake(54, 0, 175, image.size.height*imageScale+14);
                //                bgView.frame=CGRectMake(320-50-5-175-54, 10, 50+5+175+54, image.size.height*imageScale+14);
                //                headImage.frame=CGRectMake(bgView.frame.size.width-50, 5, 40, 40);
                //
                //                /**
                //                 *  54,为菊花的宽度，5*2+44=54
                //                 */
                //                if (activityView==nil) {
                //                    //如果没有传进来这个view，创建一个
                //                    activityView=[[UIView alloc] init];
                //                    [activityView setBackgroundColor:[UIColor clearColor]];
                //
                //                }
                //
                //                activityView.frame=CGRectMake(5, bgView.frame.size.height-38, 44, 44);
                //
                //                if ([notesData.isSend isEqualToString:@"0"]) {
                //                    //                    //发送失败
                //
                //                    MenuButton *sendFailedButt=[MenuButton buttonWithType:UIButtonTypeCustom];
                //                    sendFailedButt.frame=CGRectMake(0, 0, 44, 44);
                //                    sendFailedButt.nd=notesData;
                //                    [sendFailedButt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
                //                    [sendFailedButt setImage:[UIImage imageNamed:@"icon_tip"] forState:UIControlStateNormal];
                //                    [activityView addSubview:sendFailedButt];
                //                }
                //
                //                [bgView addSubview:activityView];
                
            }else{
                
                
                NSString * videolink =notesData.chatVideoModel.original_link;
                
                NSString *videoName=[videolink lastPathComponent];
                
                NSString *videoPath=[NSString stringWithFormat:@"%@%@",video_path,videoName];
                
                
                NSFileManager * fileManager = [[NSFileManager alloc]init];
                
                if ([fileManager fileExistsAtPath:[videoPath filePathOfCaches]]){
                    videoPath = [videoPath filePathOfCaches];
                    NSURL *video_file_url = [NSURL fileURLWithPath:videoPath isDirectory:NO];
                    UIImage * video_image=[VideoUtil thumbnailImageForVideo:video_file_url atTime:1];
                    [chatImage setImage:video_image];
                }else{
                    [chatImage setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"Camerapre.png"]];
                }
                
                //                //预设image
                //                float imageScale = (175-21-10)/image.size.width;
                //                chatImage.frame = CGRectMake(21+5, 7, 175-21-10, image.size.height*imageScale);
                //                chatImage.image=image;
                //                buttBubble.frame=CGRectMake(50+5, 25, 175, image.size.height*imageScale+14);
                //                headImage.frame=CGRectMake(10, 25, 40, 40);
                //                bgView.frame=CGRectMake(0, 10, 50+5+175, image.size.height * imageScale+14+25);
                //                headNameLabel.frame=CGRectMake(10, 0, 40, 20);
                //                [bgView addSubview:headNameLabel];
                
                float pointWidth=3;///<气泡尖的宽度
                float chatImageMargin=1;///<视频缩略图边距
                float bubbleWidth=200;///<视频气泡的宽度
                
                //网络请求image后
                float x=chatImage.image.size.width;
                //                chatImage.image=[UIImage imageNamed:@"Camerapre.png"];
                x=chatImage.image.size.width;
                float imageScale;
                if (x != 0) {
                    imageScale = (bubbleWidth-pointWidth-chatImageMargin*2)/chatImage.image.size.width;
                }else{
                    imageScale=1.f;
                }
                
                
                chatImage.frame = CGRectMake(pointWidth+chatImageMargin, chatImageMargin, bubbleWidth-pointWidth-chatImageMargin*2, chatImage.image.size.height*imageScale);
                buttBubble.frame=CGRectMake(50+5, 25, bubbleWidth, chatImage.image.size.height*imageScale+chatImageMargin*2);
                //                headImage.frame=CGRectMake(10, 25, 40, 40);
                bgView.frame=CGRectMake(0, 10, 50+5+bubbleWidth, chatImage.image.size.height * imageScale+chatImageMargin*2+25);
                //                headNameLabel.frame=CGRectMake(10, 0, 80, 20);
                [bgView addSubview:headNameLabel];
            }
            //            headImageView.frame=CGRectMake(0, 0, headImage.frame.size.width, headImage.frame.size.height);
            
            [headImage addSubview:headImageView];
            [buttBubble addSubview:chatImage];
            
            UIImage * playImage = [UIImage imageNamed:@"RYAssetsPicker.bundle/play.png"];
            UIImageView * playView = [[UIImageView alloc]initWithImage:playImage];
            if (isMyself) {
                playView.frame = CGRectMake((buttBubble.frame.size.width - playImage.size.width-14)/2, (buttBubble.frame.size.height - playImage.size.height)/2, playImage.size.width, playImage.size.height);
            }else{
                playView.frame = CGRectMake((buttBubble.frame.size.width - playImage.size.width+14)/2, (buttBubble.frame.size.height - playImage.size.height)/2, playImage.size.width, playImage.size.height);
            }
            
            [buttBubble addSubview:playView];
            [bgView addSubview:headImage];
            
            [bgView addSubview:buttBubble];
            
            //            if (isShowTime) {
            //                returnView.chatViewType=MyChatViewTypeTime;
            //                returnView=[self margeTimeView:bgView :timeView :returnView];
            //            }else{
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            [returnView addSubview:bgView];
            //            }
            
            
            return returnView;
            break;
        }
        case 5:{
            //草稿 有复用
            break;
        }
        case 6:
        {
            break;
        }
        case 7:
        {
#pragma mark - 群组信息
            bgView = [self groupMessage:notesData];
            bgView.nd=notesData;
            if(notesData.sendContents.length>5){
                NSRange tt=[notesData.sendContents rangeOfString:@"修改群名称为"];
                if(tt.length){
                    NSString *qunName = [[SqliteDataDao sharedInstanse]getRoomInfoModelWithroomJid:_toUserId].roomName;
                    if (qunName.length>10) {
                        NSString *  titleStr=[qunName substringToIndex:8];
                        titleStr=[NSString stringWithFormat:@"%@...",titleStr];
                        self.title=titleStr;
                    }else{
                        self.title=qunName;
                    }
                }
            }
            
            //            returnView.chatViewType=MyChatViewTypeGroup;
            //
            //            if (isShowTime) {
            //
            //                returnView=[self margeTimeView:bgView :timeView :returnView];
            //            }
            //            else{
            ////                returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            //                [returnView addSubview:bgView];
            //            }
            
            return bgView;
            break;
        }
        case 8:
        {
#pragma mark -  转发服务号
            NSDictionary * dicUrl=[NSJSONSerialization JSONObjectWithData:[notesData.sendContents dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            
            NSString *sendContentStr=dicUrl[@"contentExtra"];
            if (sendContentStr.length<=0) {
                sendContentStr=dicUrl[@"sendContents"];
            }
            
            NSArray *components = [sendContentStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
            
            
            NSMutableArray *componentsToKeep = [NSMutableArray array];
            
            for (int i = 0; i < [components count]; i = i + 2) {
                
                [componentsToKeep addObject:[components objectAtIndex:i]];
                
            }
            
            NSString *plainText = [componentsToKeep componentsJoinedByString:@""];
            
            CGRect buttonFram;
            
            MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            buttBubble.nd=notesData;
            buttBubble.imageView.tag=isMyself ? 1 :2;
            [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
            [buttBubble addTarget:self action:@selector(transBubbleButtClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(transmitLongPress:)];
            [buttBubble addGestureRecognizer:longGesture];
            
            CGFloat buttWidth=200;
            CGFloat buttHight=110;
            if (isMyself) {
                buttonFram=CGRectMake(2, 2, buttWidth-21-2, buttHight+10);
                buttBubble.frame=CGRectMake(54, 0, buttWidth, buttHight+14);
                bgView.frame=CGRectMake(320-50-5-buttWidth-54, 10, 50+5+buttWidth+54, buttHight+14);
                //                headImage.frame=CGRectMake(bgView.frame.size.width-50, 5, 40, 40);
            }else{
                buttonFram=CGRectMake(20, 2, buttWidth-21-2, buttHight+10);
                buttBubble.frame=CGRectMake(55, 25, buttWidth, buttHight+14);
                bgView.frame=CGRectMake(0, 10, 50+5+buttWidth, buttHight+14+25);
                //                headImage.frame=CGRectMake(10, 25, 40, 40);
                //                headNameLabel.frame=CGRectMake(10, 0, 80, 20);
                [bgView addSubview:headNameLabel];
            }
            //            headImageView.frame=CGRectMake(0, 0, headImage.frame.size.width, headImage.frame.size.height);
            
            
            UIView *bubbleBgView=[[UIView alloc] initWithFrame:buttonFram];
            bubbleBgView.backgroundColor=[UIColor whiteColor];
            bubbleBgView.layer.cornerRadius=3;
            //            bubbleBgView.layer.shouldRasterize=YES;
            bubbleBgView.userInteractionEnabled=NO;
            
            
            UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(5, 5, buttonFram.size.width-10, 30)];
            titleLabel.backgroundColor=[UIColor clearColor];
            titleLabel.text=dicUrl[@"title"];
            titleLabel.font=[UIFont systemFontOfSize:20];
            titleLabel.textColor=[UIColor blackColor];
            [bubbleBgView addSubview:titleLabel];
            
            UIImageView *bubbleBgViewImage=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5+30+5,buttonFram.size.width-10,50)];
            [bubbleBgViewImage setImageWithURL:[NSURL URLWithString:dicUrl[@"picUrl"]] placeholderImage:[UIImage imageNamed:@"FriendsSendsPicturesNo"]];
            [bubbleBgView addSubview:bubbleBgViewImage];
            
            UILabel *detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(5, bubbleBgViewImage.frame.origin.y+bubbleBgViewImage.frame.size.height+3, bubbleBgViewImage.frame.size.width, 30)];
            detailLabel.textColor=[UIColor blackColor];
            detailLabel.text=plainText;
            detailLabel.backgroundColor=[UIColor clearColor];
            [bubbleBgView addSubview:detailLabel];
            
            [buttBubble addSubview:bubbleBgView];
            
            
            [headImage addSubview:headImageView];
            
            [bgView addSubview:buttBubble];
            
            [bgView addSubview:headImage];
            
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            [returnView addSubview:bgView];
            
            return returnView;
            break;
        }
        case 9:{
            
#pragma mark - 视频通话
            //声音文件
            MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            buttBubble.nd=notesData;
            [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
            //            [buttBubble addTarget:self action:@selector(voiceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *markImage=[[UIImageView alloc] init];
            
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 200)];
            secondLabel.text =[NSString stringWithFormat:@"%@",notesData.sendContents];
            secondLabel.backgroundColor=[UIColor clearColor];
            secondLabel.font=[UIFont systemFontOfSize:14];
            //            if(isMyself){
            //                secondLabel.textColor=[UIColor whiteColor];
            //            }else{
            //                secondLabel.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            //            }
            secondLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            [secondLabel sizeToFit];
            CGSize size1=secondLabel.frame.size;
            
            int labelTopMargin = 12;//label距气泡上边距
            int labelLeftmargin;//label距气泡左边距
            int labelRightmargin;//label距气泡右边距
            int bubbletoleft;
            int bubbletotop;
            int imageLeftmargin;//
            int imageRightmargin;
            //根据不同的人发的信息  来设置view的位置和大小
            if (isMyself) {
                bubbletoleft=320-(12+36+3)-size1.width-23-14-11-30;//23=bubbleWargin+labeLeftlMargin
                bubbletotop=6;//|-d-气泡
                labelLeftmargin=14;
                labelRightmargin=23;
                imageRightmargin=30+11;
                imageLeftmargin=14+size1.width+11;
                markImage.image=[UIImage imageNamed:@"bubble_vedio_right.png"];
            }else{
                bubbletoleft=12+36+3;//|-d-头像w-d-气泡
                bubbletotop=6+5+10;//|-d-名字-d-气泡
                labelLeftmargin=23+30+11;
                labelRightmargin=16.5;
                imageLeftmargin=23;
                imageRightmargin=0;
                if(!self.chatType==1){
                    bubbletotop=6;
                }
                markImage.image=[UIImage imageNamed:@"bubble_vedio_left.png"];
            }
            bgView.frame=CGRectMake(0, 0, 320, size1.height+labelTopMargin*2+bubbletotop+6);
            buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, size1.width+labelRightmargin+labelLeftmargin+imageRightmargin, size1.height+labelTopMargin*2);
            secondLabel.frame=CGRectMake(labelLeftmargin, labelTopMargin, size1.width, size1.height);
            markImage.frame=CGRectMake(imageLeftmargin, 4, 30, 30);
            [headImage addSubview:headImageView];
            //            [bgView  addSubview:secondLabel];
            [bgView addSubview:headImage];
            [buttBubble addSubview:markImage];
            [buttBubble addSubview:secondLabel];
            [bgView addSubview:buttBubble];
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            [returnView addSubview:bgView];
            return  returnView;
            break;
        }
        case 10:
        {
            
#pragma mark - 音频通话
            //声音文件
            MenuButton *buttBubble=[MenuButton buttonWithType:UIButtonTypeCustom];
            buttBubble.nd=notesData;
            [buttBubble setBackgroundImage:newImage forState:UIControlStateNormal];
            //            [buttBubble addTarget:self action:@selector(voiceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *markImage=[[UIImageView alloc] init];
            
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 200)];
            secondLabel.text =[NSString stringWithFormat:@"%@",notesData.sendContents];
            secondLabel.backgroundColor=[UIColor clearColor];
            secondLabel.font=[UIFont systemFontOfSize:14];
            //            if(isMyself){
            //                secondLabel.textColor=[UIColor whiteColor];
            //            }else{
            //                secondLabel.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            //            }
            secondLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            [secondLabel sizeToFit];
            CGSize size1=secondLabel.frame.size;
            
            
            int labelTopMargin = 12;//label距气泡上边距
            int labelLeftmargin;//label距气泡左边距
            int labelRightmargin;//label距气泡右边距
            int bubbletoleft;
            int bubbletotop;
            int imageLeftmargin;//
            int imageRightmargin;
            //根据不同的人发的信息  来设置view的位置和大小
            if (isMyself) {
                bubbletoleft=320-(12+36+3)-size1.width-23-14-11-30;//23=bubbleWargin+labeLeftlMargin
                bubbletotop=6;//|-d-气泡
                labelLeftmargin=14;
                labelRightmargin=23;
                imageRightmargin=30+11;
                imageLeftmargin=14+size1.width+11;
                markImage.image=[UIImage imageNamed:@"bubble_voice_right.png"];
            }else{
                bubbletoleft=12+36+3;//|-d-头像w-d-气泡
                bubbletotop=6+10+5;//|-d-名字-d-气泡
                labelLeftmargin=23+30+11;
                labelRightmargin=16.5;
                imageLeftmargin=23;
                imageRightmargin=0;
                if(!self.chatType==1){
                    bubbletotop=6;
                }
                markImage.image=[UIImage imageNamed:@"bubble_voice_left.png"];
            }
            bgView.frame=CGRectMake(0, 0, 320, size1.height+labelTopMargin*2+bubbletotop+6);
            buttBubble.frame=CGRectMake(bubbletoleft, bubbletotop, size1.width+labelRightmargin+labelLeftmargin+imageRightmargin, size1.height+labelTopMargin*2);
            secondLabel.frame=CGRectMake(labelLeftmargin, labelTopMargin, size1.width, size1.height);
            markImage.frame=CGRectMake(imageLeftmargin, 4, 30, 30);
            [headImage addSubview:headImageView];
            //            [bgView  addSubview:secondLabel];
            [bgView addSubview:headImage];
            [buttBubble addSubview:markImage];
            [buttBubble addSubview:secondLabel];
            [bgView addSubview:buttBubble];
            returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
            [returnView addSubview:bgView];
            return  returnView;
            break;
        }
        default:
            break;
    }
    return nil;
}
#pragma mark 气泡结束
-(ChatView *)timeView:(NSString *)timeStr{
    //时间
    //刚开始不能确定view的大小，所以设置为CGRectZero
    ChatView *bgView=[[ChatView alloc] initWithFrame:CGRectZero];
    UIFont *font=[UIFont systemFontOfSize:12];
    
    CGSize timeLabelSize=[timeStr sizeWithFont:font constrainedToSize:CGSizeMake(200, 10) lineBreakMode:NSLineBreakByCharWrapping];
    //    UIImage *img=[UIImage imageNamed:@"time_label_bg"];
    //    //对图片进行边帽设置，可以把图片分为4个部分，取大约值即可，将来放大的话 四个角不变，其余部分会自动有规则的填充
    //    UIImage *newImage=[img stretchableImageWithLeftCapWidth:30 topCapHeight:6];
    //
    //    UIImageView *bgImageView=[[UIImageView alloc] initWithFrame:CGRectMake((320-timeLabelSize.width-10)/2-2, 8, timeLabelSize.width+10+4, 20+4)];
    //    bgImageView.image=newImage;
    //    bgImageView.layer.cornerRadius=3;
    //    bgImageView.layer.masksToBounds=YES;
    //    bgImageView.layer.shouldRasterize=YES;
    //    bgImageView.backgroundColor=[UIColor clearColor];
    //    [bgView addSubview:bgImageView];
    
    UILabel *timeLabel=[[UILabel alloc] init];
    timeLabel.frame=CGRectMake((320-timeLabelSize.width-10)/2, 10, timeLabelSize.width+10, 10);
    timeLabel.backgroundColor=[UIColor clearColor];
    timeLabel.textAlignment=NSTextAlignmentCenter;
    timeLabel.text=timeStr;
    timeLabel.textColor=[UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1];
    timeLabel.font=[UIFont systemFontOfSize:10];
    [timeLabel.layer setMasksToBounds:YES];
    timeLabel.layer.cornerRadius=3;
    bgView.frame=CGRectMake(0, 0, 320, 20);
    
    bgView.chatViewType=MyChatViewTypeTime;
    [bgView addSubview:timeLabel];
    return bgView;
}
-(ChatView *)groupMessage:(NotesData *)nd{
    //刚开始不能确定view的大小，所以设置为CGRectZero
    ChatView *bgView=[[ChatView alloc] initWithFrame:CGRectZero];
    bgView.chatViewType=MyChatViewTypeGroup;
    bgView.backgroundColor=[UIColor clearColor];
    UIFont *font=[UIFont systemFontOfSize:11];
    CGSize label_group_Size=[nd.sendContents sizeWithFont:font constrainedToSize:CGSizeMake(200, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    
    UIView *bgImageView=[[UIView alloc] initWithFrame:CGRectMake((320-label_group_Size.width-10)/2-2, 6, label_group_Size.width+10+4, label_group_Size.height+14)];
    //    bgImageView.image=newImage;
    //    bgImageView.layer.shouldRasterize=YES;
    bgImageView.layer.cornerRadius=12.5;
    bgImageView.layer.masksToBounds=YES;
    bgImageView.backgroundColor=[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [bgView addSubview:bgImageView];
    
    UILabel *label_group=[[UILabel alloc] init];
    label_group.frame=CGRectMake((320-label_group_Size.width-10)/2, 13, label_group_Size.width+10, label_group_Size.height);
    label_group.numberOfLines=0;
    label_group.lineBreakMode=NSLineBreakByCharWrapping;
    label_group.backgroundColor=[UIColor clearColor];
    label_group.textAlignment=NSTextAlignmentCenter;
    label_group.text=nd.sendContents;
    label_group.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    label_group.font=[UIFont systemFontOfSize:11];
    label_group.layer.masksToBounds=YES;
    label_group.layer.cornerRadius=3;
    bgView.frame=CGRectMake(0, 0, 320, label_group_Size.height+14+12);
    [bgView addSubview:label_group];
    return bgView;
}

-(ChatView *)margeTimeView:(ChatView *)bgView :(UIView *)timeView :(ChatView *)returnView{
    //    UIView *myBgView=[[UIView alloc] initWithFrame:CGRectZero];
    //    myBgView.backgroundColor=[UIColor clearColor];
    returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height+timeView.frame.size.height);
    [returnView addSubview:timeView];
    bgView.frame=CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y+timeView.frame.size.height, bgView.frame.size.width, bgView.frame.size.height);
    [returnView addSubview:bgView];
    return returnView;
}


//图片方向矫正
-(UIImage *)fixOrientation:(UIImage *)aImage {
    if (aImage == nil) {
        return nil;
    }
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = aImage.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
        {
            transform = CGAffineTransformIdentity;
            break;
        }
        case UIImageOrientationUpMirrored: //EXIF =
        {
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        }
        case UIImageOrientationDown: //EXIF = 3
        {
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
        case UIImageOrientationDownMirrored: //EXIF = 4
        {
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        }
        case UIImageOrientationLeftMirrored: //EXIF = 5
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationLeft: //EXIF = 6
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationRightMirrored: //EXIF = 7
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        case UIImageOrientationRight: //EXIF = 8
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        default:
        {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
        }
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) { CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

#pragma mark - 图片
/**
 *  根据type来拼接url串,来区分是网络图片还是本地图片,0网络图片,1本地图片,2为空(理论不会出现)
 *
 *  @param url
 *  @param type
 *
 *  @return
 */
-(NSString *)jointIamgeUrl:(NSString *)url urlType:(int)type{
    NSString *str=[NSString stringWithFormat:@"%d#%@",type,url];
    return str;
}

-(void)imageButtonClick:(MenuButton *)sender{
    [self.view endEditing:YES];
    
    
    if ([self tagarWhenEditing:sender.nd]) {
        return;
    }
    
    NSMutableArray *retinaImageUrlArray=[[NSMutableArray alloc] init];
    
    for (NotesData *_nd in imageUrlArray) {
        
        NSString *image_url=nil;
        
        if (_nd.imageCHatData.imagePath.length>0) {
            image_url=[self jointIamgeUrl:_nd.imageCHatData.imagePath urlType:1];
        }else{
            if (image_url.length<=0) {
                if (_nd.imageCHatData.originalLink.length>0) {
                    image_url=[self jointIamgeUrl: _nd.imageCHatData.originalLink urlType:0];
                }else{
                    image_url=[self jointIamgeUrl:@"imageUrl_null" urlType:2];
                }
            }
        }
        [retinaImageUrlArray addObject:image_url];
    }
    
    PhotoViewController *photoVC=[[PhotoViewController alloc] init];
    photoVC.photos=retinaImageUrlArray;
    photoVC.index=[imageUrlArray indexOfObject:sender.nd];
    photoVC.nd=sender.nd;
    photoVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:photoVC animated:YES];
    
}

#pragma mark - 气泡点击
-(void)bubbleButtClick:(MenuButton *)butt{
    if ([self tagarWhenEditing:butt.nd]) {
        return;
    }
}
-(void)transBubbleButtClick:(MenuButton *)butt{
    
    if ([self tagarWhenEditing:butt.nd]) {
        return;
    }
    
    NotesData *notesData=[[NotesData alloc] init];
    
    if (!butt.nd) {
        return;
    }
    
    if([self tagarWhenEditing:butt.nd]){
        return;
    }
    //    notesData.serviceNews=butt.nd.serviceNews;
    NSString *sendContents=butt.nd.sendContents;
    NSDictionary * dicUrl=[NSJSONSerialization JSONObjectWithData:[sendContents dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    notesData.serviceNews=sendContents;
    notesData.sendContents=dicUrl[@"contentExtra"];
    if (notesData.sendContents.length<=0) {
        /**
         *  为新内容的服务号(多条)
         */
        notesData.sendContents=dicUrl[@"sendContents"];
    }
    NSString *regulaURl =@"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%%_\\./-~-]*)?";
    NSPredicate *regextestURL = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regulaURl];
    if ([regextestURL evaluateWithObject:notesData.sendContents]) {
        ServiceNumberWebViewController *snWebView=[[ServiceNumberWebViewController alloc]init];
        snWebView.snUrl=notesData.sendContents;
        snWebView.snName=dicUrl[@"title"];
        snWebView.isSider=NO;
        snWebView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:snWebView animated:YES];
    }else{
        ServiceNumberMsgDetailViewController *snMsgDetail=[[ServiceNumberMsgDetailViewController alloc]init];
        snMsgDetail.notesData=notesData;
        snMsgDetail.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:snMsgDetail animated:YES];
    }
    
}

#pragma mark - 保存图片
BOOL isSaveImage = NO;
UIImageView  *imageView;
-(void)saveImage:(UILongPressGestureRecognizer *)longRecognizer{
    if (isSaveImage == NO) {
        //        DDLogInfo(@"BAO");
        
    }
    //移除子菜单
    [self removeSubmenu];
    
    
    imageView=(UIImageView *)longRecognizer.view;
    UIActionSheet * actionSheet1=(UIActionSheet *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:actionSheet_tag];
    if (!actionSheet1) {
        UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到本地", nil];
        actionSheet.tag=actionSheet_tag;
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    
    
    
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case alert_deleta_content:
        {
            if (buttonIndex == 0) {
                [self cellDelete];
                [self messageDelete:_selectNotesData];
            }
            break;
        }
        default:
            break;
    }
}
-(void)cellDelete{
    //删除操作,考虑时间问题
    /**
     *  如果是最后一条,且上一个为时间view,连带着把时间view删除掉
     *  如果是最后一条,上一个不为时间view,不做特殊处理
     *  如果不是最后一条,上一个为时间view,但是下一个不是时间view,不做特殊处理
     *  如果不是最后一条,上一个为时间view,但是下一个是时间view,连带着把时间view删除掉
     *  如果不是最后一条,上一个不为时间view,不做处理
     *  补：如果删除cell是第一个cell，以上情况都不需要特殊处理，特殊处理只是为了顺带处理时间cell
     */
    ChatCell *cell=[cellDict objectForKey:_selectNotesData.contentsUuid];
    NSString *lastViewUuid=((ChatView *)[chatArray lastObject]).nd.contentsUuid;
    NSString *cellUuuid=cell.chatView.nd.contentsUuid;
    NSMutableArray *indexPathArray=[[NSMutableArray alloc] init];
    NSIndexPath *indexPath=[_chatTable indexPathForCell:cell];//内容cell的index
    if (!indexPath) {
        indexPath=[_chatTable indexPathForRowAtPoint:cell.center];
    }
    [indexPathArray addObject:indexPath];
    if(indexPath.row!=0){
        if ([cellUuuid isEqualToString:lastViewUuid]) {
            //是最后一条
            
            ChatView *lastChatView=[chatArray objectAtIndex:chatArray.count -2];//上一个view
            
            if (lastChatView.chatViewType==MyChatViewTypeTime) {
                //上一个view为时间view
                [chatArray removeObject:lastChatView];
                NSString *messageUuid=lastChatView.nd.contentsUuid;
                if (!messageUuid) {
                    messageUuid=lastChatView.nd.serverTime;
                }
                if (lastChatView.chatViewType==MyChatViewTypeTime) {
                    messageUuid=[NSString stringWithFormat:@"time_%@",messageUuid];
                }
                
                ChatCell *lastCell=[cellDict objectForKey:messageUuid];
                NSIndexPath *lastIndexPath=[_chatTable indexPathForCell:lastCell];
                if (!lastIndexPath) {
                    lastIndexPath=[_chatTable indexPathForRowAtPoint:lastCell.center];
                }
                [indexPathArray addObject:lastIndexPath];
                
                [cellDict removeObjectForKey:messageUuid];
            }
            
        }else{
            //不是最后一条
            
            ChatView *nextChatView=[chatArray objectAtIndex:[chatArray indexOfObject:cell.chatView]+1];//下一个view
            
            ChatView *lastChatView=[chatArray objectAtIndex:[chatArray indexOfObject:cell.chatView]-1];//上一个view
            
            if (lastChatView.chatViewType==MyChatViewTypeTime) {
                //上一个为时间view
                if (nextChatView.chatViewType==MyChatViewTypeTime) {
                    //下一个为时间view,删除掉上一个view
                    [chatArray removeObject:lastChatView];
                    NSString *messageUuid=lastChatView.nd.contentsUuid;
                    if (!messageUuid) {
                        messageUuid=lastChatView.nd.serverTime;
                    }
                    if (lastChatView.chatViewType==MyChatViewTypeTime) {
                        messageUuid=[NSString stringWithFormat:@"time_%@",messageUuid];
                    }
                    
                    ChatCell *lastCell=[cellDict objectForKey:messageUuid];
                    NSIndexPath *lastIndexPath=[_chatTable indexPathForCell:lastCell];
                    if (!lastIndexPath) {
                        lastIndexPath=[_chatTable indexPathForRowAtPoint:lastCell.center];
                    }
                    [indexPathArray addObject:lastIndexPath];
                    
                    [cellDict removeObjectForKey:messageUuid];
                }
            }
        }
    }
    [chatArray removeObject:cell.chatView];
    
    [cellDict removeObjectForKey:_selectNotesData.contentsUuid];
    
    [[SqliteDataDao sharedInstanse] deleteChatDataWithMessageId:@[_selectNotesData.contentsUuid]];
    
    [_chatTable beginUpdates];
    [_chatTable deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationRight];
    [_chatTable endUpdates];
}
-(void)messageDelete:(NotesData *)notesData{
    
    //    [[SqliteDataDao sharedInstanse] deleteChatDataWithMessageId:@[notesData.contentsUuid]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    int messageType=[notesData.typeMessage integerValue];
    switch (messageType) {
        case 0:
        {
            //文字
            break;
        }
        case 1:
        {
            //图片
            [fileManager removeItemAtPath:[notesData.imageCHatData.imagePath filePathOfCaches] error:nil];
            break;
        }
        case 2:
        {
            [fileManager removeItemAtPath:[notesData.chatVoiceData.voicePath filePathOfCaches] error:nil];
            break;
        }
        default:
            break;
    }
    
    
}
#pragma mark - UIActionSheet delegate #####重发消息
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    /**
     *  根据tag值区分actionSheet
     */
    switch (actionSheet.tag) {
        case actionSheet_AllNumber:
        {
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.phone]]];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.tele]]];
                    break;
                case 2:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.shotNum]]];
                    break;
                default:
                    break;
            }
            break;
            
        }
        case actionSheet_Notele:{
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.phone]]];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.shotNum]]];
                    break;
                default:
                    break;
            }
            break;
            
        }
        case actionSheet_NoshortNum:{
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.phone]]];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.member_userInfo.tele]]];
                    break;
                default:
                    break;
            }
            break;
            
        }
            
        case actionSheet_tag:
        {
            switch (buttonIndex) {
                case 1:
                    isSaveImage = NO;
                    break;
                case 0:
                    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                    break;
                default:
                    break;
            }
            break;
        }
        case actionSheet_message_send_again:
        {
            switch (buttonIndex) {
                case 1:
                    //取消,什么也不需要做
                    
                    break;
                case 0:
                {
                    
                    //再次发送
                    is_send_message_again=YES;
                    NotesData * nd=_selectNotesData;
                    if ([nd.typeMessage isEqualToString:@"0"]) {
                        //文字
                        [self cellDelete];
                        [self sendMessage:nil messageType:@"0" message:nd.sendContents withNotesData:nd];
                    }else{
                        //声音，图片，视频等
                        
                        [self cellDelete];
                        
                        isDelet=NO;
                        int messageType=[nd.typeMessage intValue];
                        switch (messageType) {
                            case 1:
                            {
                                nd.isSend=0;
                                ActivituViewBg *activityBg=[[ActivituViewBg alloc] initWithGetActivityView:nd];
                                activityBg.sendMessageAgain=^(NotesData *nd){
                                    [self sendMessageAgainWithNotesData:nd];
                                };
                                ChatView *v=[self getChatView:nd from:YES activityViewV:activityBg];
                                [chatArray addObject:v];
                                [_chatNotesDataArray addObject:nd];
                                [self reloadChatTabel];
                                MessageModel *mm = [[MessageModel alloc] init];
                                mm.chatType=self.chatType;
                                mm.fileType=1;
                                mm.messageID=nd.contentsUuid;
                                mm.receivedTime=nd.serverTime;
                                mm.msg =@" ";
                                mm.from = [ConstantObject sharedConstant].userInfo.imacct;
                                mm.to  = _toUserId;
                                mm.thread=@"";
                                
                                mm.imageChatData=nd.imageCHatData;
                                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                                [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
                                if (nd.imageCHatData.middleLink.length<=0) {
                                    //有路径说明图片已经上传服务器成功,但是没有发送到openfire
                                    
                                    [self uploadImage:nd.imageCHatData.imageName imagePath:nd.imageCHatData.imagePath uuid:nd.contentsUuid avtivtyView:activityBg noteData:nd];
                                    
                                }else{
                                    
                                    NSDictionary *_dict=@{key_messageImage_image_name: nd.imageCHatData.imageName,
                                                          key_messageImage_middle_link:nd.imageCHatData.middleLink,
                                                          key_messageImage_original_link:nd.imageCHatData.originalLink,
                                                          key_messageImage_small_link:nd.imageCHatData.smallLink,
                                                          key_messageImage_image_width:[NSString stringWithFormat:@"%d",nd.imageCHatData.imagewidth],key_messageImage_image_height:[NSString stringWithFormat:@"%d",nd.imageCHatData.imageheight]};
                                    [[QFXmppManager shareInstance] sendMessage:_dict chatType:self.chatType withType:1 toUser:_toUserId messageId:nd.contentsUuid withCompletion:^(BOOL ret, NSString *siID) {
                                        if (ret) {
                                            DDLogInfo(@"发送图片成功");
                                            [activityBg sendsucceed];
                                            
                                        }else{
                                            DDLogInfo(@"发送图片失败");
                                            //把请求下来的值带上,再次发送的时候如果有这个数据就是,图片上传成功,但是消息没有发出去
                                            [activityBg addFailView:nd];
                                            activityBg.sendMessageAgain=^(NotesData *nd){
                                                [self sendMessageAgainWithNotesData:nd];
                                            };
                                        }
                                    }];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:nil];
                                }
                                break;
                            }
                            case 2:
                            {
                                NSString *fileName=[NSString stringWithFormat:@"%@_%@_audiorecord.mp3",[[nd.chatVoiceData.voicePath lastPathComponent] stringByDeletingPathExtension],nd.chatVoiceData.voiceLenth];
                                nd.isSend=0;
                                ActivituViewBg *activityBg=[[ActivituViewBg alloc] initWithGetActivityView:nd];
                                
                                ChatView *v=[self getChatView:nd from:YES activityViewV:activityBg];
                                
                                [chatArray addObject:v];
                                [_chatNotesDataArray addObject:nd];
                                [self reloadChatTabel];
                                MessageModel *mm = [[MessageModel alloc] init];
                                mm.chatType=self.chatType;
                                mm.fileType=2;
                                mm.messageID=nd.contentsUuid;
                                mm.receivedTime=nd.serverTime;
                                mm.msg =@" ";
                                mm.from = [ConstantObject sharedConstant].userInfo.imacct;
                                mm.to  = _toUserId;
                                mm.thread=@"";
                                mm.chatVoiceData=nd.chatVoiceData;
                                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                                [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
                                
                                if (nd.chatVoiceData.voiceUrl.length<=0) {
                                    
                                    [self uploadVoice:fileName imagePath:nd.chatVoiceData.voicePath uuid:nd.contentsUuid avtivtyView:activityBg noteData:nd];
                                    
                                }else{
                                    NSDictionary *_dict=@{key_messageVoice_name: fileName,
                                                          key_messageVoice_url:nd.chatVoiceData.voiceUrl,
                                                          key_messageVoice_length:nd.chatVoiceData.voiceLenth};
                                    [[QFXmppManager shareInstance] sendMessage:_dict chatType:self.chatType withType:kMsgVoice toUser:_toUserId messageId:nd.contentsUuid withCompletion:^(BOOL ret, NSString *siID) {
                                        if (ret) {
                                            DDLogInfo(@"发送语音成功");
                                            [activityBg sendsucceed];
                                            
                                        }else{
                                            DDLogInfo(@"发送语音失败");
                                            [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:nd.contentsUuid state:@"2"];
                                            [activityBg addFailView:nd];
                                            activityBg.sendMessageAgain=^(NotesData *nd){
                                                [self sendMessageAgainWithNotesData:nd];
                                            };
                                        }
                                    }];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:nil];
                                }
                                break;
                            }
                            case 5:
                            {
                                
                                break;
                            }
                            default:
                                break;
                        }
                        
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    UIAlertView *alertView;
    
    if (error != NULL){
        alertView = [[UIAlertView alloc] initWithTitle:@"保存错误" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }else{
        [myApp showWithCustomView:nil detailText:@"保存成功" isCue:0 delayTime:1 isKeyShow:NO];
    }
    
}
#pragma mark - 点击视频图片按钮播放视频
-(void)camareButtonClick:(MenuButton *)sender{
    [self.navigationController.view endEditing:YES];
    
    NotesData *notesData=sender.nd;
    if ([self tagarWhenEditing:notesData]) {
        return;
    }
    
    NSString * videolink =notesData.chatVideoModel.original_link;
    if (videolink.length<=0) {
        return;
    }
    
    NSString *videoName=[videolink lastPathComponent];
    
    NSString *videoPath=[NSString stringWithFormat:@"%@%@",video_path,videoName];
    
    
    NSFileManager * fileManager = [[NSFileManager alloc]init];
    
    if ([fileManager fileExistsAtPath:[videoPath filePathOfCaches]]) {
        videoPath = [videoPath filePathOfCaches];
        NSURL * fileUrl = [NSURL fileURLWithPath:videoPath isDirectory:NO];
        [self playVideo:fileUrl];
    }else{
        NSURL *videoUrl=[NSURL URLWithString:videolink];
        [self downVideoWithPath:videoPath fileUrl:videoUrl type:4];
    }
    
    
    
}
-(void)playVideo:(NSURL *)url{
    if (self.moviePlayer) {
        self.moviePlayer=nil;
    }
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    self.moviePlayer.contentURL = url;
    //充满player bounds,可以设置全屏，非全屏
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    [self.moviePlayer prepareToPlay];
    
    //非全屏frame设置
    //    [self.player.view setFrame:self.view.bounds];
    //    [self.view addSubview:self.player.view];
    
    //全屏frame设置
    [self.moviePlayer.view setFrame:[[UIScreen mainScreen] bounds]];  // player的尺寸
    [self.navigationController.view addSubview:self.moviePlayer.view];
    
    //移除子菜单
    [self removeSubmenu];
}
-(void)scrollViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event whichView:(id)scrollView{
    //    [self.myImageView setHidden:YES];
    [self.myScrollView setHidden:YES];
    //下面两句代码顺序不能颠倒
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBarHidden=NO;
    
}


#pragma mark UIScrollView delegate methods
//实现图片的缩放
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.myImageView;
}
//实现图片在缩放过程中居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.myImageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

#pragma mark - 声音播放

- (void)voiceAmrToWavMm:(MenuButton *)mm savePath:(NSString *)filePath
{
    _isPlay=YES;
    
    NSString *wavfilePath=[[NSString stringWithFormat:@"%@%@",voice_path,mm.nd.chatVoiceData.voiceName] filePathOfCaches];
    [VoiceConverter amrToWav:[filePath filePathOfCaches] wavSavePath:wavfilePath];
    mm.nd.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,mm.nd.chatVoiceData.voiceName];
    [self voiceButtonClick:mm];
    //    mm.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,mm.chatVoiceData.voiceName];
    //    [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
}


-(void)voiceButtonClick:(MenuButton *)sender{
    
    
    
    if ([self tagarWhenEditing:sender.nd]) {
        return;
    }
    //  处理公众号的
    if (!sender.nd.chatVoiceData.voicePath) {
        [[DownManage sharedDownload] downloadWhithUrl:sender.nd.chatVoiceData.voiceUrl fileName:sender.nd.chatVoiceData.voiceName type:2 downFinish:^(NSString *filePath) {
            NSString *fileExtention = [filePath pathExtension];
            if([fileExtention isEqualToString:@"amr"])
            {
                [self voiceAmrToWavMm:sender savePath:filePath];
            }else
            {
                sender.nd.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,sender.nd.chatVoiceData.voiceName];
                
                //                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                //                [self getDelegate:mm];
                [self voiceButtonClick:sender];
            }
            //            [self voiceAmrToWavMm:sender savePath:filePath];
        } downFail:^(NSError *error) {
            
        }];
        return;
    }
    
    UIImageView *imageView=sender.voiceImageView;
    if (sender.imageView.tag==1) {
        //自己的
        imageView.animationImages=@[[UIImage imageNamed:@"chat_voice_2.png"],[UIImage imageNamed:@"chat_voice_4.png"],[UIImage imageNamed:@"chat_voice_6.png"]];
        
    }else if (sender.imageView.tag==2){
        //对方的
        imageView.animationImages=@[[UIImage imageNamed:@"chat_voice_2_1.png"],[UIImage imageNamed:@"chat_voice_4_1.png"],[UIImage imageNamed:@"chat_voice_6_1.png"]];
    }
    if ([player isPlaying]) {
        [player stop];
        [_lastImageView stopAnimating];
    }
    
    if (sender.selected) {
        //跳过
    }else{
        if (sender.readStateView) {
            sender.readStateView.hidden=YES;
            [sender.readStateView removeFromSuperview];
            sender.readStateView=nil;
        }
        
        //      修改消息的未读状态
        [[SqliteDataDao sharedInstanse]updateVoice_tableByMessageId:sender.nd.contentsUuid];
        
        _lastImageView  = imageView;
        [self playVoice:sender.nd.chatVoiceData.voicePath];
        imageView.animationDuration=1;
        imageView.animationRepeatCount = [sender.nd.chatVoiceData.voiceLenth intValue];
        [imageView startAnimating];
        //移除子菜单
        [self removeSubmenu];
    }
    sender.selected=!sender.selected;
    
}

-(void)playVoice:(NSString *)path{
    
    //    从path路径中 加载播放器
    //得到AVAudioSession单例对象
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置类别,此处只支持支持播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    NSError *error_1=nil;
    NSData *dataAudio = [NSData dataWithContentsOfFile:[path filePathOfCaches] options:0 error:&error_1];
    NSError *error=nil;
    player = [[AVAudioPlayer alloc]initWithData:dataAudio error:&error];
    player.delegate=self;
    //初始化播放器
    [player prepareToPlay];
    
    //设置播放循环次数，如果numberOfLoops为负数 音频文件就会一直循环播放下去
    player.numberOfLoops = 0;
    
    //设置音频音量 volume的取值范围在 0.0为最小 0.1为最大 可以根据自己的情况而设置
    player.volume = 1.0f;
    
    [player play];
    
}
#pragma mark - 显示在中间的消息 url
- (void)middleMsgClick:(CustomButtonNewsDetail *)butt
{
    
    UIMenuController *menu=[UIMenuController sharedMenuController];
    [menu setMenuVisible:NO];
    
    //    int index=butt.tag-MIDDLE_TAG_BASE;
    
    if (!butt.nd) {
        return;
    }
    
    if([self tagarWhenEditing:butt.nd]){
        return;
    }
    
    ServiceNumberMsgDetailViewController *snMsgDetail=[[ServiceNumberMsgDetailViewController alloc]init];
    
    NSError *error=nil;
    
    NSXMLElement *x_parse=[[NSXMLElement alloc] initWithXMLString:butt.nd.sendContents error:&error];
    
    if (error) {
        DDLogInfo(@"解析出错,error:%@",error);
    }
    
    NSArray *articleArray=[[x_parse elementForName:@"article"] elementsForName:@"mediaarticle"];
    
    snMsgDetail.notesData=butt.nd;
    snMsgDetail.x_element=articleArray[0];
    snMsgDetail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:snMsgDetail animated:YES];
}
#pragma 显示在中间的消息 长按
- (void)middleMsgLongPress:(UILongPressGestureRecognizer *)sender
{
    //    MenuButton  *butt=(MenuButton *)longRecognizer.view;
    CustomButtonNewsDetail *button=(CustomButtonNewsDetail *)sender.view;
    if(sender.state==UIGestureRecognizerStateBegan){
        
        [button becomeFirstResponder];
        //        DDLogInfo(@"%@",NSStringFromCGRect(button.frame));
        _selectNotesData=button.nd;
        //        _selectIndex = button.tag-20000;
        [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"长按消息,显示删除菜单"]];
        UIMenuItem *itemDel=[[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(myDelete:)];
        //        UIMenuItem *transmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTransmit:)];
        UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"更多..." action:@selector(more:)];
        
        
        CGRect buttFram=button.frame;
        if (button.customButtonType==CustomButtonTypeTransmit) {
            int x =0;
            if (button.imageView.tag==1) {
                x=button.frame.origin.x;
            }else if(button.imageView.tag==2){
                x=button.frame.origin.x-20;
            }
            buttFram.origin.x=x;
        }
        
        NSMutableArray  *menuArray=[[NSMutableArray alloc] init];
        if (isService) {
            
            
            NSArray *authoArray=[[NSUserDefaults standardUserDefaults] objectForKey:authority_type];
            for (NSDictionary *dict in authoArray) {
                //                NSString *authorityId=dict[@"authorityId"];
                //                if ([authorityId isEqualToString:@"delete"]) {
                //                    [menuArray addObject:itemDel];
                //                }else if ([authorityId isEqualToString:@"zf"]){
                //                    [menuArray addObject:transmit];
                //                }else if ([authorityId isEqualToString:@"pl_manage"]){
                //                    [menuArray addObject:more];
                //                }
                NSString *authorityId=dict[@"authorityId"];
                if ([authorityId isEqualToString:@"delete"]) {
                    [menuArray addObject:itemDel];
                }else if ([authorityId isEqualToString:@"pl_manage"]){
                    [menuArray addObject:more];
                }
            }
            
            //            menuArray=@[itemDel,transmit,more];
        }else{
            [menuArray addObjectsFromArray:@[itemDel]];
        }
        
        UIMenuController *menuController=[UIMenuController sharedMenuController];
        [menuController setMenuItems:menuArray];
        [menuController setTargetRect:buttFram inView:button];
        //        [menuController setMenuVisible:NO];
        [menuController setMenuVisible:YES animated:YES];
        
    }
    
}
#pragma mark - 头像
-(void)headClick:(id)sender{
    
    if(self.chatType==5){
        return;
    }
    MenuButton *butt=(MenuButton *)sender;
    
    if (self.chatType==2){
        ServiceNumberDetailViewController *detailVC=[[ServiceNumberDetailViewController alloc] init];
        detailVC.publicaccontModel=self.publicModel;
        detailVC.hidesBottomBarWhenPushed=YES;
        detailVC.subscribestatusType=1;
        detailVC.isFromMessage=YES;
        
        [self.navigationController pushViewController:detailVC animated:YES];
        return;
    }
    
    EmployeeModel *eml=[SqlAddressData queryMemberInfoWithImacct:butt.nd.fromUserId];
    DDLogInfo(@"%@...",butt.nd.fromUserId);
    if(!eml.name){
        MBProgressHUD *errorHud=[[MBProgressHUD alloc] initWithView:self.view];
        errorHud.labelText=@"该用户已经删除";
        errorHud.mode=MBProgressHUDModeText;
        [self.view bringSubviewToFront:errorHud];
        [self.view addSubview:errorHud];
        [errorHud show:YES];
        [errorHud hide:YES afterDelay:1];
        return;
    }
    
    UserDetailViewController *userDetailVC=[[UserDetailViewController alloc] init];
    userDetailVC.userInfo=eml;
    userDetailVC.organizationName = eml.comman_orgName;
    userDetailVC.hidesBottomBarWhenPushed=YES;
    if (self.chatType==0) {
        userDetailVC.isFromChat=YES;
    }
    
    [self.navigationController pushViewController:userDetailVC animated:YES];
    
    
}

#pragma mark - 单元格长按,自定义menu
//显示菜单
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(myCopy:) || action == @selector(myDelete:) || action == @selector(myTask:)|| action == @selector(myTransmit:) || action == @selector(more:)) {
        return YES;
    }
    return NO;
}
-(void)transmitLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    if (_chatTable.editing) {
        return;
    }
    
    MenuButton  *butt=(MenuButton *)longRecognizer.view;
    
    [[LogRecord sharedWriteLog] writeLog:@"服务号长按"];
    
    if (longRecognizer.state == UIGestureRecognizerStateBegan){
        _selectNotesData=butt.nd;
        
        [butt becomeFirstResponder];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
        //        UIMenuItem *transmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTransmit:)];
        UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"更多..." action:@selector(more:)];
        
        int x =0;
        if (butt.imageView.tag==1) {
            x=butt.frame.origin.x-10;
        }else if(butt.imageView.tag==2){
            x=butt.frame.origin.x+10;
        }
        
        CGRect rect=CGRectMake(x, butt.frame.origin.y, butt.frame.size.width, butt.frame.size.height);
        
        NSMutableArray  *menuArray=[[NSMutableArray alloc] init];
        if (isService) {
            
            NSArray *authoArray=[[NSUserDefaults standardUserDefaults] objectForKey:authority_type];
            for (NSDictionary *dict in authoArray) {
                NSString *authorityId=dict[@"authorityId"];
                //                if ([authorityId isEqualToString:@"delete"]) {
                //                    [menuArray addObject:delete];
                //                }else if ([authorityId isEqualToString:@"zf"]){
                //                    [menuArray addObject:transmit];
                //                }else if ([authorityId isEqualToString:@"pl_manage"]){
                //                    [menuArray addObject:more];
                //                }
                if ([authorityId isEqualToString:@"delete"]) {
                    [menuArray addObject:delete];
                }else if ([authorityId isEqualToString:@"pl_manage"]){
                    [menuArray addObject:more];
                }
            }
            
        }else{
            //            [menuArray addObjectsFromArray:[NSArray arrayWithObjects:transmit,delete,nil]];
            [menuArray addObjectsFromArray:[NSArray arrayWithObjects:delete,nil]];
            
        }
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:rect inView:butt.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
-(void)textLabelLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    //文字
    
    if (_chatTable.editing) {
        return;
    }
    
    MenuButton  *butt=(MenuButton *)longRecognizer.view;
    
    [[LogRecord sharedWriteLog] writeLog:@"文字长按"];
    
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        
        _selectNotesData=butt.nd;
        
        
        [butt becomeFirstResponder];
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(myCopy:)];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
        //        UIMenuItem *transmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTransmit:)];
        //        UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"更多..." action:@selector(more:)];
        UIMenuItem *task = [[UIMenuItem alloc] initWithTitle:@"转成任务" action:@selector(myTask:)];
        int x =0;
        if (butt.imageView.tag==1) {
            x=butt.frame.origin.x-10;
        }else if(butt.imageView.tag==2){
            x=butt.frame.origin.x+10;
        }
        
        CGRect rect=CGRectMake(x, butt.frame.origin.y, butt.frame.size.width, butt.frame.size.height);
        
        NSArray *menuArray;
        //        if (isService) {
        //            menuArray=[NSArray arrayWithObjects:copy,transmit,delete,more,nil];
        //        }else{
        //            menuArray=[NSArray arrayWithObjects:copy,transmit,delete,nil];
        //        }
        //        menuArray=[NSArray arrayWithObjects:copy,transmit,delete,more,nil];
        if (butt.nd.isTask == 2) {
            menuArray=[NSArray arrayWithObjects:copy,delete,nil];
        }else {
            menuArray=[NSArray arrayWithObjects:copy,delete,task,nil];
        }
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:rect inView:butt.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
-(void)imageLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    //图片
    if (_chatTable.editing) {
        return;
    }
    [[LogRecord sharedWriteLog] writeLog:@"图片长按"];
    
    MenuButton *butt=(MenuButton *)longRecognizer.view;
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        //   TSTableViewCell *cell = (TSTableViewCell *)recognizer.view;
        
        _selectNotesData=butt.nd;
        
        [butt becomeFirstResponder];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
        //        UIMenuItem *transmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTransmit:)];
        //        UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"更多..." action:@selector(more:)];
        int x =0;
        if (butt.imageView.tag==1) {
            x=butt.frame.origin.x-10;
        }else if(butt.imageView.tag==2){
            x=butt.frame.origin.x+10;
        }
        
        CGRect rect=CGRectMake(x, butt.frame.origin.y, butt.frame.size.width, butt.frame.size.height);
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        NSArray *menuArray;
        //        if (isService) {
        //            menuArray=[NSArray arrayWithObjects:transmit,delete,more, nil];
        //        }else{
        //            menuArray=[NSArray arrayWithObjects:transmit,delete, nil];
        //        }
        menuArray=[NSArray arrayWithObjects:delete, nil];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:rect inView:butt.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
-(void)videoLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    //视频
    if (_chatTable.editing) {
        return;
    }
    [[LogRecord sharedWriteLog] writeLog:@"视频长按"];
    MenuButton *butt=(MenuButton *)longRecognizer.view;
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        _selectNotesData=butt.nd;
        [butt becomeFirstResponder];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
        //        UIMenuItem *transmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTransmit:)];
        //        UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"更多..." action:@selector(more:)];
        int x =0;
        if (butt.imageView.tag==1) {
            x=butt.frame.origin.x-10;
        }else if(butt.imageView.tag==2){
            x=butt.frame.origin.x+10;
        }
        
        CGRect rect=CGRectMake(x, butt.frame.origin.y, butt.frame.size.width, butt.frame.size.height);
        NSArray *menuArray;
        menuArray=[NSArray arrayWithObjects:delete, nil];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:rect inView:butt.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
-(void)voiceLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    //声音
    if (_chatTable.editing) {
        return;
    }
    [[LogRecord sharedWriteLog] writeLog:@"声音长按"];
    MenuButton *butt=(MenuButton *)longRecognizer.view;
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        //   TSTableViewCell *cell = (TSTableViewCell *)recognizer.view;
        
        _selectNotesData=butt.nd;
        
        [butt becomeFirstResponder];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
        //        UIMenuItem *transmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTransmit:)];
        //        UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"更多..." action:@selector(more:)];
        int x =0;
        if (butt.imageView.tag==1) {
            x=butt.frame.origin.x-10;
        }else if(butt.imageView.tag==2){
            x=butt.frame.origin.x+10;
        }
        
        NSArray *menuArray;
        
        menuArray=[NSArray arrayWithObjects:delete, nil];
        
        CGRect rect=CGRectMake(x, butt.frame.origin.y, butt.frame.size.width, butt.frame.size.height);
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:rect inView:butt.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
#pragma mark - 更多
-(void)more:(id)sender{
    _chatTable.allowsMultipleSelectionDuringEditing = YES;
    [_chatTable setEditing:YES animated:YES];
    [_rightButt setHidden:YES];
    [_leftButt setTitle:@"取消" forState:UIControlStateNormal];
    [_leftButt setBackgroundImage:nil forState:UIControlStateNormal];
    isEdite=YES;
    if (!selectCellDict) {
        selectCellDict=[[NSMutableDictionary alloc] init];
    }
    [selectCellDict removeAllObjects];
    
    ChatCell *cell=[cellDict objectForKey:_selectNotesData.contentsUuid];
    [cell changeMSelectedState];
    if (cell.myChatSelect) {
        //默认选中长按的那条消息
        [selectCellDict setObject:cell forKey:_selectNotesData.contentsUuid];
    }
    [self showMultipleView];
}
#pragma mark 多选时的工具条
-(void)showMultipleView{
    
    if (multipleView) {
        [multipleView removeFromSuperview];
        multipleView=nil;
    }
    
    int numIos7=0;
    if (IS_IOS_7) {
        numIos7=64;
    }else{
        numIos7=44;
    }
    multipleView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, 320, 44)];
    multipleView.backgroundColor=[UIColor whiteColor];
    for (int i=0; i<1; i++) {
        UIButton *butt=[UIButton buttonWithType:UIButtonTypeCustom];
        butt.frame=CGRectMake(30+50*i+35*i, (44-35)/2, 35, 35);
        if (i==0) {
            [butt setBackgroundImage:[UIImage imageNamed:@"Session_Multi_Delete"] forState:UIControlStateNormal];
            [butt setBackgroundImage:[UIImage imageNamed:@"Session_Multi_Delete_HL"] forState:UIControlStateHighlighted];
        }else if (i==1){
            [butt setBackgroundImage:[UIImage imageNamed:@"Session_Multi_Forward"] forState:UIControlStateNormal];
            [butt setBackgroundImage:[UIImage imageNamed:@"Session_Multi_Forward_HL"] forState:UIControlStateHighlighted];
        }
        butt.tag=i+multipleButt_tag;
        [butt addTarget:self action:@selector(multipleButt:) forControlEvents:UIControlEventTouchUpInside];
        [multipleView addSubview:butt];
    }
    [self.view addSubview:multipleView];
    [self.view bringSubviewToFront:multipleView];
    
    ///取消所有的点击事件
    for (ChatView *view in chatArray) {
        view.userInteractionEnabled=NO;
    }
    
}
-(void)hideMyltipleView{
    
    [_chatTable setEditing:NO animated:YES];
    isEdite=NO;
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    [_leftButt setTitle:@"  返回" forState:UIControlStateNormal];
    _rightButt.hidden=NO;
    if (selectCellDict) {
        
        for (NSString  *key in selectCellDict.allKeys) {
            //避免转发后,再次点更多,会出来
            ChatCell *cell=[selectCellDict objectForKey:key];
            [cell changeMSelectedState];
        }
        
        [selectCellDict removeAllObjects];
    }
    [multipleView removeFromSuperview];
    multipleView=nil;
    
    //恢复所有的点击时间
    for (ChatView *view in chatArray) {
        view.userInteractionEnabled=YES;
    }
    
}
-(void)multipleButt:(UIButton *)sender{
    int index=sender.tag-multipleButt_tag;
    
    if (index==1) {
        return;
    }else{
        //删除
        DDLogInfo(@"删除-----%d",selectCellDict.allKeys.count);
        
        
        //删除操作,考虑时间问题
        /**
         *  如果是最后一条,且上一个为时间view,连带着把时间view删除掉
         *  如果是最后一条,上一个不为时间view,不做特殊处理
         *  如果不是最后一条,上一个为时间view,但是下一个不是时间view,不做特殊处理
         *  如果不是最后一条,上一个为时间view,但是下一个是时间view,连带着把时间view删除掉
         *  如果不是最后一条,上一个不为时间view,不做处理
         */
        
    }
}
#pragma mark - 复制
-(void)myCopy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = _selectNotesData.sendContents;
}
#pragma mark - 删除
-(void)myDelete:(id)sender{
    //删除消息
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定要删除这条消息?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag=alert_deleta_content;
    [alert show];
}
#pragma mark - 转成任务
- (void)myTask:(id)sender {
    TaskCreateViewController *taskCreateVC = [[TaskCreateViewController alloc] init];
    taskCreateVC.detailText = _selectNotesData.sendContents;
    taskCreateVC.hidesBottomBarWhenPushed = YES;
    taskCreateVC.isFromMessage = YES;
    taskCreateVC.createTaskDelegate = self;
    [self.navigationController pushViewController:taskCreateVC animated:YES];
}

- (void)createTaskSuccess {
    [[SqliteDataDao sharedInstanse] updateTaskStateWithToMessageId:_selectNotesData.contentsUuid];
    _selectNotesData.isTask = 2;
    ChatCell *cell = [cellDict objectForKey:_selectNotesData.contentsUuid];
    NSInteger i = [chatArray indexOfObject:cell.chatView];
    [cellDict removeObjectForKey:_selectNotesData.contentsUuid];
    [chatArray removeObject:cell.chatView];
    BOOL isSelf=NO;
    if ([_selectNotesData.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct] && _selectNotesData.contentsUuid.length>0) {
        //自己给自己发消息
        
        NSString *str=[_selectNotesData.contentsUuid substringToIndex:4];
        if ([str isEqualToString:@"self"]) {
            isSelf=NO;
        }else{
            isSelf=YES;
        }
    }else{
        if ([_selectNotesData.fromUserId isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
            isSelf=YES;
        }else{
            isSelf=NO;
        }
    }
    ChatView *v = [self getChatViewonly:_selectNotesData from:isSelf activityViewV:nil];
    [chatArray insertObject:v atIndex:i];
    [self reloadChatTabel];
}

#pragma mark - 服务号 转发
-(void)tranmistServersNumber:(NSString *)toTaskId messageType:(int)type{
    
    NSString *selfNum=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    
    //服务号
    NSMutableArray *queueArray=[[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *sendContents;
    
    NSDate *nowDate=[[NSDate alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendTime=[formatter stringFromDate:nowDate];
    
    int serviceNewsCount=0;
    
    if (type==8) {
        //服务号转发消息
        sendContents=_selectNotesData.sendContents;
    }else if (type==1){
        
        NSString *temp_send_content_str=_selectNotesData.sendContents;
        NSArray *serviceContentArray=[temp_send_content_str componentsSeparatedByString:partition_service];
        serviceNewsCount=serviceContentArray.count;
        if (serviceContentArray.count>0) {
            //多条内容的服务号
            for (NSString *serviceNewsStr in serviceContentArray) {
                sendContents=serviceNewsStr;
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:0];
                [dict setObject:@"sendChat" forKey:@"act"];
                [dict setObject:selfNum forKey:@"fromUserId"];
                [dict setObject:sendTime forKey:@"sendTime"];
                [dict setObject:toTaskId forKey:@"taskId"];
                [dict setObject:@"1" forKey:@"type"];
                [dict setObject:@"8" forKey:@"type"];
                [dict setObject:sendContents forKey:@"sendContents"];
                [queueArray addObject:dict];
            }
            
            
        }else{
            //之前旧的服务号
            
            NSDictionary *serviceNewsDict=[NSJSONSerialization JSONObjectWithData:[_selectNotesData.serviceNews dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            NSMutableDictionary *contentDict=[[NSMutableDictionary alloc] initWithDictionary:serviceNewsDict];
            [contentDict setObject:_selectNotesData.sendContents forKey:@"contentExtra"];
            NSData *data=[NSJSONSerialization dataWithJSONObject:contentDict options:NSJSONWritingPrettyPrinted error:nil];
            sendContents =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        
    }
    
    if (serviceNewsCount==0) {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:@"sendChat" forKey:@"act"];
        [dict setObject:selfNum forKey:@"fromUserId"];
        [dict setObject:sendTime forKey:@"sendTime"];
        [dict setObject:toTaskId forKey:@"taskId"];
        [dict setObject:@"1" forKey:@"type"];
        [dict setObject:@"8" forKey:@"type"];
        [dict setObject:sendContents forKey:@"sendContents"];
        [queueArray addObject:dict];
    }
    
    
    [[TransmitSendMessage sharedTransmit] sendMessage:queueArray];
    [self tranmistSucceesHud];
}
-(void)tranmistSucceesHud{
    [self hudWasHidden:nil];
    [myApp showWithCustomView:nil detailText:@"转发成功" isCue:0 delayTime:1 isKeyShow:NO];
}
-(void)myTransmit:(id)sender{
    
    self.tranmistMessageArray=@[_selectNotesData];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    nav_add.addScrollType=AddScrollTypeTransmit;
    nav_add.delegate_addID = self;
    
    [self presentViewController:nav_add animated:YES completion:^{
        
    }];
    return;
}
-(void)GetArrayID:(RoomInfoModel *)roomModel{
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=1;
    detailViewController.roomInfoModel=roomModel;
    detailViewController.isTranmist=YES;
    detailViewController.tranmistMessageArray=self.tranmistMessageArray;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)sendMassMessage:(NSArray *)memberArray{
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=0;
    detailViewController.member_userInfo=memberArray[0];
    detailViewController.isTranmist=YES;
    detailViewController.tranmistMessageArray=self.tranmistMessageArray;
    //    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    //    temporaryBarButtonItem.title = @"返回";
    //    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
#pragma mark - 头像长按
-(void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer{
    
    
    MenuButton  *butt=(MenuButton *)longPressGestureRecognizer.view;
    NotesData *notesData=butt.nd;
    UITextView *inputText=(UITextView *)[self.view viewWithTag:text_input_tag];
    
    if ([notesData.fromUserId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]]) {
        return;
    }else{
        
        inputText.text = [NSString stringWithFormat:@"@%@ ",notesData.fromUserName];
        [inputText becomeFirstResponder];
        ButtonAudioRecorder *audioButt=(ButtonAudioRecorder *)[self.view viewWithTag:butt_make_voice_tag];
        audioButt.alpha=0;
        [voice_tip_view setHidden:YES];
        
        UIButton *voiceButton=(UIButton *)[self.view viewWithTag:butt_voice_tag];
        if (voiceButton.selected) {
            [voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_Sound-Onp.png"] forState:UIControlStateNormal];
            voiceButton.selected=!voiceButton.selected;
        }
        FaceButton *faceButt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
        if (faceButt.selected) {
            [faceButt setBackgroundImage:[UIImage imageNamed:@"chat_smile.png"] forState:UIControlStateNormal];
            faceButt.selected=!faceButt.selected;
        }
        MoreButton *morebtn=(MoreButton *)[self.view viewWithTag:butt_add_tag];
        morebtn.selected=NO;
    }
    
}
#pragma mark - 双击文本消息
-(void)textLabelTap:(UITapGestureRecognizer *)sender{
    
    if (_chatTable.editing) {
        return;
    }
    
    [self.view endEditing:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
    FaceButton *faceButt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
    faceButt.selected=NO;
    MoreButton *morebtn=(MoreButton *)[self.view viewWithTag:butt_add_tag];
    morebtn.selected=NO;
    
    
    MenuButton  *butt=(MenuButton *)sender.view;
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    
    if (!bigView) {
        
    }
    bigView=[[UIView alloc] initWithFrame:keyWindow.bounds];
    bigView.backgroundColor=[UIColor whiteColor];
    bigView.alpha=0;
    [keyWindow addSubview:bigView];
    
    CGSize textSize=[butt.nd.sendContents sizeWithFont:[UIFont systemFontOfSize:24]];
    
    
    UITextView * bigTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 10, 320-20, bigView.frame.size.height-20)];
    bigTextView.text=butt.nd.sendContents;
    bigTextView.font=[UIFont systemFontOfSize:24];
    bigTextView.textColor=[UIColor blackColor];
    bigTextView.backgroundColor=[UIColor whiteColor];
    bigTextView.editable=NO;
    bigTextView.textAlignment=NSTextAlignmentLeft;
    if (textSize.width<300) {
        bigTextView.textAlignment=NSTextAlignmentCenter;
    }
    
    [bigView addSubview:bigTextView];
    
    [bigTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];//也可以监听contentSize属性
    
    [UIView animateWithDuration:0.3 animations:^{
        bigView.alpha=1;
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *textViewTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTap)];
        textViewTap.numberOfTapsRequired=1;
        [bigTextView addGestureRecognizer:textViewTap];
    }];
    
}
-(void)textViewTap{
    
    [UIView animateWithDuration:0.3 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        bigView.alpha=0;
    } completion:^(BOOL finished) {
        
    }];
}
//接收处理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *bigTextView = (UITextView *)object;
    
    CGFloat topCorrect = ([bigTextView bounds].size.height - [bigTextView contentSize].height);
    
    topCorrect = (topCorrect <0.0 ?0.0 : topCorrect);
    
    bigTextView.contentOffset = (CGPoint){.x =0, .y = -topCorrect/2};
    
}

#pragma mark-
#pragma mark TouchTableDelegate
- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    FaceButton *butt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
    butt.selected=NO;
    MoreButton *morebtn=(MoreButton *)[self.view viewWithTag:butt_add_tag];
    morebtn.selected=NO;
    UITextView *t=(UITextView *)[self.view viewWithTag:text_input_tag];
    t.inputView=nil;
    //移除子菜单
    [self removeSubmenu];
}
#pragma mark-
#pragma mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获得每一行对应的气泡view
    ChatView *bubble=(ChatView *)[chatArray  objectAtIndex:indexPath.row];
    return bubble.frame.size.height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [chatArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!cellDict) {
        cellDict=[[NSMutableDictionary alloc] initWithCapacity:0];
    }
    ChatView *bubble=(ChatView *)[chatArray objectAtIndex:indexPath.row];
    NSString *messageUuid=bubble.nd.contentsUuid;
    if (!messageUuid) {
        messageUuid=bubble.nd.serverTime;
        DDLogInfo(@"uuid为空%@",messageUuid);
        
    }
    if (bubble.chatViewType==MyChatViewTypeTime) {
        messageUuid=[NSString stringWithFormat:@"time_%@",messageUuid];
    }if (bubble.chatViewType==MyChatViewTypeGroup) {
        messageUuid=[NSString stringWithFormat:@"group_%@",messageUuid];
    }
    
    NSString *indebtifier=[NSString stringWithFormat:@"Cell_%@",messageUuid];
    //    DDLogInfo(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@",indebtifier);
    
    ChatCell *cell=[cellDict objectForKey:messageUuid];
    if (!cell) {
        cell=[[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indebtifier];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectedBackgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clearBack"]];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.cellChatViewType=bubble.chatViewType;
        [cell.contentView addSubview:bubble];
        [cellDict setObject:cell forKey:messageUuid];
        cell.chatView=bubble;
        //        DDLogInfo(@"新建%@",indebtifier);
        //    }else{
        //        DDLogInfo(@"复用%@",indebtifier);
    }
    return cell;
}

#pragma mark - UITableView delete
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.editing) {
        //编辑状态
        
        ChatView *bubble=(ChatView *)[chatArray objectAtIndex:indexPath.row];
        if (bubble.chatViewType==MyChatViewTypeTime || bubble.chatViewType==MyChatViewTypeGroup) {
            return;
        }
        
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        ChatCell *chatCell=(ChatCell *)cell;
        
        
        if (!selectCellDict) {
            selectCellDict=[[NSMutableDictionary alloc] init];
        }
        NSString *messageUuid=bubble.nd.contentsUuid;
        if (!messageUuid) {
            messageUuid=bubble.nd.serverTime;
        }
        if (chatCell.myChatSelect) {
            //选中
            [selectCellDict removeObjectForKey:messageUuid];
        }else{
            //未选中
            [selectCellDict setObject:cell forKey:messageUuid];
        }
        
        [chatCell changeMSelectedState];
        
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.editing){
        ChatView *bubble=(ChatView *)[chatArray objectAtIndex:indexPath.row];
        if (bubble.chatViewType==MyChatViewTypeTime || bubble.chatViewType==MyChatViewTypeGroup) {
            return;
        }
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        ChatCell *chatCell=(ChatCell *)cell;
        
        if (!selectCellDict) {
            selectCellDict=[[NSMutableDictionary alloc] init];
        }
        NSString *messageUuid=bubble.nd.contentsUuid;
        if (!messageUuid) {
            messageUuid=bubble.nd.serverTime;
        }
        if (chatCell.myChatSelect) {
            //选中
            [selectCellDict removeObjectForKey:messageUuid];
        }else{
            //未选中
            [selectCellDict setObject:cell forKey:messageUuid];
        }
        [chatCell changeMSelectedState];
    }
}

#pragma mark-
#pragma mark scrollViewDelegate下拉刷新
//是否还有更多聊天记录
BOOL isNext=YES;
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_headTableView.superview && scrollView.contentOffset.y < -50)
    {
        int nowcount=[chatArray count];
        if(_chatType==4){
            NSArray *temp=[[NSArray alloc]initWithArray:[[SqliteDataDao sharedInstanse]queryBulletinDataWithlocation:[self.chatNotesDataArray count] length:onePageCount+1]];
            NSMutableArray *ndtemp=[[NSMutableArray alloc]init];
            for(int i=0;i<temp.count;i++){
                BulletinModel *nd=[temp objectAtIndex:i];
                NotesData *ttt=[[NotesData alloc]init];
                ttt.typeMessage=@"4";
                ttt.BulletinModel=nd;
                ttt.serverTime=nd.receiveTime;
                ttt.sendContents=nd.bulletinID;
                ttt.contentsUuid=nd.bulletinID;
                [ndtemp addObject:ttt];
            }
            [self insertChat:_chatNotesDataArray withArray:ndtemp];
        }else{
            [self insertChat:_chatNotesDataArray withArray:[[SqliteDataDao sharedInstanse]queryChatDataWithToUserId:_toUserId location:[self.chatNotesDataArray count] length:onePageCount+1]];
        }
        //延迟
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[chatArray count]-nowcount inSection:0];
            if([chatArray count]>indexPath.row){
                [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        });
    }
    
}
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//
////    return;
//    if (_headTableView.superview && scrollView.contentOffset.y < -50)
//    {
//        DDLogInfo(@"进行下拉刷新功能");
//        //下拉刷新
//        pageIndex=[self.chatNotesDataArray count]/20+1;
//        if ([self.chatNotesDataArray count]%20 != 0) {
//            isNext=NO;
//        }else{
//            isNext=YES;
//        }
//
//        if (isNext) {
//
//            //copy的目的是避免对地址的直接引用.分配出来一个新的内存空间
//            NSArray * tempArray=[self.chatNotesDataArray copy];
//
//            [self.chatNotesDataArray removeAllObjects];
//            if ([self.chatNotesDataArray count] != 0) {
//                //如果查询出来的结果不为0,就证明存在新数据
//
//                int newArrayCount = [self.chatNotesDataArray count];
//                if (newArrayCount > 2) {
//                    newArrayCount =newArrayCount+4;
//                }
//
//                //临时的数组,存放之前的数据,避免for循环层数过多
//
//                [self.chatNotesDataArray addObjectsFromArray:tempArray];
//
////                __block typeof(self) block_self=self;
//                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//                    _chatTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
//                } completion:^(BOOL finished) {
//                    //临时的气泡数组
//                    [chatArray removeAllObjects];
//                    [self loadNotesData];
//
//                    [_chatTable reloadData];
//                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:newArrayCount inSection:0];
//                    [_chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//                }];
//            }else{
//                //什么也不需要做
//                [self.chatNotesDataArray addObjectsFromArray:tempArray];
//            }
//
//        }else{
//            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//                _chatTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
//            } completion:^(BOOL finished) {
//
//            }];
//        }
//
//        //延迟两秒
//        double delayInSeconds = 1.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//                _chatTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//            } completion:^(BOOL finished) {
//
//            }];
//
//        });
//    }
//
//}
#pragma mark - AVAudioPlayDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive:NO withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:nil];
    
}

#pragma mark - 设置在编辑模式失去响应,别响应cell的点击效果
-(BOOL)tagarWhenEditing:(NotesData *)nd{
    if (_chatTable.editing) {
        
        NSString *messageUuid=nd.contentsUuid;
        if (!messageUuid) {
            messageUuid=nd.serverTime;
        }
        ChatCell *cell=[cellDict objectForKey:messageUuid];
        if (!selectCellDict) {
            selectCellDict=[[NSMutableDictionary alloc] init];
        }
        
        if (cell.myChatSelect) {
            //选中
            [selectCellDict removeObjectForKey:messageUuid];
        }else{
            //未选中
            [selectCellDict setObject:cell forKey:messageUuid];
        }
        [cell changeMSelectedState];
        return YES;
    }else{
        return NO;
    }
    
}
#pragma mark-
#pragma mark HUD 指示器

- (void)hudWasHidden:(MBProgressHUD *)hud{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}
-(void)addHUD:(NSString *)labelStr{
    _HUD=[[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    _HUD.labelText = labelStr;
    _HUD.delegate=self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
    [_HUD show:YES];
}
#pragma mark - 表情内容点击
- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type{
    
    
    if (_chatTable.editing) {
        return;
    }
    
    switch (type) {
        case MLEmojiLabelLinkTypeEmail:
        {
            break;
        }
        case MLEmojiLabelLinkTypeURL:
        {
            NSString *url;
            url=link;
            NSString *isHttp=[link substringToIndex:4];
            if (![isHttp isEqualToString:@"http"]) {
                url=[NSString stringWithFormat:@"http://%@",url];
            }
            [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"点击聊天内容中的连接,地址为:%@",url]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            break;
        }
        case MLEmojiLabelLinkTypeAt:
        {
            break;
        }
        case MLEmojiLabelLinkTypePhoneNumber:
        {
            break;
        }
        case MLEmojiLabelLinkTypePoundSign:
        {
            break;
        }
        default:
            break;
    }
    
}
#pragma mark -公告详情
-(void) contexttouch:(id)sender{
    UIButton *button=(UIButton *)sender;
    DDLogCInfo(@"title%d",button.tag);
    
    ContextDetilControllerViewController *vc=[[ContextDetilControllerViewController alloc]init];
    vc.bulletinID=[NSString stringWithFormat:@"%d",button.tag];
    vc.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    NSLog(@"查看全文");
}
-(NSString *)fixurl:(NSString *)str{
    NSString *url=[str stringByReplacingOccurrencesOfRegex:@"/original/real/" withString:@"/middle/"];
    NSString *picname=[str lastPathComponent];
    //    NSLog(@"%@",picname);
    url=[url stringByReplacingOccurrencesOfRegex:picname withString:@""];
    NSArray *ary=[picname componentsSeparatedByString:@"."];
    url=[NSString stringWithFormat:@"%@%@_middle.%@",url,ary[0],ary[1]];
    DDLogInfo(@"处理后字符串名字%@",url);
    return url;
}
#pragma mark - 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end