//
//  BTPhotoViewController.m
//  AppearanceChapter
//
//  Created by Adam Burkepile on 7/16/12.
//  Copyright (c) 2012 Adam Burkepile. All rights reserved.
//

#import "BTPhotoViewController.h"
#import "FMDatabase.h"
#import "NSString+FilePath.h"
#import "UIImageView+WebCache.h"
@interface BTPhotoViewController ()

@end

@implementation BTPhotoViewController
@synthesize ibPhoto,index,scrollView;

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
	// Do any additional setup after loading the view.
    self.ibPhoto.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.directionalLockEnabled  = YES;
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.scrollView.delegate = self;
    self.scrollView.touchesdelegate=self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale  = 4.0;
    self.scrollView.bouncesZoom = YES;
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    longPress.delegate = self;
//    [self.view addGestureRecognizer:longPress];
    
    
}

-(void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
//        DDLogInfo(@"UIGestureRecognizerStateBegan");
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}
-(void)saveImage{

    
    NSArray  * imgPathArray=[self.photoData  componentsSeparatedByString:@"#"];
    DDLogInfo(@"图片资源====%@",self.photoData);
    NSInteger file_path_type=[[imgPathArray objectAtIndex:0] integerValue];
    switch (file_path_type) {
        case 0:
//          网络图片
        {
            NSString  * imgName=[imgPathArray[1] lastPathComponent];
            NSString *file_path=[NSString stringWithFormat:@"%@%@",image_path,imgName];
            NSString *nowImageFilePath=[file_path filePathOfCaches];
            UIImage *nowImage=[UIImage imageWithContentsOfFile:nowImageFilePath];
            UIImageWriteToSavedPhotosAlbum(nowImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        case 1:
//           本地图片
        {

            UIImage * nowImage=[UIImage imageWithContentsOfFile:[imgPathArray[1] filePathOfCaches]];
            UIImageWriteToSavedPhotosAlbum(nowImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        default:
            break;
    }

}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
   
    
    if (error != NULL){
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存错误" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }else{
        //        alertView = [[UIAlertView alloc] initWithTitle:@"Save Success" message:@"Image has Saved !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"保存成功" isCue:0 delayTime:1 isKeyShow:NO];
    }
    
}
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [ibPhoto setImageWithURL:[NSURL URLWithString:self.photoData]];
    NSArray *filePathArray=[self.photoData componentsSeparatedByString:@"#"];
    NSInteger file_path_type=[[filePathArray objectAtIndex:0] integerValue];
    switch (file_path_type) {
        case 0:
        {
            //url
//            royasoft
            //图片缓存处理
            NSFileManager *fileManager=[NSFileManager defaultManager];
            
            NSString *fileName=[filePathArray[1] lastPathComponent];
            NSString *file_path=[NSString stringWithFormat:@"%@%@",image_path,fileName];
            
            //从网络下载
            //判断目录是否存在不存在则创建
            NSString *pathDirectories = [[file_path filePathOfCaches] stringByDeletingLastPathComponent];
            if (![fileManager fileExistsAtPath:pathDirectories]) {
                [fileManager createDirectoryAtPath:pathDirectories withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            if ([fileManager fileExistsAtPath:[file_path filePathOfCaches]]) {
                //请求成功
                [ibPhoto setImage:[UIImage imageWithContentsOfFile:[file_path filePathOfCaches]]];
                return;
            }
            
            
            NSString *image_url=[filePathArray objectAtIndex:1];
            NSRange ran=[image_url rangeOfString:@"/real/"];
        
           
            if (ran.length!=6){
               image_url=[image_url stringByDeletingLastPathComponent];
               image_url=[NSString stringWithFormat:@"%@/real/%@",image_url,fileName];
            }
           
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:image_url]]];
            
            //添加下载请求（获取服务器的输出流）
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[file_path filePathOfCaches] append:NO];
            
            MBProgressHUD *HUD;
            HUD=[[MBProgressHUD alloc] initWithView:self.view];
            HUD.removeFromSuperViewOnHide=YES;
            HUD.mode=MBProgressHUDModeDeterminateHorizontalBar;
            HUD.dimBackground = YES;
            HUD.labelText=@"正在下载图片";
            [self.view bringSubviewToFront:HUD];
            [self.view addSubview:HUD];
            [HUD show:YES];
            
            //设置下载进度条
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                
                //显示下载进度
                CGFloat progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
                HUD.detailsLabelText=[NSString stringWithFormat:@"%.2f%%",progress * 100];
                HUD.progress=progress;
                if (progress == 1) {
                    [HUD hide:YES];
                }
                
            }];
            
            //请求管理判断请求结果
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //请求成功
                [ibPhoto setImage:[UIImage imageWithContentsOfFile:[file_path filePathOfCaches]]];
                
                self.photoData=[self jointIamgeUrl:file_path urlType:1];
                
                [[SqliteDataDao sharedInstanse] updateImageChatDataWithMessageId:self.nd.contentsUuid imageChatData:self.nd.imageCHatData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                //请求失败
                [HUD hide:YES];
                MBProgressHUD *errorHud=[[MBProgressHUD alloc] initWithView:self.view];
                errorHud.labelText=@"下载失败,请重试";
                errorHud.mode=MBProgressHUDModeText;
                [self.view bringSubviewToFront:errorHud];
                [self.view addSubview:errorHud];
                [errorHud show:YES];
                [errorHud hide:YES afterDelay:1];
                [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"图片下载失败,error:%@",error]];
                DDLogInfo(@"Error: %@",error);
                [fileManager removeItemAtPath:[file_path filePathOfCaches] error:nil];
            }];
            [operation start];
            break;
        }
        case 1:
        {
            //本地图片
            //加载本地
            [ibPhoto setImage:[UIImage imageWithContentsOfFile:[filePathArray[1] filePathOfCaches]]];
            break;
        }
        case 2:
        {
            //图片为空
            [ibPhoto setImage:[UIImage imageNamed:@"FriendsSendsPicturesNo.png"]];
            break;
        }
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
//        DDLogInfo(@"0");
        
        UITapGestureRecognizer *tapGes_grayView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGestureAction:)];
        UITapGestureRecognizer *tapGes_addView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGestureAction:)];
        self.grayView.alpha = 0.3;
        [self.grayView addGestureRecognizer:tapGes_grayView];
        [self.addView addGestureRecognizer:tapGes_addView];
        CGRect frame = self.navigationController.view.frame;
        [self.addView setFrame:CGRectMake(35, frame.origin.y + 90, self.addView.frame.size.width, self.addView.frame.size.height)];
        [self.navigationController.view addSubview:self.grayView];
        [self.navigationController.view addSubview:self.addView];
    }else if(buttonIndex == 1){
//        DDLogInfo(@"1");
        
    }
}

