/*
 * Copyright (c) 2012 AS3NUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.as3nui.airkinect.demos.core {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;

	public class BaseDemo extends Sprite {
		protected var _demoName:String = "Base Demo";
		
		public function BaseDemo() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}

		protected function onAddedToStage(event:Event):void {
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		protected function onRemovedFromStage(event:Event):void {
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExiting);
			stage.removeEventListener(Event.RESIZE, onStageResize);
			AIRKinect.shutdown();
		}

		protected function onStageResize(event:Event):void {

		}

		protected function onExiting(event:Event):void {

		}

		public function get demoName():String {
			return _demoName;
		}
	}
}