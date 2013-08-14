//
//  VTDOMElement+Layout.h
//  vTeam
//
//  Created by zhang hailong on 13-8-14.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <vTeam/VTDOMElement+Frame.h>

@interface VTDOMElement (Layout)

@property(nonatomic,assign) CGSize contentSize;
@property(nonatomic,readonly) UIEdgeInsets padding;

-(CGSize) layoutChildren:(UIEdgeInsets) padding;

-(CGSize) layout:(CGSize) size;

@end