-(void)TapGestureAction:(UITapGestureRecognizer *)sender{
    [self.text_name resignFirstResponder];
}

- (IBAction)determineAction:(id)sender {
   

    if ([self.text_name.text isEqualToString:@""]) {
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"名字不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertV show];
        return;
    }
    
//    [self createImagePath];
}
/*
-(NSString *)createImagePath{
    NSString *sqliteattachmentPath=[attachmentImage_PATH filePathOfDocuments];
    //判断目录是否存在，不存在则创建目录
//    NSString *sqliteDictionary = [sqliteattachmentPath stringByDeletingLastPathComponent];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:sqliteattachmentPath]) {
        [fileManager createDirectoryAtPath:sqliteattachmentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png",sqliteattachmentPath,self.text_name.text];
    NSData *imageData = UIImagePNGRepresentation(self.ibPhoto.image);
    [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
    
    return sqliteattachmentPath;
}
*/
- (IBAction)cancelAction:(id)sender {
    [self.grayView removeFromSuperview];
    [self.addView removeFromSuperview];
    self.text_name.text = nil;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.ibPhoto;
}
#pragma mark scrollView 单击事件
BOOL is_touch;
-(void)scrollViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event whichView:(id)scrollView{
//    [self.navigationController popViewControllerAnimated:NO];
    DDLogInfo(@"单击");
    if (is_touch) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.navigationController.navigationBarHidden=YES;
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        self.navigationController.navigationBarHidden=NO;
    }
    is_touch=!is_touch;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)button:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
    UIButton *butt=(UIButton *)sender;
    if (!butt.selected) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.navigationController.navigationBarHidden=YES;
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        self.navigationController.navigationBarHidden=NO;
    }
    butt.selected=!butt.selected;
    
}

@end


//@implementation UIImage (Resizing)

//CGSize calculateProportionalResize(CGSize originalSize, CGSize frameSize) {
//    float x1 = originalSize.width;
//    float y1 = originalSize.height;
//    float x2 = frameSize.width;
//    float y2 = frameSize.height;
//    
//    float deltaX = x2 / x1;
//    float deltaY = y2 / y1;
//    
//    float delta = deltaX < deltaY ? deltaX : deltaY;
//    
//    return CGSizeMake(floorf(delta*x1), floorf(delta*y1));
//}
//
//- (UIImage *)resizeToFrame:(CGSize)newSize {
//    return [self resizeToSize:calculateProportionalResize([self size],newSize)];
//}
//- (UIImage *)resizeToSize:(CGSize)newSize {
//    UIGraphicsBeginImageContext(newSize);
//    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}
//@end