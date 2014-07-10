//
//  XVimChildEvaluator.h
//  XVim
//
//  Created by Tomas Lundell on 21/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XVimEvaluator.h"

// Helper class
// Funnels certain evaluator calls to the parent
@interface XVimArgumentEvaluator : XVimEvaluator {
@protected
    XVimEvaluator* _parent;
}

- (instancetype)initWithContext:(XVimEvaluatorContext*)context
			   parent:(XVimEvaluator*)parent NS_DESIGNATED_INITIALIZER;
@end
