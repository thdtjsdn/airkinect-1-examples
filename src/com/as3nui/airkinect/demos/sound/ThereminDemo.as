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

package com.as3nui.airkinect.demos.sound {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.geom.Point;
	import flash.media.Sound;

	public class ThereminDemo extends BaseDemo {

		private var _octave:Number = 4;
		private var _amp:Number = 0;
		private var _phase:Number = 0;
		private var _dphase:Number = 1 / 44100 * Math.PI * 2;

		private var _flags:uint;
		private var _sound:Sound;

		public function ThereminDemo() {
			_demoName = "Bad Theremin Demo";
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			uninitDemo();
		}

		override protected function onStageResize(event:Event):void {
			super.onStageResize(event);
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
		}

		private function initDemo():void {
			graphics.lineStyle(1);
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON;
			initKinect();
		}

		private function uninitDemo():void {

			graphics.clear();

			if (_sound) {
				_sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				try{
					_sound.close();
				}catch(err:Error){}
				_sound = null;
			}

			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}


		private function initKinect():void {
			if (!AIRKinect.initialize(_flags)) {
				trace("Kinect Failed");
			} else {
				trace("Kinect Success");
				onKinectLoaded();
			}
		}

		private function onKinectLoaded():void {
			//Hand Control
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			//Mouse Control
			//this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			onStageResize(null);

			_sound = new Sound();
			_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			_sound.play();
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if (event.skeletonFrame.numSkeletons > 0) processHands(event.skeletonFrame.getSkeleton(0))
		}

		private function processHands(skeleton:AIRKinectSkeleton):void {
			var leftHeight:Number = skeleton.getJoint(AIRKinectSkeleton.HAND_LEFT).y;
			var rightHeight:Number = skeleton.getJoint(AIRKinectSkeleton.HAND_RIGHT).y;
			_octave = leftHeight * 25;
			_amp = rightHeight;
		}

		private function onSampleData(event:SampleDataEvent):void {
			graphics.clear();
			graphics.lineStyle(0, 0x999999);
			graphics.moveTo(0, stage.stageHeight / 2);

			var frec:Number = 220 * Math.pow(2, _octave / 12);
			for (var i:int = 0; i < 2048; i++) {
				var sample:Number = 0.5 * Math.sin(_phase * frec) * _amp;
				_phase += _dphase;
				event.data.writeFloat(sample); // left
				event.data.writeFloat(sample); // right

				graphics.lineTo(i / 2048 * stage.stageWidth, stage.stageHeight / 2 - sample * stage.stageHeight / 8);
			}
		}

		private function onEnterFrame(event:Event):void {
			_octave = (stage.mouseY / stage.stageHeight) * 25;
			_amp = stage.mouseX / stage.stage.stageWidth;
		}

	}
}