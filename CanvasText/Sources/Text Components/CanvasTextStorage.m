//
//  CanvasTextStorage.m
//  CanvasText
//
//  Created by Sam Soffes on 6/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#import "CanvasTextStorage.h"

@interface CanvasTextStorage ()
@property (nonatomic) NSUInteger editCount;
@end

@implementation CanvasTextStorage

// MARK: - Properties

@synthesize editCount = _editCount;
@synthesize canvasDelegate = _canvasDelegate;

- (BOOL)isEditing {
	return self.editCount > 0;
}


// MARK: - NSTextStorage

- (void)beginEditing {
	[super beginEditing];
	self.editCount += 1;
}

- (void)endEditing {
	[super endEditing];
	self.editCount -= 1;
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
	// Local changes are delegated to the text controller
	[self.canvasDelegate canvasTextStorage:self willReplaceCharactersInRange:range withString:aString];
}


- (void)actuallyReplaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
	[super replaceCharactersInRange:range withString:aString];
}

@end
