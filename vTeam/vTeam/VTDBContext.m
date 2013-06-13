//
//  VTDBContext.m
//  vTeam
//
//  Created by zhang hailong on 13-6-4.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "VTDBContext.h"

#include <sqlite3.h>
#include <objc/runtime.h>


@interface VTDBContext(){
  
}

@end

@implementation VTDBContext

@synthesize db = _db;

-(void) dealloc{
    [_db release];
    [super dealloc];
}

static NSString * VTDBContextPropertyDBType(objc_property_t prop){
    
    
    NSString * type = [NSString stringWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
    
    if( [type hasPrefix:@"Ti"] || [type hasPrefix:@"Tl"] || [type hasPrefix:@"Tb"]){
        return @"INT";
    }
    
    if( [type hasPrefix:@"Tq"]  ){
        return @"BIGINT";
    }
    
    if( [type hasPrefix:@"Tf"] || [type hasPrefix:@"Td"]   ){
        return @"DOUBLE";
    }
    
    if( [type hasPrefix:@"T@\"NSString\""] ){
        return @"TEXT";
    }
    
    if( [type hasPrefix:@"T@\"NSData\""] ){
        return @"BLOB";
    }
    
    if( [type hasPrefix:@"T@"] ){
        return @"BLOB";
    }
    
    return @"VARCHAR(45)";
}

-(void) regDBObjectClass:(Class) dbObjectClass{
    
    unsigned int propCount = 0;
    objc_property_t * prop =  class_copyPropertyList(dbObjectClass, &propCount);
    NSString * name = NSStringFromClass(dbObjectClass) ;
    
    BOOL isExists = NO;
   
    id<IVTSqliteCursor> cursor = [_db query:@"SELECT [sql] FROM [sqlite_master] WHERE [type]='table' AND [name]=:name" withData:[NSDictionary dictionaryWithObject:name forKey:@"name"]];
    
    if([cursor next]){
        
        NSString * sql = [cursor stringValueAtIndex:0];
        
        for(int i=0;i<propCount;i++){
            NSString * n = [NSString stringWithFormat:@"[%s]",property_getName(prop[i])];
            
            if([sql rangeOfString:n].location == NSNotFound){
                [_db execture:[NSString stringWithFormat:@"ALTER TABLE [%@] ADD COLUMN %@ %@;",name,n,VTDBContextPropertyDBType(prop[i])] withData:nil];
            }

        }
        
        isExists = YES;
        
    }
    [cursor close];
    
    if(!isExists){
        
        NSMutableString * mb = [NSMutableString stringWithCapacity:1024];
        
        [mb appendFormat:@"CREATE TABLE IF NOT EXISTS [%@] ( [rowid] INTEGER PRIMARY KEY AUTOINCREMENT ",name];

        for(int i=0;i<propCount;i++){
            
            const char * n = property_getName(prop[i]);
            
            [mb appendFormat:@",[%s] %@",n,VTDBContextPropertyDBType(prop[i])];
        }
        
        [mb appendString:@")"];
        
        if(![_db execture:mb withData:nil]){
            NSLog(@"%@",[_db errmsg]);
        }
        
    }
}

-(BOOL) insertObject:(VTDBObject *) dbObject{
    
    Class dbObjectClass = [dbObject class];
    unsigned int propCount = 0;
    objc_property_t * prop =  class_copyPropertyList(dbObjectClass, &propCount);
    objc_property_t rowid = class_getProperty(dbObjectClass, "rowid");
    NSString * name = NSStringFromClass(dbObjectClass) ;
    
    NSMutableString * mb = [NSMutableString stringWithCapacity:1024];
    NSMutableString * values = [NSMutableString stringWithCapacity:1024];
    
    [mb appendFormat:@"INSERT INTO [%@] ( ",name];
    [values appendString:@" VALUES("];
    
    BOOL isFirst = YES;
    
    for(int i=0;i<propCount;i++){
        
        if(rowid == prop[i]){
            continue;
        }
        
        const char * n = property_getName(prop[i]);
    
        if(isFirst){
            isFirst = NO;
        }
        else {
            [mb appendString:@","];
            [values appendString:@","];
        }
        
        [mb appendFormat:@"[%s]",n];
        [values appendFormat:@":%s",n];
    }
    
    [values appendString:@")"];
    
    [mb appendString:@")"];
    
    [mb appendString:values];
    
    if([_db execture:mb withData:dbObject]){
        [dbObject setRowid:[_db lastInsertRowid]];
        return YES;
    }
    
    return NO;
}

-(BOOL) deleteObject:(VTDBObject *) dbObject{
    Class dbObjectClass = [dbObject class];
    NSString * name = NSStringFromClass(dbObjectClass) ;
    return [_db execture:[NSString stringWithFormat:@"DELETE FROM [%@] WHERE [rowid]=:rowid",name] withData:dbObject];
}

-(BOOL) updateObject:(VTDBObject *) dbObject{
    
    Class dbObjectClass = [dbObject class];
    unsigned int propCount = 0;
    objc_property_t * prop =  class_copyPropertyList(dbObjectClass, &propCount);
    objc_property_t rowid = class_getProperty(dbObjectClass, "rowid");
    
    NSString * name = NSStringFromClass(dbObjectClass) ;
    
    NSMutableString * mb = [NSMutableString stringWithCapacity:1024];

    [mb appendFormat:@"UPDATE [%@] SET ",name];
    
    BOOL isFirst = YES;
    
    for(int i=0;i<propCount;i++){
        
        if(rowid == prop[i]){
            continue;
        }
        
        const char * n = property_getName(prop[i]);
  
        if(isFirst){
            isFirst = NO;
        }
        else{
            [mb appendString:@","];
        }
        
        [mb appendFormat:@"[%s]=:%s",n,n];
    }
    
    [mb appendString:@" WHERE [rowid]=:rowid"];
    
    return [_db execture:mb withData:dbObject];
}

-(id<IVTSqliteCursor>) query:(Class) dbObjectClass sql:(NSString *) sql data:(id) data{
    NSString * name = NSStringFromClass(dbObjectClass) ;
    return [_db query:[NSString stringWithFormat:@"SELECT * FROM [%@] %@",name,sql ? sql : @""] withData:data];
}

@end
