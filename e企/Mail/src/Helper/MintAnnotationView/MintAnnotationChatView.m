//
//  MintAnnotationView.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationView
//

#import <QuartzCore/QuartzCore.h>
#import "MintAnnotationChatView.h"

static NSString* const keyModelId = @"mintACV_id";

@interface MintAnnotationChatView()
{
    BOOL isModified;
    NSMutableArray *tagViews;
}

@end

@implementation MintAnnotationChatView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        self.annotationList = [[NSMutableArray alloc] init];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //self.scrollEnabled = NO;
    [super drawRect:rect];
    
    for (UIView *tagView in tagViews) {
        [tagView removeFromSuperview];
    }
    
    if (self.annotationList == nil || self.attributedText.length  < 1) return;
    
    // 3. Find and draw
    
    [self.attributedText enumerateAttribute:keyModelId inRange:NSMakeRange(0, self.attributedText.length)
                                    options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                                        
                                        if ([self annotationForId:value]){
//                                            DDLogInfo(@"%d, %d",range.location, range.length);
                                            CFRange cfRange = CFRangeMake(range.location, range.length);
                                            [self calculatingTagRectAndDraw:cfRange];
                                            
                                            
                                        }
                                        
                                    }];
    
}

- (void) calculatingTagRectAndDraw:(CFRange) annoationStringRange
{
    /*
     Caclulating Rect and Draw
     */
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UITextView *textView = self;
    
    // 4) Find rect
    CFRange stringRange = annoationStringRange;
    UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:stringRange.location];
    UITextPosition *end = [textView positionFromPosition:begin offset:stringRange.length];
    UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];
    
    // 5) Need 2line?
    CGPoint firstCharPosition = [textView caretRectForPosition:begin].origin;
    CGPoint lastCharPosition = [textView caretRectForPosition:end].origin;
    
    if (firstCharPosition.y < lastCharPosition.y){
        
        // Finf pos of first line
        float secondY = firstCharPosition.y;
        CFRange secondStrRange = CFRangeMake(stringRange.location, 1); // first time is just init, not have mean of value
        NSInteger secondPos = stringRange.location;
        NSInteger cnt = 0;
        
        while (secondY < lastCharPosition.y) {
            
            secondPos++;
            cnt++;
            
            secondStrRange = CFRangeMake(secondPos, stringRange.length - cnt);
            UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
            CGPoint secondPosition = [textView caretRectForPosition:secondBegin].origin;
            secondY = secondPosition.y;
            
        }
        
        // Calculate rect
        UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
        UITextPosition *secondEnd = [textView positionFromPosition:secondBegin offset:secondStrRange.length];
        UITextRange *secondTextRange = [textView textRangeFromPosition:secondBegin toPosition:secondEnd];
        
        // 1st line
        [self drawTag:context Rect:[textView firstRectForRange:textRange]
                 name:[self textInRange:[textView textRangeFromPosition:textRange.start toPosition:secondBegin]]];
        
        // 2nd Line
    [self drawTag:context Rect:[textView firstRectForRange:secondTextRange]name:[self textInRange:secondTextRange]];
    }
    else{
        // Draw rect first line
        [self drawTag:context Rect:[textView firstRectForRange:textRange] name:[self textInRange:textRange]];
    }
}



#pragma mark - Draw Tag graphics

- (void) drawTag: (CGContextRef) context Rect:(CGRect) rect name:(NSString*)nameText
{
 
    
    if(self.nameTagImage){
        [self drawTagImageInRect:rect name:nameText];

    }
    else{
        [self drawRectangle:context Rect:rect];
    }
}

