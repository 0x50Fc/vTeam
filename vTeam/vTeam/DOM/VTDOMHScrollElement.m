//
//  VTDOMHScrollElement.m
//  vTeam
//
//  Created by zhang hailong on 14-1-1.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VTDOMHScrollElement.h"

#import "VTDOMView.h"

#import "VTDOMElement+Layout.h"
#import "VTDOMElement+Style.h"


@implementation VTDOMHScrollElement

-(CGSize) layoutChildren:(UIEdgeInsets)padding{
    
    CGSize size = self.frame.size;
    
    CGSize contentSize = CGSizeMake(0, size.height);
    
    for (VTDOMElement * element in [self childs]) {
        
        [element layout:size];
        
        CGRect r = element.frame;
        
        UIEdgeInsets margin = [element margin];
    
        r.origin = CGPointMake(contentSize.width + margin.left + padding.left, padding.top);
        r.size.height = size.height - padding.top - padding.bottom;
        
        [element setFrame:r];
        
        contentSize.width += r.size.width + margin.left + margin.right;
    }
    
    contentSize.width += padding.left + padding.right;
    
    [self setContentSize:contentSize];
    
    if([self isViewLoaded]){
        [self.contentView setContentSize:contentSize];
    }
    
    return size;
}

@end
