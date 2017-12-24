//
//  BaseTextStorage.m
//  CanvasText
//
//  Created by Sam Soffes on 6/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#import "BaseTextStorage.h"

@interface BaseTextStorage ()
@property (nonatomic) NSMutableAttributedString *storage;
@end

@implementation BaseTextStorage

@synthesize storage = _storage;

// MARK: - Initializers

- (instancetype)init {
	if (self = [super init]) {
		self.storage = [[NSMutableAttributedString alloc] init];
	}
	return self;
}


// MARK: - NSTextStorage

- (NSString *)string {
	return self.storage.string;
}

- (NSDictionary<NSString *,id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)effectiveRange {
	return [self.storage attributesAtIndex:location effectiveRange:effectiveRange];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
	[self.storage replaceCharactersInRange:range withString:aString];
	
	NSInteger change = aString.length - range.length;
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:change];
}

- (void)setAttributes:(NSDictionary<NSString *,id> *)attributes range:(NSRange)range {
	if (NSMaxRange(range) > self.length) {
		NSLog(@"WARNING: Tried to set attributes at out of bounds range %@. Length: %lu", NSStringFromRange(range), (unsigned long)self.length);
		return;
	}
	
	[self beginEditing];
	[self.storage setAttributes:attributes range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
	[self endEditing];
}

@end
