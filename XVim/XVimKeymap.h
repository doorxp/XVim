//
//  XVimKeymap.h
//  XVim
//
//  Created by Tomas Lundell on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XVimKeyStroke;

@interface XVimKeymapContext : NSObject
- (void)clear;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *toString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *absorbedKeys;
@end

@interface XVimKeymap : NSObject
- (void)mapKeyStroke:(NSArray*)keyStrokes to:(NSArray*)targetKeyStrokes;

- (NSArray*)lookupKeyStrokeFromOptions:(NSArray*)options 
						   withPrimary:(XVimKeyStroke*)primaryKeyStroke
						   withContext:(XVimKeymapContext*)context;
@end
