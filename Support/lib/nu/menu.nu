; Simple menu popup at the carets location in the current text view.
; Input is a JSON-encoded menu structure in the 'menuList' variable.
;
; Copyright (c) 2011 Martin Hedenfalk <martin@bzero.se>
;
; Permission to use, copy, modify, and distribute this software for any
; purpose with or without fee is hereby granted, provided that the above
; copyright notice and this permission notice appear in all copies.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

(class ShellMenuDelegate is NSObject
	(unless $ShellMenuDelegateLoaded
		(set $ShellMenuDelegateLoaded YES)
		(ivar (id)shellCommand (id)itemSelected))

	(imethod (id) itemSelected is @itemSelected)

	(imethod (id) initWithShell:(id) shell is
		(super init)
		(set @itemSelected NO)
		(set @shellCommand shell)
		(@shellCommand log:"returning #{self}")
		self)

	(imethod (void) selectMenuItem:(id) sender is
		(@shellCommand log:"selected item #{(sender description)}")
		(set @itemSelected YES)
		(set ret (NSMutableDictionary dictionary))
		(ret setObject:(sender representedObject) forKey:"selectedTitle")
		(ret setObject:(- (sender tag) 1) forKey:"selectedIndex")
		(@shellCommand exitWithObject:ret)
		(set @shellCommand nil)))

(set NSRightMouseDown 3)

; FIXME: why doesn't this work directly? need to run the runloop once?
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)
;((NSRunLoop mainRunLoop) runMode:NSDefaultRunLoopMode beforeDate:(NSDate distantFuture))

(set target ((ShellMenuDelegate alloc) initWithShell:shellCommand))

(set menu ((NSMenu alloc) initWithTitle:"a menu"))
(menu setAllowsContextMenuPlugIns:NO)
(set tag 1)
('("one" "two" "three") each: (do (title)
	(set key "")
	(if (<= tag 10)
		(set key "#{(% tag 10)}"))
	(set tag (+ tag 1))
	(set item (menu addItemWithTitle:title action:"selectMenuItem:" keyEquivalent:key))
	(item setKeyEquivalentModifierMask:0)
	(item setTarget:target)
	(item setTag:tag)
	(item setRepresentedObject:title)))

(set range `(,(text caret) 0))
(set rect ((text layoutManager) boundingRectForGlyphRange:range inTextContainer:(text textContainer)))
(set point (cons (first rect) (list (second rect))))
(set ev (NSEvent mouseEventWithType:NSRightMouseDown
			   location:(text convertPoint:point toView:nil)
		      modifierFlags:0
			  timestamp:((NSDate date) timeIntervalSinceNow)
		       windowNumber:((text window) windowNumber)
			    context:(NSGraphicsContext currentContext)
		        eventNumber:0
			 clickCount:1
			   pressure:1.0))
(NSMenu popUpContextMenu:menu withEvent:ev forView:text)
(unless (target itemSelected)
	(shellCommand exitWithError:1))
	