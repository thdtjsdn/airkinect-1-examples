/**
 *
 * User: rgerbasi
 * Date: 12/16/11
 * Time: 1:46 PM
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