/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.demos {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.geom.Point;
	import flash.media.Sound;

	public class AirKinectThereminDemo extends Sprite {

		private var _octave:Number    	= 4;
		private var _amp:Number    		= 0;
		private var _phase:Number    	= 0;
		private var _dphase:Number   	= 1 / 44100 * Math.PI * 2;

		private var _flags:uint;
		
		public function AirKinectThereminDemo() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			initDemo();

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
		}

		private function initDemo():void {
			graphics.lineStyle(1);
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON;
			initKinect();
		}

		private function initKinect():void {
			if(!AIRKinect.initialize(_flags)){
				trace("Kinect Failed");
			}else{
				trace("Kinect Success");
				onKinectLoaded();
			}
		}

		private function onKinectLoaded():void {
			//Hand Control
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			//Mouse Control
			//this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			//Listeners
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			onStageResize(null);

			var sound:Sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.play();
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if(event.skeletonFrame.numSkeletons >0) processHands(event.skeletonFrame.getSkeletonPosition(0))
		}

		private function processHands(skeletonPosition:SkeletonPosition):void {
			var leftHeight:Number = skeletonPosition.getElement(SkeletonPosition.HAND_LEFT).y;
			var rightHeight:Number = skeletonPosition.getElement(SkeletonPosition.HAND_RIGHT).y;

			_octave = leftHeight * 25;
			_amp = rightHeight;

			//trace(skeletonPosition.getElement(SkeletonPosition.HAND_LEFT));
			//trace(skeletonPosition.getElement(SkeletonPosition.HAND_RIGHT));
		}

		private function onSampleData(event:SampleDataEvent):void {
			 graphics.clear();
    		graphics.lineStyle(0, 0x999999);
    		graphics.moveTo(0, stage.stageHeight / 2);
			
			var frec:Number    = 220 * Math.pow(2, _octave / 12);
			for(var i:int = 0; i < 2048; i++) {
				var sample:Number = 0.5*Math.sin(_phase * frec) * _amp;
				_phase += _dphase;
				event.data.writeFloat(sample); // left
				event.data.writeFloat(sample); // right

				graphics.lineTo(i / 2048 * stage.stageWidth, stage.stageHeight / 2 - sample * stage.stageHeight / 8);
			}
		}

		private function onExiting(event:Event):void {
			AIRKinect.shutdown();
		}
		
		private function onEnterFrame(event:Event):void {
			_octave = (stage.mouseY / stage.stageHeight) * 25;
			_amp = stage.mouseX / stage.stage.stageWidth;
		}

	}
}