//
//  XVimMarkMotionEvaluator.h
//  XVim
//
//  Created by Tomas Lundell on 21/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XVimMotionArgumentEvaluator.h"

typedef NS_ENUM(NSInteger, XVimMarkOperator) {
	MARKOPERATOR_MOVETO,
	MARKOPERATOR_MOVETOSTARTOFLINE
} ;

@interface XVimMarkMotionEvaluator : XVimMotionArgumentEvaluator

- (instancetype)initWithContext:(XVimEvaluatorContext*)context
			   parent:(XVimMotionEvaluator*)parent
		 markOperator:(XVimMarkOperator)markOperator;

+ (NSUInteger)markLocationForMark:(NSString*)mark inWindow:(XVimWindow*)window;

@end