- (void) drawRectangle: (CGContextRef) context Rect:(CGRect) rect
{

    rect.size.width+=4;
    rect.size.height-=0;
    rect.origin.y+=0;
    rect.origin.x-=2;
  
    if (_nameTagColor == nil)
        self.nameTagColor = [UIColor colorWithRed:222.00/255.00 green:237.00/255.00 blue:254.00/255.00 alpha:1.000];
    if (_nameTagLineColor == nil)
        self.nameTagLineColor = [UIColor clearColor];
    
    CGContextSetFillColorWithColor(context, _nameTagColor.CGColor);
    CGContextSetStrokeColorWithColor(context, _nameTagLineColor.CGColor);
    
   
    
    // Draw line
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
    // Fill
    CGContextFillRect(context, rect);
    CGContextStrokeRectWithWidth(context, rect, 0.5);
   
    /*
    //画圆矩形
    //CGContextSaveGState(context);
    //设置线宽
    //CGContextSetLineWidth(context, 1);
    //设置填充颜色和画笔颜色
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:244.0/255.0 green:248.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor);
    //CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:207.0/255.0 green:221.0/255.0 blue:252.0/255.0 alpha:1.0].CGColor);
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x,rect.origin.y, rect.size.width, rect.size.height) cornerRadius:50].CGPath;
    CGContextAddPath(context, clippath);
    //CGContextClosePath(context);
     CGContextDrawPath(context, kCGPathFillStroke);
    */
}

- (void) drawTagImageInRect:(CGRect) rect name:(NSString*)nameText
{
    UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tagButton.frame=rect;
    CGRect frame=rect;//CGPoint center=tagButton.center;
    frame.size.height-=frame.size.height>20?7:0;
    frame.size.width+=6;
    frame.origin.x-=5.3;frame.origin.y+=0.3;
    tagButton.frame = frame;

    
//    UIImageView *iv=[[UIImageView alloc]initWithImage:self.nameTagImage];
//    iv.frame=tagButton.bounds;
    //[tagButton addSubview:iv];
    
    //[tagButton setBackgroundImage:self.nameTagImage forState:UIControlStateNormal];
    tagButton.backgroundColor=[UIColor colorWithRed:181/255.0 green:204/255.0 blue:250/255.0 alpha:0.08];
    tagButton.layer.borderWidth=1;
    tagButton.layer.borderColor=[UIColor colorWithRed:181/255.0 green:204/255.0 blue:250/255.0 alpha:1.0].CGColor;
    tagButton.layer.cornerRadius=8;tagButton.layer.masksToBounds=YES;
    //[tagButton setTitle:nameText forState:UIControlStateNormal];
    [tagButton setTitleColor:self.nameTagColor forState:UIControlStateNormal];
    tagButton.titleLabel.font = [UIFont systemFontOfSize:self.font.pointSize-4];
    //tagButton.alpha=0.3;
    
    if (!tagViews)
        tagViews = [[NSMutableArray alloc] init];
    
    [tagViews addObject:tagButton];
    [self addSubview:tagButton];
}


#pragma mark - Modeling

// --- NEW ---
- (void)addAnnotation:(MintAnnotation *)newAnnoation
{
    // Check aleady imported
    for (MintAnnotation *annotation in self.annotationList) {
        
        if ([annotation.usr_id isEqualToString:newAnnoation.usr_id])
        {
//            DDLogInfo(@"MintAnnoationChatView >> addAnoation >> id'%@'is aleady in", newAnnoation.usr_id);
            return;
        }
    }
    
    // Add
    if (!self.annotationList)
        self.annotationList = [[NSMutableArray alloc] init];
    /*
    NSString *name = [SqlAddressData queryMemberInfoWithEmail:newAnnoation.usr_id].name;
    if (name)
    {
        newAnnoation.usr_name = name;
    }*/
    [self.annotationList addObject:newAnnoation];
    
    // Insert Plain user name text
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] initWithDictionary:[self defaultAttributedString]];
    [attr setObject:newAnnoation.usr_id forKey:keyModelId];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc]
                                             initWithString:[NSString stringWithFormat:@"%@  ", [newAnnoation.usr_name length]>18?([NSString stringWithFormat:@"%@...",[newAnnoation.usr_name substringToIndex:18]]):(newAnnoation.usr_name)]
                                             attributes:attr];
    
    NSMutableAttributedString *spaceStringPefix = nil;
    NSString *tempCommentWriting = self.text;
    
//    DDLogInfo(@"nameString:%@",nameString);

    
    NSInteger cursor = self.selectedRange.location;
    // display name
    
    // Add Last
