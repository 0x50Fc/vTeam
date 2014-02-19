//
//  VTDOMStatusElement.m
//  vTeam
//
//  Created by zhang hailong on 14-2-19.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VTDOMStatusElement.h"

#import "VTDOMElement+Render.h"

#import "VTDOMViewElement.h"

#import "UIView+VTDOMElement.h"

@implementation VTDOMStatusElement

-(void) setAttributeValue:(NSString *)value forKey:(NSString *)key{
    [super setAttributeValue:value forKey:key];
    if([key isEqualToString:@"status"]){
        [self refreshStatus];
    }
}

-(void) refreshStatusForElement:(VTDOMElement *) element forStatus:(NSString *) status{
    NSString * s = [element attributeValueForKey:@"status"];
    [element setAttributeValue: s == status || [status isEqualToString:s] ? @"false":@"true" forKey:@"hidden"];
    if([element isKindOfClass:[VTDOMViewElement class]] && [(VTDOMViewElement *)element isViewLoaded]){
        [[(VTDOMViewElement *)element view] setElement:element];
    }
    [element setNeedDisplay];
}

-(void) refreshStatus{
    
    NSString * status = [self attributeValueForKey:@"status"];
    
    for(VTDOMElement * el in [self childs]){
        [self refreshStatusForElement:el forStatus:status];
    }
    
}

-(void) addElement:(VTDOMElement *)element{
    [super addElement:element];
    [self refreshStatusForElement:element forStatus:[self attributeValueForKey:@"status"]];
}

-(void) insertElement:(VTDOMElement *)element atIndex:(NSUInteger)index{
    [super insertElement:element atIndex:index];
    [self refreshStatusForElement:element forStatus:[self attributeValueForKey:@"status"]];
    
}

-(NSString *) status{
    return [self attributeValueForKey:@"status"];
}

-(void) setStatus:(NSString *)status{
    [self setAttributeValue:status forKey:@"status"];
}

@end
