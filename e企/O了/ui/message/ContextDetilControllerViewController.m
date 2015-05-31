//
//  ContextDetilControllerViewController.m
//  e企
//
//  Created by HC_hmc on 15/3/30.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "ContextDetilControllerViewController.h"
@interface ContextDetilControllerViewController (){
    UIImage *image;
    MBProgressHUD *HUD;
    NSString *textstr;
    NSMutableArray *contentarray;
    NSMutableDictionary *imagearray;
    int contenttype;//0 原来版本，1后来版本
}
@end
@implementation ContextDetilControllerViewController
@synthesize bgview;
- (void)viewDidLoad {
    [super viewDidLoad];
    HUD=[[MBProgressHUD alloc] initWithView:self.view];
    HUD.removeFromSuperViewOnHide=YES;
    HUD.mode=MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.labelText=@"加载全文";
    [self.view bringSubviewToFront:HUD];
    [self.view addSubview:HUD];
    [HUD show:YES];
    contentarray=[[NSMutableArray alloc]init];
    imagearray=[[NSMutableDictionary alloc]init];
    // Do any additional setup after loading the view from its nib.

        AFClient *client = [AFClient sharedClient];
        NSDictionary *dict=@{@"noticeIds":_bulletinID};
        DDLogInfo(@"接口传输字典：%@",dict);
        //noticeinfo_multi
        [client postPath:@"eas/noticeinfo_multi" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             DDLogInfo(@"拉取公告回执回执%@",operation.responseString);
             NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
             
             DDLogInfo(@"%@",dic[@"data"]);
             @try {
                 NSDictionary *datadic = dic[@"data"][0];
                 _context =[[BulletinModel alloc]init];
                 _context.createTime=[datadic objectForKey:@"create_time"];
                 _context.title=datadic[@"title"];
                 _context.picUrl=datadic[@"pic_url"];
                 textstr=datadic[@"main_text"];
//                 textstr=@"[{\"text\":\"你好你好你好的撒都是极爱点击萨基低级扫大街哦撒奇偶的奇偶撒娇动机扫大街哦撒奇偶的奇偶撒娇冬季骚动打死傲娇帝萨基点击萨基\",\"picUrl\":\"http://218.205.81.42/upload/picture/20150505/original/2b8f1b3804d145af8ad1b74f10c10952.jpg\"},{\"text\":\"王浩王浩测试测试djsiajdiasjidjni我当年是你滴啊基督教ijsiajidjsaijdijsai姐弟仨基督教赛季第撒娇低价阿斯顿及\",\"picUrl\":\"http://218.205.81.42/upload/picture/20150505/original/3b67b7e7ffc44ac1ad651f6e56c53e87.jpg\"}]";
                 NSString *str=[textstr substringToIndex:2];
                 if([str isEqualToString:@"[{"]){
                     contenttype=1;
                 }else{
                     contenttype=0;
                 }
                 if(contenttype==1){//改版后，分解多图文
                     NSData* textData = [textstr dataUsingEncoding:NSUTF8StringEncoding];
                     contentarray=[NSJSONSerialization JSONObjectWithData:textData options:NSJSONReadingMutableContainers error:nil];
                     int count=contentarray.count;
                     for(int i=0;i<count;i++){
                         if(contentarray[i][@"picUrl"]&&![contentarray[i][@"picUrl"] isEqualToString:@""]){
                             NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:contentarray[i][@"picUrl"]]];
                             UIImage *tempimage = [UIImage imageWithData:imgData];
                             [imagearray setValue:tempimage forKey:[NSString stringWithFormat:@"%d",i]];
                         }
                     }
                 }else{//改版前，展示封面
                     NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_context.picUrl]];
                     image = [UIImage imageWithData:imgData];
                 }
//                 DDLogCInfo(@"图片大小%f %f",image.size.width,image.size.height);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self reloadview];
                 });
             }
             @catch (NSException *exception) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [HUD hide:YES];
                     [[ConstantObject app] showWithCustomView:nil detailText:@"加载失败" isCue:1 delayTime:3 isKeyShow:NO];
                 });
             }
             @finally {
                 
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSInteger stateCode = operation.response.statusCode;
             DDLogInfo(@"拉去失败%d",stateCode);
             [HUD hide:YES];
             [self.navigationController popViewControllerAnimated:YES];
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"公告获取失败" detailText:@"网络异常或服务器异常，请稍后重试" isCue:1.5 delayTime:1.5 isKeyShow:NO];
        }];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadview{
    UILabel *tttitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 500)];
    tttitle.text=_context.title;
    tttitle.font=[UIFont systemFontOfSize:22];
    tttitle.numberOfLines=0;
    tttitle.lineBreakMode=NSLineBreakByCharWrapping;
    [tttitle sizeToFit];
    float  titleheight=tttitle.frame.size.height;
    
