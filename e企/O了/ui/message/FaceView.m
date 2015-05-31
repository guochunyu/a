//
//  FaceView.m
//  O了
//
//  Created by 化召鹏 on 14-1-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "FaceView.h"
#import "FaceViewButton.h"
#define facebuttonconut 126
@implementation FaceView{
    NSArray *faceNameArray;//文本显示名字
    NSArray *emojiFaceArray;
    NSArray *faceExpressionArray;//文本传输名字
    NSArray *faceImageArray;
    NSMutableArray *_faceArray;//图片名字
    int facetype;
    int pagecount;//表情符号分页数量
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
//        self.backgroundColor=[UIColor lightGrayColor];
        facetype=0;
        pagecount=4;
        [self drawfaceview];
        [self addSubview:_faceView];
        _facePageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(110, _faceView.frame.size.height-20, 100, 20)];
        [_facePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
        _facePageControl.numberOfPages=pagecount;
        _facePageControl.currentPage=0;
        _facePageControl.pageIndicatorTintColor=[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1];
        _facePageControl.currentPageIndicatorTintColor=[UIColor colorWithRed:122/255.0 green:120/255.0 blue:120/255.0 alpha:1];
        //        _facePageControl.backgroundColor=[UIColor redColor];
        [self addSubview:_facePageControl];
        UIView *bottonview=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-30, 320, 30)];
        [bottonview setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1]];
        [self addSubview:bottonview];
        
        UIButton *face1button=[UIButton buttonWithType:UIButtonTypeCustom];
        face1button.frame=CGRectMake(0, self.frame.size.height-30, 50, 30);
        face1button.tag=1001;
