package com.as3nui.airkinect.demos.mask
{
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.DeviceStatusEvent;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectCameraResolutions;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class MaskDemo extends BaseDemo
	{
		
		private var _flags:uint;
		private var _rgbImage:Bitmap;
		private var _playerMaskImage:Bitmap;
		
		public function MaskDemo()
		{
			super();
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
			if(_rgbImage) {
				_rgbImage.x = (stage.stageWidth - _rgbImage.width) * .5;
				_rgbImage.y = (stage.stageHeight - _rgbImage.height) * .5;
			}
			if(_playerMaskImage) {
				_playerMaskImage.scaleX = -1;
				_playerMaskImage.x = (stage.stageWidth + _playerMaskImage.width) * .5;
				_playerMaskImage.y = (stage.stageHeight - _playerMaskImage.height) * .5;
			}
		}
		
		private function initDemo():void {
			_demoName = "Mask Demo";
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH;
			initKinect();
		}
		
		private function uninitDemo():void {
			if(_rgbImage){
				_rgbImage.bitmapData.dispose();
				if(this.contains(_rgbImage)) this.removeChild(_rgbImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			AIRKinect.removeEventListener(CameraFrameEvent.PLAYER_MASK, onPlayerMask);
			
			AIRKinect.removeEventListener(DeviceStatusEvent.DISCONNECTED, onKinectDisconnected);
			AIRKinect.removeEventListener(DeviceStatusEvent.RECONNECTED, onKinectConnected);
			
			//Listeners
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function initKinect():void {
			if(!AIRKinect.initialize(_flags, AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480, AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480)){
				trace("Kinect Failed");
			}else{
				trace("Kinect Success");
				onKinectLoaded();
			}
		}
		
		private function onKinectLoaded():void {
			
			AIRKinect.playerMaskEnabled = true;
			
			//RGB Camera Setup
			if (AIRKinect.rgbEnabled) {
				_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
				this.addChild(_rgbImage);
				AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);
			}
			
			//Depth Camera Setup
			if (AIRKinect.depthEnabled) {
				_playerMaskImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
				//add some blur to the mask for better results
				_playerMaskImage.filters = [new BlurFilter(5, 5)];
				this.addChild(_playerMaskImage);
				AIRKinect.addEventListener(CameraFrameEvent.PLAYER_MASK, onPlayerMask);
				
				if(_rgbImage)
				{
					_rgbImage.cacheAsBitmap = _playerMaskImage.cacheAsBitmap = true;
					_rgbImage.mask = _playerMaskImage;
				}
			}
			
			//Disconnect/Reconnect Listeners
			AIRKinect.removeEventListener(DeviceStatusEvent.RECONNECTED, onKinectConnected);
			AIRKinect.addEventListener(DeviceStatusEvent.DISCONNECTED, onKinectDisconnected);
			
			//Listeners
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			onStageResize(null);
		}
		
		//----------------------------------
		// Disconnection/Reconnection
		//----------------------------------
		private function onKinectConnected(e:DeviceStatusEvent):void {
			initKinect();
		}
		
		private function onKinectDisconnected(event:DeviceStatusEvent):void {
			uninitDemo();
			AIRKinect.addEventListener(DeviceStatusEvent.RECONNECTED, onKinectConnected);
		}
		
		//----------------------------------
		// Keyboard Debugging
		//----------------------------------
		private function onKeyUp(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.S:
					if (!AIRKinect.KINECT_RUNNING) AIRKinect.initialize(_flags);
					break;
				case Keyboard.X:
					if (AIRKinect.rgbEnabled) _rgbImage.bitmapData.dispose();
					if (AIRKinect.depthEnabled) _playerMaskImage.bitmapData.dispose();
					AIRKinect.shutdown();
					break;
				case Keyboard.M:
				case 186://doesn't match?
					AIRKinect.playerMaskEnabled = !AIRKinect.playerMaskEnabled;
					break;
			}
		}
		
		//show RGB Image
		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}
		
		//Show Depth Image
		private function onPlayerMask(e:CameraFrameEvent):void {
			_playerMaskImage.bitmapData = e.frame;
		}
		
	}
}