//
//  LdTKRoundedView.m
//  GroupV
//
//  Created by lurn on 2/9/14.
//  Copyright (c) 2014 Lordar. All rights reserved.
//

#import "LdTKRoundedView.h"

#define _BORDER_COLOR [UIColor colorWithRed:189/255.0f green:187/255.0f blue:183/255.0f alpha:1.0f];
#define _FILL_COLOR [UIColor colorWithRed:240/255.0f green:241/255.0f blue:242/255.0f alpha:1.0f];
#define _BORDER_RADIUS 5.0f

@implementation LdTKRoundedLightGrayBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self assignAttrs];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self assignAttrs];
    }
    return self;
}

-(void)assignAttrs
{
    self.fillColor = [UIColor clearColor];
    self.borderColor = _BORDER_COLOR;
    self.cornerRadius = _BORDER_RADIUS;
}

@end

@implementation LdTKRoundedLightGrayBgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self assignAttrs];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self assignAttrs];
    }
    return self;
}

-(void)assignAttrs
{
    self.fillColor = _FILL_COLOR;
    self.borderColor = [UIColor clearColor];
    self.cornerRadius = _BORDER_RADIUS;
}

@end


@implementation LdTKRoundedDarkGrayBgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self assignAttrs];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self assignAttrs];
    }
    return self;
}

-(void)assignAttrs
{
    self.fillColor = [UIColor darkGrayColor];
    self.borderColor = [UIColor clearColor];
    self.cornerRadius = _BORDER_RADIUS;
}
@end