//    DDLogInfo(@"self.attributedText.string.length:%d",self.attributedText.string.length);
    if (cursor >= self.attributedText.string.length-1)
    {
        // Add Space
        if (tempCommentWriting.length > 0){
            
            NSString *prevString = [tempCommentWriting substringFromIndex:tempCommentWriting.length-1];
            
            if (![prevString isEqualToString:@"\n"])
            {
                spaceStringPefix = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
            }
        }
        
        NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        if (spaceStringPefix)
            [conts appendAttributedString:spaceStringPefix];
        [conts appendAttributedString:nameString];
        NSMutableAttributedString *afterBlank = [[NSMutableAttributedString alloc] initWithString:@"  "
                                                                                       attributes:[self defaultAttributedString]];
        [conts appendAttributedString:afterBlank];
        
//        DDLogInfo(@"conts:%@",conts);
        
        self.attributedText = conts;
//        DDLogInfo(@"\n\nself.attributedText:%@",self.attributedText);
        
    }
    // Insert in text
    else
    {
        self.attributedText = [self attributedStringInsertString:nameString at:cursor];
    }
    
    
    [self setNeedsDisplay];
    
    // Pass Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
}

- (NSRange) findTagPosition:(MintAnnotation*)annoation
{
    
    __block NSRange stringRange = NSMakeRange(0, 0);
    [self.attributedText enumerateAttribute:keyModelId inRange:NSMakeRange(0, self.attributedText.length-1)
                                    options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                                        
                                        if ([value isEqualToString:annoation.usr_id])
                                        {
                                            stringRange = range;
                                            //                                            stringRange = CFRangeMake(range.location, range.location + range.length);
                                        }
                                        
                                    }];
    
    return stringRange;
    
}

- (MintAnnotation *) annotationForId:(NSString*)usr_id
{
    for (MintAnnotation *annotation in self.annotationList) {
        
        if ([annotation.usr_id isEqualToString:usr_id])
            return annotation;
    }
    
    return nil;
}


