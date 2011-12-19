/**
 *
 * User: rgerbasi
 * Date: 12/19/11
 * Time: 4:32 PM
 */
package com.as3nui.airkinect.demos.composite {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;

	import flash.events.Event;
	import flash.filters.ShaderFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;

	public class ThresholdDemo extends BaseDemo {
		private var _depthImage:Bitmap;
		private var _rgbImage:Bitmap;
		private var _flags:uint;

		[Embed("/../assets/embeded/filters/ThresholdClampFilter/bin/ThresholdClamp.pbj", mimeType="application/octet-stream")]
		private var ThresholdClampFilter:Class;

		public function ThresholdDemo() {
			_demoName = "Depth Extraction Demo";
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

//			if (_depthImage) _depthImage.x = stage.stageWidth - _depthImage.width;
		}

		private function initDemo():void {
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH;
			initKinect();
		}

		private function uninitDemo():void {
			if (_rgbImage) {
				_rgbImage.bitmapData.dispose();
				if (this.contains(_rgbImage)) this.removeChild(_rgbImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);

			if (_depthImage) {
				_depthImage.bitmapData.dispose();
				if (this.contains(_depthImage)) this.removeChild(_depthImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.DEPTH, onDepthFrame);


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
			_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
			_rgbImage.scaleX = _rgbImage.scaleY = .5;
			this.addChild(_rgbImage);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);

			_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			_depthImage.scaleX = -1;
			_depthImage.x = _depthImage.width;
			this.addChild(_depthImage);
			AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

			var shader:Shader = new Shader(new ThresholdClampFilter() as ByteArray);
			var filter:ShaderFilter = new ShaderFilter(shader);
			_depthImage.filters = [filter];

			onStageResize(null);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}

		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthImage.bitmapData = e.frame;
		}

		private function onEnterFrame(event:Event):void {
		}
	}
}