//        [face1button setTitle:@"表情1" forState:UIControlStateNormal];
        face1button.adjustsImageWhenHighlighted = NO;
        [face1button setBackgroundImage:[UIImage imageNamed:@"icon_express_smile_pre.png"] forState:UIControlStateNormal];
        [face1button addTarget:self action:@selector(facetypechange:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:face1button];
        
        UIButton *face2button=[UIButton buttonWithType:UIButtonTypeCustom];
        face2button.frame=CGRectMake(50, self.frame.size.height-30, 50, 30);
        face2button.tag=1002;
//        [face2button setTitle:@"表情2" forState:UIControlStateNormal];
         face2button.adjustsImageWhenHighlighted = NO;
        [face2button setBackgroundImage:[UIImage imageNamed:@"icon_express_yellow_nm.png"] forState:UIControlStateNormal];
        [face2button addTarget:self action:@selector(facetypechange:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:face2button];
        
        UIButton *sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame=CGRectMake(self.frame.size.width-50, self.frame.size.height - 30, 50, 30);
        [sendButton setImage:[UIImage imageNamed:@"face_send_pre.png"] forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendFace:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
        
    }
    return self;
}
-(void)facetypechange:(id)sender{
    
    UIButton *butt=(UIButton *)sender;
    if(butt.tag==facetype+1001){
        return ;
    }
    DDLogInfo(@"表情切换");
    facetype=1-facetype;
    if(facetype==0){
        pagecount=4;
    }else{
        pagecount=7;
    }
    [_faceView removeFromSuperview];
    _faceView=nil;
    [self drawfaceview];
    if(facetype==0){
        UIButton *face1button=(UIButton *)[self viewWithTag:1001];
        [face1button setBackgroundImage:[UIImage imageNamed:@"icon_express_smile_pre.png"] forState:UIControlStateNormal];
        UIButton *face2button=(UIButton *)[self viewWithTag:1002];
        [face2button setBackgroundImage:[UIImage imageNamed:@"icon_express_yellow_nm.png"] forState:UIControlStateNormal];
    }else{
        UIButton *face1button=(UIButton *)[self viewWithTag:1001];
        [face1button setBackgroundImage:[UIImage imageNamed:@"icon_express_smile_nm.png"] forState:UIControlStateNormal];
        UIButton *face2button=(UIButton *)[self viewWithTag:1002];
        [face2button setBackgroundImage:[UIImage imageNamed:@"icon_express_yellow_pre.png"] forState:UIControlStateNormal];
    }
    [self addSubview:_faceView];
    [_facePageControl removeFromSuperview];
    _facePageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(110, _faceView.frame.size.height-20, 100, 20)];
    [_facePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    _facePageControl.numberOfPages=pagecount;
    _facePageControl.currentPage=0;
    _facePageControl.currentPageIndicatorTintColor=[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1];
    _facePageControl.pageIndicatorTintColor=[UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1];
    //        _facePageControl.backgroundColor=[UIColor redColor];
    [self addSubview:_facePageControl];
//    self viewWithTag:<#(NSInteger)#>
}
-(void)drawfaceview{
    self.faceView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 165)];
    _faceView.pagingEnabled=YES;//分页
    _faceView.contentSize=CGSizeMake(pagecount*320, 165);
    _faceView.showsHorizontalScrollIndicator=NO;
    _faceView.showsVerticalScrollIndicator=NO;
    _faceView.delegate=self;
    _faceView.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    switch (facetype) {
        case 0:{
            emojiFaceArray=@[@"😄",@"😊",@"😉",@"😍",@"😘",@"😚",@"😜",@"😝",@"😳",@"😁",@"😔",@"😒",@"😢",@"😂",@"😭",@"😰",@"😓",@"😨",@"😱",@"😖",@"😡",@"😷",@"😲",@"😏",@"💀",@"👽",@"💩",@"🔥",@"💨",@"👄",@"👍",@"👎",@"👌",@"✌",@"👻",@"👏",@"👫",@"💑",@"👯",@"🎁",@"👑",@"❤",@"💔",@"💘",@"💋",@"💎",@"💍",@"🎂",@"☀",@"☁",@"⚡",@"☔",@"🍜",@"☕",@"🍻",@"🍰",@"🍦",@"🍔",@"🍉",@"💊",@"💰",@"🀄",@"🎤",@"🎵",@"🚀",@"✈",@"🚗",@"🎩",@"🚲",@"🔫",@"🎸",@"💣",@"🌟",@"🐶",@"🐱",@"🐷",@"🐰",@"🐤",@"🐔",@"🎅"];
//                NSString *str=[NSString stringWithFormat:@"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"@\"%C\"",0xE415,0xE056,0xE405,0xE106,0xE418,0xE417,0xE105,0xE409,0xE40D,0xE404,0xE403,0xE40E,0xE413,0xE412,0xE411,0xE40F,0xE108,0xE40B,0xE107,0xE407,0xE416,0xE40C,0xE410,0xE402,0xE11C,0xE10C,0xE05A,0xE11D,0xE330,0xE41C,0xE00E,0xE421,0xE420,0xE011,0xE11B,0xE41F,0xE428,0xE425,0xE429,0xE112,0xE10E,0xE022,0xE023,0xE329,0xE003,0xE035,0xE034,0xE34B,0xE04A,0xE049,0xE13D,0xE04B,0xE340,0xE045,0xE30C,0xE046,0xE33A,0xE120,0xE348,0xE30F,0xE12F,0xE12D,0xE03C,0xE03E,0xE10D,0xE01D,0xE01B,0xE503,0xE136,0xE113,0xE041,0xE311,0xE335,0xE052,0xE04F,0xE10B,0xE52C,0xE523,0xE52E,0xE448];
            
            int j=0;
            for (int i=0; i<emojiFaceArray.count; i++) {
                FaceViewButton *butt=[FaceViewButton buttonWithType:UIButtonTypeCustom];
                butt.buttonIndex=i;
                [butt addTarget:self action:@selector(faceButtClick:) forControlEvents:UIControlEventTouchUpInside];
                
                butt.frame = CGRectMake((((j)%21)%7)*44+6+((j)/21*320), (((j)%21)/7)*44+8, 44, 44);
                butt.titleLabel.font=[UIFont systemFontOfSize:30];
                j++;
                if ( ((i+1)%20==0 || i==emojiFaceArray.count-1)&&j!=0) {
                    [butt setTitle:emojiFaceArray[i] forState:UIControlStateNormal];
                    FaceViewButton *butt_delete=[FaceViewButton buttonWithType:UIButtonTypeCustom];
                    [butt_delete setImage:[UIImage imageNamed:@"tenpay_del_press.png"] forState:UIControlStateNormal];
                    [butt_delete addTarget:self action:@selector(faceDeleteButtClick:) forControlEvents:UIControlEventTouchUpInside];
                    
                    butt_delete.frame = CGRectMake((((j)%21)%7)*44+6+((j)/21*320), (((j)%21)/7)*44+8, 44, 44);
                    
                    j++;
                    [_faceView addSubview:butt_delete];
                }else{
                    [butt setTitle:emojiFaceArray[i] forState:UIControlStateNormal];
                    
                }
                [_faceView addSubview:butt];
            }
            break;
        }
        case 1:{
            faceNameArray=[[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression_custom" ofType:@"plist"]];//表情显示的文本
            faceExpressionArray=[[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"]];//表情传输文本
//            _faceArray=[[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face_imagename" ofType:@"plist"]];
            int j=0;
            for (int i=0; i<facebuttonconut; i++) {
                FaceViewButton *butt=[FaceViewButton buttonWithType:UIButtonTypeCustom];
                butt.buttonIndex=i;
                [butt addTarget:self action:@selector(faceButtClick:) forControlEvents:UIControlEventTouchUpInside];
                
                butt.frame = CGRectMake((((j)%21)%7)*44+6+((j)/21*320), (((j)%21)/7)*44+8, 44, 44);
                j++;
                if ( ((i+1)%20==0 || i==facebuttonconut-1)&&j!=0) {
                    butt.imageview.image=[UIImage imageNamed:[NSString stringWithFormat:@"Expression_%d.png",i+1]];
                    FaceViewButton *butt_delete=[FaceViewButton buttonWithType:UIButtonTypeCustom];
                    [butt_delete setImage:[UIImage imageNamed:@"tenpay_del_press.png"] forState:UIControlStateNormal];
                    [butt_delete addTarget:self action:@selector(faceDeleteButtClick:) forControlEvents:UIControlEventTouchUpInside];
                    butt_delete.frame = CGRectMake((((j)%21)%7)*44+6+((j)/21*320), (((j)%21)/7)*44+8, 44, 44);
                    
                    j++;
                    [_faceView addSubview:butt_delete];
                }else{
                    butt.imageview.image=[UIImage imageNamed:[NSString stringWithFormat:@"Expression_%d.png",i+1]];
                }
                [_faceView addSubview:butt];
            }
            
            break;
        }
        default:
            break;
    }
}
- (void)pageChange:(id)sender {
    _facePageControl.currentPage=_faceView.contentOffset.x/320;
    [_facePageControl updateCurrentPageDisplay];
}
-(void)faceButtClick:(id)sender{

    FaceViewButton *butt=(FaceViewButton *)sender;
    if (self.faceClick) {
        self.faceClick(sender);
    }
    int i=butt.buttonIndex;
    NSMutableString *faceString = [[NSMutableString alloc] initWithString:self.inputTextView.text];
    NSString *faceName;
    if(facetype==0){
        faceName=emojiFaceArray[butt.buttonIndex];
    }else{
        faceName=faceNameArray[butt.buttonIndex];
    }
    [faceString appendString:faceName];
    NSString *result;
    
    if (self.inputTextView.text.length==0) {
        result=faceName;
    }else{
        //判断光标
        int location = self.inputTextView.selectedRange.location;
        
        result= [NSString stringWithFormat:@"%@%@%@",[self.inputTextView.text substringToIndex:location],faceName,[self.inputTextView.text substringFromIndex:location]];
        
    }
    self.inputTextView.text = result;
    
    return;
//    
//    if (i%21==0) {
//        if (self.inputTextView.text.length==0) {
//            
//        }else{
//            NSString *deleteStr;
//            NSString *tempStr=[self.inputTextView.text substringFromIndex:self.inputTextView.text.length-1];
//            if ([tempStr isEqualToString:@"]"]) {
//                NSString *tempTwoStr=[self.inputTextView.text substringFromIndex:self.inputTextView.text.length-4];
//                NSString *tempFirstStr=[tempTwoStr substringToIndex:1];
//                if ([tempFirstStr isEqualToString:@"["]) {
//                    deleteStr=[self.inputTextView.text substringToIndex:self.inputTextView.text.length-4];
//                }else{
//                    NSString *tempThreeStr=[self.inputTextView.text substringFromIndex:self.inputTextView.text.length-5];
//                    NSString *tempFirstStr1=[tempThreeStr substringToIndex:1];
//                    if ([tempFirstStr1 isEqualToString:@"["]) {
//                        deleteStr=[self.inputTextView.text substringToIndex:self.inputTextView.text.length-5];
//                    }
//                }
//            }else{
//                deleteStr=[self.inputTextView.text substringToIndex:self.inputTextView.text.length-1];
//            }
//            
//            
//            str = deleteStr;
//            self.inputTextView.text=str;
//        }
//        
//        
//    }
//    else{
//
////        if (i<10) {
////            str=[NSString stringWithFormat:@"[0%d]",i-i/21];
////        }else{
////            str=[NSString stringWithFormat:@"[%d]",i-i/21];
////        }
//        NSString *faceName=[faceNameArray objectAtIndex:i-i/21-1];
//        
//        [faceString appendString:faceName];
//        NSString *result;
//        
//        
//        if (self.inputTextView.text.length==0) {
//            result=faceName;
//        }else{
//            //判断光标
//            int location = self.inputTextView.selectedRange.location;
//            
//            result= [NSString stringWithFormat:@"%@%@%@",[self.inputTextView.text substringToIndex:location],faceName,[self.inputTextView.text substringFromIndex:location]];
//            
//        }
//        self.inputTextView.text = result;
//    }
//
}
-(void)faceDeleteButtClick:(id)sender{
    if (self.faceClick) {
        self.faceClick(sender);
    }
    NSString *str=self.inputTextView.text;
    if (str.length<=0) {
        return;
    }
    if (str.length>1 && [self stringContainsEmoji:[str substringFromIndex:str.length-2]]) {
        str=[str substringToIndex:str.length-2];
    }else{
        NSString *text=[str substringFromIndex:str.length-1];
        
        if([text isEqualToString:@"]"]){
            for(NSString * facestr in faceNameArray){
                
                if(str.length>= facestr.length){
                    NSString *rangestr=[str substringFromIndex:str.length-facestr.length];
                    if([rangestr isEqualToString:facestr]){//表情标签
                        str=[str substringToIndex:str.length-facestr.length];
                        self.inputTextView.text=str;
                        return ;
                    }
                }
            }
        }
        str=[str substringToIndex:str.length-1];
    }
    self.inputTextView.text=str;
}
#pragma mark - 限制系统表情
- (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (hs == 0x263a)
         {
             returnValue = YES;
             
         }
         // surrogate pair
         else
             if (0xd800 <= hs && hs <= 0xdbff) {
                 if (substring.length > 1) {
                     const unichar ls = [substring characterAtIndex:1];
                     const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                     if (0x1d000 <= uc && uc <= 0x1f77f) {
                         returnValue = YES;
                     }
                 }
             } else if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 if (ls == 0x20e3) {
                     returnValue = YES;
                 }
                 
             } else {
                 // non surrogate
                 if (0x2100 <= hs && hs <= 0x27ff) {
                     returnValue = YES;
                 } else if (0x2B05 <= hs && hs <= 0x2b07) {
                     returnValue = YES;
                 } else if (0x2934 <= hs && hs <= 0x2935) {
                     returnValue = YES;
                 } else if (0x3297 <= hs && hs <= 0x3299) {
                     returnValue = YES;
                 } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                     returnValue = YES;
                 }
             }
     }];

    return returnValue;
}
-(void)sendFace:(id)sender{
//    UIButton *butt=(UIButton *)sender;
    [self.delegate sendFaceButtClick:self.inputTextView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _facePageControl.currentPage=_faceView.contentOffset.x/320;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