- (NSString *)setTextWithTageedString:(NSString *)memo
{
    
    
    NSMutableAttributedString *parsingMemo = [[NSMutableAttributedString alloc] initWithString:memo];
    [parsingMemo setAttributes:[self defaultAttributedString] range:NSMakeRange(0, parsingMemo.length)];
    
//    DDLogInfo(@"memo:%@",parsingMemo);
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"<u uid=[^>]*>[^>]*<\\/u>"
                                  options:0
                                  error:&error];
    
    if (error){
//        DDLogInfo(@"error:%@",error.description);
        return nil;
    }
    
    [regex enumerateMatchesInString:parsingMemo.string options:0 range:NSMakeRange(0, [parsingMemo length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             
                             // detect
                             // <u uid=?>?</u>
                             NSRange range = [match rangeAtIndex:0];
                             NSString *insideString = [parsingMemo.string substringWithRange:range];
                             
                             // Name
                             NSRegularExpression *regexUsrName = [NSRegularExpression
                                                                  regularExpressionWithPattern:@">[가-힣a-zA-Z0-9]*<"
                                                                  options:0
                                                                  error:nil];
                             NSRange usrNameRange = [regexUsrName rangeOfFirstMatchInString:insideString
                                                                                    options:0
                                                                                      range:NSMakeRange(0, insideString.length)];
                             
                             if (usrNameRange.location != NSNotFound)
                             {
                                 NSString *userName = [insideString substringWithRange:usrNameRange];
                                 userName = [userName stringByReplacingOccurrencesOfString:@">" withString:@""];
                                 userName = [userName stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                                 DDLogInfo(@"userName:%@",userName);
                                 
                                 // ID
                                 NSRegularExpression *regexUsrID = [NSRegularExpression
                                                                    regularExpressionWithPattern:@"uid=[^>]*"
                                                                    options:0
                                                                    error:nil];
                                 NSRange usrIDRange = [regexUsrID rangeOfFirstMatchInString:insideString
                                                                                    options:0
                                                                                      range:NSMakeRange(0, insideString.length)];
                                 NSString *userID = [insideString substringWithRange:usrIDRange];
                                 userID = [userID stringByReplacingOccurrencesOfString:@"uid=" withString:@""];
                                 userID = [userID stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                                 DDLogInfo(@"userID:%@",userID);
                                 
                                 if (userID && userName)
                                 {
                                     MintAnnotation *annotation = [[MintAnnotation alloc] init];
                                     annotation.usr_id = userID;
                                     annotation.usr_name = userName;
                                     
                                     if (!self.annotationList) self.annotationList = [[NSMutableArray alloc] init];
                                     NSString *name = [SqlAddressData queryMemberInfoWithEmail:annotation.usr_id].name;
                                     if (name) {
                                         annotation.usr_name = name;
                                     }
                                     [self.annotationList addObject:annotation];
                                     
                                     NSRange userNameStringRange = NSMakeRange(range.location + usrNameRange.location+1, usrNameRange.length-2);
//                                     DDLogInfo(@"nameRange:%d,%d",userNameStringRange.location,userNameStringRange.length);
                                     [parsingMemo addAttribute:keyModelId value:userID range:userNameStringRange];
                                 }
                                 
                                 
                             }
                             
                         }];
    
    
    NSRange r;
    
    while ((r = [[parsingMemo mutableString] rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        [[parsingMemo mutableString] replaceCharactersInRange:r withString:@""];
    }
    
    self.attributedText = parsingMemo;
    [self setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
    
    
    return self.attributedText.string;
}

#pragma mark - UITextviewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self setNeedsDisplay];
    // length = 0, but attributed have id
    if (self.attributedText.string.length == 0)
    {
        [self clearAllAttributedStrings];
    }
    
    return;
    
}

- (BOOL) shouldChangeTextInRange:(NSRange)editingRange replacementText:(NSString *)text
{
    
    __block BOOL result = YES;
    
    // ALl clear
    if (editingRange.location == 0 && editingRange.length == self.attributedText.string.length)
    {
//        DDLogInfo(@"<<<<<< --- all cleared by keyboard");
        [self clearAll];
        return YES;
    }
    
    // Checking Trying to insert within tag
    if (text.length > 0)
    {
        NSRange rangeOfCheckingEditingInTag = editingRange;
        if (rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length <= self.attributedText.length)
        {
            rangeOfCheckingEditingInTag.length = 1;
            rangeOfCheckingEditingInTag.location-=1;
            
//            DDLogInfo(@"<<<<< ----------- 1");
            
            //
            NSInteger totalLength = rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length;
            if (totalLength > self.attributedText.length)
            {
                rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
//                DDLogInfo(@"<<<<< ----------- 2");
            }
            else if (totalLength < 1)
            {
                rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
//                DDLogInfo(@"<<<<< -------------3");
            }
        }
        
        
        [self.attributedText enumerateAttributesInRange:rangeOfCheckingEditingInTag options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            if ([attrs objectForKey:keyModelId] && [self annotationForId:[attrs objectForKey:keyModelId]])
            {
                DDLogInfo(@"------- Editing In Tag");
                result = NO;
            }
            
        }];
        
        
        return result;
    }
    // Deleting
    else
    {
        editingRange.location-=1;
        if (editingRange.location == -1)
            editingRange.location = 0;
        
        if (editingRange.length == 0)
        {
//            DDLogInfo(@"location >>>> 0");
            
            if (self.attributedText.length == 0)
            {
                [self clearAllAttributedStrings];
            }
            
            return YES;
            
        }
//        DDLogInfo(@"editingRange :%d, %d",editingRange.location, editingRange.length);
        
        [self.attributedText enumerateAttributesInRange:editingRange options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            if ([attrs objectForKey:keyModelId] && [self annotationForId:[attrs objectForKey:keyModelId]])
            {
                
                NSRange tagRange = [self findTagPosition:[self annotationForId:[attrs objectForKey:keyModelId]]];
                
//                DDLogInfo(@"Deleted annotation tag >>>>> id(%@):range(%d,%d)",[attrs objectForKey:keyModelId], tagRange.location, tagRange.length);
                
                self.attributedText = [self attributedStringWithCutOutOfRange:tagRange];
                self.selectedRange = NSMakeRange(tagRange.location, 0);
                
                [self.annotationList removeObject:[self annotationForId:[attrs objectForKey:keyModelId]]];
                [self setNeedsDisplay];
            }
            
        }];
        
        return YES;
        
    }
    
}


#pragma mark - AttributedStrings
- (NSAttributedString *) attributedStringWithCutOutOfRange:(NSRange)cuttingRange
{
    /*
     Cut out string of range on full string
     to get head + tail without middle
     */
    
    // Cutting Heads
    NSAttributedString *head = nil;
    if (cuttingRange.location > 0 && cuttingRange.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, cuttingRange.location-1)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    // Cutting Tail
    
    NSAttributedString *tail = nil;
    if (cuttingRange.location + cuttingRange.length <= self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(cuttingRange.location + cuttingRange.length,
                                                                             self.attributedText.length - 1 - cuttingRange.location - cuttingRange.length)];
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    if (head)
        [conts appendAttributedString:head];
    if (tail)
        [conts appendAttributedString:tail];
    
    return conts;
}

- (NSAttributedString *) attributedStringInsertString:(NSAttributedString*)insertingStr at:(NSInteger)position
{
    /*
     Insert str within text at position
     with blank
     -> head + blank + insertingStr + blank + tail
     */
    
    // Cutting Heads
    NSAttributedString *head = nil;
    if (position > 0 && self.attributedText.string.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, position)];
    else if (position > 0)
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    // Cutting Tail
    NSAttributedString *tail = nil;
    if (position + 1 < self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(position,
                                                                             self.attributedText.length - position)];
    else{
        tail = [[NSMutableAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]];
    }
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    if (head)
    {
        [conts appendAttributedString:head];
        [conts appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]]];
    }
    
    [conts appendAttributedString:insertingStr];
    
    if (tail)
    {
        [conts appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]]];
        [conts appendAttributedString:tail];
    }
    
    return conts;
}