//    UILabel *ttlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 292, 1500)];
//    ttlabel.text=textstr;
//    ttlabel.lineBreakMode=NSLineBreakByCharWrapping;
//    ttlabel.font=[UIFont systemFontOfSize:14];
//    ttlabel.numberOfLines=0;
//    [ttlabel sizeToFit];
//    float  contextheight=ttlabel.frame.size.height;
//    NSLog(@"#######%f %f",titleheight,contextheight);
    float imageheight=image.size.height;
    float imagewidth=image.size.width;
    if(imagewidth>292){
        imageheight=imageheight*292/imagewidth;
        imagewidth=292;
    }
    if(!image){
        imageheight=0;
    }
    
    bgview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    bgview.backgroundColor=bgcor1;
    bgview.delegate=self;
    [self.view addSubview:bgview];
    
    UILabel *titlelb=[[UILabel alloc]initWithFrame:CGRectMake(14, 15, 292, titleheight)];
    titlelb.textColor=cor1;
    titlelb.font=[UIFont systemFontOfSize:22];
    titlelb.lineBreakMode=NSLineBreakByWordWrapping;
//    titlelb.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
    titlelb.text=_context.title;
    titlelb.numberOfLines=0;
//    [titlelb sizeToFit];
    [bgview addSubview:titlelb];
    
    UILabel *timelb=[[UILabel alloc]initWithFrame:CGRectMake(14, titlelb.frame.origin.y+titlelb.frame.size.height+11, 292, 12)];
    timelb.textColor=cor4;
    timelb.font=[UIFont systemFontOfSize:12];
    timelb.text=_context.createTime;
    [bgview addSubview:timelb];
    
    UIImageView *imageview;
    if(image){
        imageview=[[UIImageView alloc]initWithFrame:CGRectMake((320-imagewidth)/2, timelb.frame.origin.y+timelb.frame.size.height+16,imagewidth, imageheight)];
        imageview.image=image;
    }else{
        imageview=[[UIImageView alloc]initWithFrame:CGRectMake((320-imagewidth)/2, timelb.frame.origin.y+timelb.frame.size.height,imagewidth, imageheight)];
    }
    [bgview addSubview:imageview];
    
    float heigthmark=imageview.frame.origin.y+imageview.frame.size.height+16;
    
    if(contenttype==1){
        for(int i=0;i<contentarray.count;i++){
            
            NSString *itemstr=contentarray[i][@"text"];
            NSString *itemimage=contentarray[i][@"picUrl"];

            if(itemimage&&![itemimage isEqualToString:@""]){
                UIImage *timage=[imagearray objectForKey:[NSString stringWithFormat:@"%d",i]];
                float timagewidth=timage.size.width;
                float timageheight=timage.size.height;
                if(timagewidth>292){
                    timageheight=timageheight*292/timagewidth;
                    timagewidth=292;
                }
                UIImageView *tempimageview=[[UIImageView alloc]initWithFrame:CGRectMake((320-timagewidth)/2, heigthmark,timagewidth, timageheight)];
                tempimageview.image=timage;
                [bgview addSubview:tempimageview];
                heigthmark=heigthmark+timageheight+16;
            }
            if(itemstr&&![itemstr isEqualToString:@""]){
                UILabel *textlabel=[[UILabel alloc]initWithFrame:CGRectMake(9, heigthmark, 302, 40)];
                textlabel.textColor=[[UIColor alloc]initWithRed:89/255.0 green:89/255.0 blue:89/255.0 alpha:1];
                textlabel.font=[UIFont systemFontOfSize:14];
                textlabel.text=textstr;
                textlabel.lineBreakMode=NSLineBreakByCharWrapping;
                textlabel.numberOfLines=0;
                NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:itemstr];
                NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
                [paragraphStyle1 setLineSpacing:8];
                [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [itemstr length])];
                [textlabel setAttributedText:attributedString1];
                [textlabel sizeToFit];
                [bgview addSubview:textlabel];
                heigthmark=heigthmark+textlabel.frame.size.height+16;
            }
            
        }
    }else{
        UILabel *contentlb=[[UILabel alloc]initWithFrame:CGRectMake(9, heigthmark, 302, 40)];
//        contentlb.textColor=UIColorFromRGB(0f595959);
        contentlb.textColor=[[UIColor alloc]initWithRed:89/255.0 green:89/255.0 blue:89/255.0 alpha:1];
        contentlb.font=[UIFont systemFontOfSize:14];
        contentlb.text=textstr;
        contentlb.lineBreakMode=NSLineBreakByCharWrapping;
        contentlb.numberOfLines=0;
        NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:textstr];
        NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle1 setLineSpacing:8];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [textstr length])];
        [contentlb setAttributedText:attributedString1];
        [contentlb sizeToFit];
        [bgview addSubview:contentlb];
        heigthmark=heigthmark+contentlb.frame.size.height+16;
    }
    
//    if (_context.title.length>13) {
//        NSString *  titleStr=[_context.title substringToIndex:12];
//        titleStr=[NSString stringWithFormat:@"%@...",titleStr];
//        self.title=titleStr;
//    }else {
//        self.title=_context.title;
//    }
    float viewheight=heigthmark;
    if(viewheight<self.view.frame.size.height){
        viewheight=self.view.frame.size.height;
    }
    bgview.contentSize=CGSizeMake(320, viewheight);
     self.title=_context.title;
    [HUD hide:YES];
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
