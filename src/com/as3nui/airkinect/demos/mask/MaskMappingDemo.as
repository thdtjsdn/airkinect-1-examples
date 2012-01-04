package com.as3nui.airkinect.demos.mask {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.DeviceStatusEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	public class MaskMappingDemo extends BaseDemo {

		private var _flags:uint;
		private var _rgbImage:Bitmap;
		private var _depthImage:Bitmap;
		private var _playerMaskImage:Bitmap;
		private var _currentSkeletons:Vector.<AIRKinectSkeleton>;
		private var _skeletonsSprite:Sprite;

		public function MaskMappingDemo() {
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
			if (_playerMaskImage) {
				_playerMaskImage.x = (stage.stageWidth - _playerMaskImage.width) * .5;
				_playerMaskImage.y = (stage.stageHeight - _playerMaskImage.height) * .5;
			}

			if (_depthImage) _depthImage.x = stage.stageWidth - _depthImage.width;
		}

		private function initDemo():void {
			_demoName = "Mask Demo";
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX;
			initKinect();
		}

		private function uninitDemo():void {
			if (_rgbImage) {
				_rgbImage.bitmapData.dispose();
				if (this.contains(_rgbImage)) this.removeChild(_rgbImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			AIRKinect.removeEventListener(CameraFrameEvent.PLAYER_MASK, onPlayerMask);

			AIRKinect.removeEventListener(DeviceStatusEvent.DISCONNECTED, onKinectDisconnected);
			AIRKinect.removeEventListener(DeviceStatusEvent.RECONNECTED, onKinectConnected);

			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			//Listeners
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			if(_skeletonsSprite) if(this.contains(_skeletonsSprite)) this.removeChild(_skeletonsSprite);
		}

		private function initKinect():void {
			if (!AIRKinect.initialize(_flags)) {
				trace("Kinect Failed");
			} else {
				//Turn on the Player Mask Image
				AIRKinect.playerMaskEnabled = true;
				trace("Kinect Success");
				onKinectLoaded();
			}
		}

		private function onKinectLoaded():void {
			//RGB Camera Setup
			if (AIRKinect.rgbEnabled) {
				_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
				_rgbImage.scaleX = _rgbImage.scaleY = .25;
				this.addChild(_rgbImage);
				AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);
			}

			//Depth Camera Setup
			if (AIRKinect.depthEnabled) {
				_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
				_depthImage.scaleX = _depthImage.scaleY = .5;
				this.addChild(_depthImage);
				AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

				//Player Mask Image
				_playerMaskImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
				_playerMaskImage.scaleX = _playerMaskImage.scaleY = 2;

				this.addChild(_playerMaskImage);
				AIRKinect.addEventListener(CameraFrameEvent.PLAYER_MASK, onPlayerMask);

				AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			}

			//Disconnect/Reconnect Listeners
			AIRKinect.removeEventListener(DeviceStatusEvent.RECONNECTED, onKinectConnected);
			AIRKinect.addEventListener(DeviceStatusEvent.DISCONNECTED, onKinectDisconnected);

			//Listeners
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			onStageResize(null);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);
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

		private function onSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSkeletons = new <AIRKinectSkeleton>[];
			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;

			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeleton(j));
				}
			}
		}

		private function onEnterFrame(event:Event):void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if (!AIRKinect.skeletonEnabled) return;

			var playerMaskPoint:Point;
			var playMaskSprite:Sprite;
			for each(var skeleton:AIRKinectSkeleton in _currentSkeletons) {
				for (var i:uint = 0; i < skeleton.numJoints; i++) {
					playerMaskPoint = skeleton.getJointInDepthSpace(i);
					playerMaskPoint.x = 320 - playerMaskPoint.x;
					playerMaskPoint.x *= _playerMaskImage.scaleX;
					playerMaskPoint.y *= _playerMaskImage.scaleY;

					playerMaskPoint.x += _playerMaskImage.x;
					playerMaskPoint.y += _playerMaskImage.y;

					playMaskSprite = new Sprite();
					playMaskSprite.graphics.beginFill(0x00ff00);
					playMaskSprite.graphics.drawCircle(0, 0, 5);
					playMaskSprite.x = playerMaskPoint.x;
					playMaskSprite.y = playerMaskPoint.y;
					_skeletonsSprite.addChild(playMaskSprite);
				}
			}
		}

		//show RGB Image
		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}

		//Show Player Mask Image
		private function onPlayerMask(e:CameraFrameEvent):void {
			_playerMaskImage.bitmapData = e.frame;
		}

		//Show Depth Image
		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthImage.bitmapData = e.frame;
		}
	}
}