- (NSDictionary*) defaultAttributedString
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    return @{NSFontAttributeName : self.font,
             NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle
             };
}



#pragma mark -ETC

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    #pragma mark -复制 黏贴
    /*
     Couldn't Cut, Copy, Past
     */
    return NO;
}

- (NSString*) makeStringWithTag
{
    
    NSMutableAttributedString *workingStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Finding Replace ranges and annoations
    [workingStr enumerateAttribute:keyModelId inRange:NSMakeRange(0, workingStr.string.length) options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            
                            MintAnnotation *annoation = nil;
                            if (value){
                                annoation = [self annotationForId:value];
                            }
                            
                            if (annoation){
                                NSString *replaceTo = [NSString stringWithFormat:@"<u uid=%@>%@</u>",
                                                       annoation.usr_id,
                                                       annoation.usr_name];
                                [workingStr replaceCharactersInRange:range withString:replaceTo];
                                
                            }
                            
                        }];
    
    return workingStr.string;
    
}

- (NSString*) makeString
{
    NSMutableString *str = [NSMutableString new];
    for (MintAnnotation *annotation in self.annotationList) {
        [str appendFormat:@"%@  ",annotation.usr_name];
    }
    [str appendFormat:@"%@  ",[self makeStringWithoutTagString]];
    NSString *temptext = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    temptext = [temptext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    if (temptext.length == 0) {
        return @"";
    }
    return str;
}

- (NSString*) makeStringWithoutTagString
{
    
    NSMutableAttributedString *workingStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Finding Replace ranges and annoations
    [workingStr enumerateAttribute:keyModelId inRange:NSMakeRange(0, workingStr.string.length) options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            
                            MintAnnotation *annoation = nil;
                            if (value){
                                annoation = [self annotationForId:value];
                            }
                            
                            if (annoation){
                                [workingStr replaceCharactersInRange:range withString:@""];
                                
                            }
                            
                        }];
    
    return workingStr.string;
    
}

- (void) clearAllAttributedStrings
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedString removeAttribute: keyModelId range: NSMakeRange(0, self.text.length)];
    [self.annotationList removeAllObjects];
    [self setNeedsDisplay];
//    DDLogInfo(@"cleared attributes!");
}


- (void)clearAll
{
    [self clearAllAttributedStrings];
    self.attributedText = [[NSAttributedString alloc]initWithString:@"" attributes:[self defaultAttributedString]];
    [self setNeedsDisplay];
}
@end
