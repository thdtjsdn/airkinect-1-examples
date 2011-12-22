/**
 *
 * User: rgerbasi
 * Date: 12/19/11
 * Time: 4:32 PM
 */
package com.as3nui.airkinect.demos.composite {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	import uk.co.soulwire.gui.SimpleGUI;

	public class CompositeDemo extends BaseDemo {
		private var _depthImage:Bitmap;
		private var _rgbImage:Bitmap;
		private var _flags:uint;

		[Embed("/../assets/embeded/filters/DepthMatteFilter/bin/DepthMatteFilter.pbj", mimeType="application/octet-stream")]
		private var DepthMatteFilter:Class;
		private var _shader:Shader;
		private var _shaderJob:ShaderJob;
		private var _displayBitmap:Bitmap;
		private var _rgbBitmapData:BitmapData;
		private var _depthBitmapData:BitmapData;

		private var _gui:SimpleGUI;

		public var lightThreshold:Number;
		public var darkThreshold:Number;

		public function CompositeDemo() {
			_demoName = "Depth Extraction Demo";
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			lightThreshold = .7;
			darkThreshold = .3;
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

			initGUI();
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

		private function initGUI():void {
			_gui = new SimpleGUI(this, "Threshold Controls");
			_gui.addSlider("lightThreshold", 0, 1, {label:"Light Threshold"});
			_gui.addSlider("darkThreshold", 0, 1, {label:"Dark Threshold"});
			_gui.show();
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
			_displayBitmap = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
			_displayBitmap.scaleX = _displayBitmap.scaleY= .5;
			_displayBitmap.y += 100;
			this.addChild(_displayBitmap);

			_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
			_rgbImage.scaleX = -1;
			_rgbImage.x += 400 + _rgbImage.width;
			this.addChild(_rgbImage);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);

			_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			_depthImage.scaleX = _depthImage.scaleY = 2;
			_depthImage.x = 400;
			_depthImage.alpha = .75;
			this.addChild(_depthImage);
			AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

			_shader = new Shader(new DepthMatteFilter() as ByteArray);

			onStageResize(null);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbBitmapData = e.frame;
			_rgbImage.bitmapData = _rgbBitmapData
		}

		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthBitmapData = e.frame;
			_depthImage.bitmapData = _depthBitmapData;
		}

		private function onEnterFrame(event:Event):void {
			_shader.data.lightThreshold.value = [lightThreshold];
			_shader.data.darkThreshold.value = [darkThreshold];
			
			_shader.data.rgbSrc.input = _rgbBitmapData;
			_shader.data.depthSrc.input = _depthBitmapData;

			_shaderJob = new ShaderJob(_shader, _displayBitmap.bitmapData);
			_shaderJob.start();
		}
	}
}