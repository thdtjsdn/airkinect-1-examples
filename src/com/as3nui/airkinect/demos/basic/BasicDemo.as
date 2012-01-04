/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.demos.basic {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectCameraResolutions;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.DeviceStatusEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class BasicDemo extends BaseDemo {
		public static const KinectMaxDepthInFlash:uint = 200;

		private var _flags:uint;
		private var _currentSkeletons:Vector.<AIRKinectSkeleton>;

		private var _skeletonsSprite:Sprite;

		private var _rgbImage:Bitmap;
		private var _depthImage:Bitmap;

		public function BasicDemo() {
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
			if (_depthImage) _depthImage.x = stage.stageWidth - _depthImage.width;
		}

		private function initDemo():void {
			_demoName = "Basic Demo";
			// Possible Flags for Kinect
			//_flags = AIRKinect.NUI_INITIALIZE_FLAG_USES_SKELETON;
			//_flags = AIRKinect.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinect.NUI_INITIALIZE_FLAG_USES_COLOR;
			//_flags = AIRKinect.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinect.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX;
			//_flags = AIRKinect.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinect.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinect.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX;
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH;
			initKinect();
		}

		private function uninitDemo():void {
			if(_rgbImage){
				_rgbImage.bitmapData.dispose();
				if(this.contains(_rgbImage)) this.removeChild(_rgbImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);

			if(_depthImage){
				_depthImage.bitmapData.dispose();
				if(this.contains(_depthImage)) this.removeChild(_depthImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

			if (AIRKinect.skeletonEnabled) {
				if(this.contains(_skeletonsSprite)) this.removeChild(_skeletonsSprite);
			}

			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);


			AIRKinect.removeEventListener(DeviceStatusEvent.DISCONNECTED, onKinectDisconnected);
			AIRKinect.removeEventListener(DeviceStatusEvent.RECONNECTED, onKinectConnected);

			//Listeners
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}


		private function initKinect():void {
			if(!AIRKinect.initialize(_flags, AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480, AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240)){
			//if(!AIRKinect.initialize(_flags)){
				trace("Kinect Failed");
			}else{
				trace("Kinect Success");
				onKinectLoaded();
			}
		}

		private function onKinectLoaded():void {

			//RGB Camera Setup
			if (AIRKinect.rgbEnabled) {
				_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
				_rgbImage.scaleX = _rgbImage.scaleY = .5;
				this.addChild(_rgbImage);
				AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);
			}

			//Depth Camera Setup
			if (AIRKinect.depthEnabled) {
				_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
				this.addChild(_depthImage);
				AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);
			}

			//Skeleton Tracking Setup
			if (AIRKinect.skeletonEnabled) {
				_skeletonsSprite = new Sprite();
				this.addChild(_skeletonsSprite);
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
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
					if (AIRKinect.depthEnabled) _depthImage.bitmapData.dispose();
					if (AIRKinect.skeletonEnabled) while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
					AIRKinect.shutdown();
					break;
			}
		}

		//show RGB Image
		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}

		//Show Depth Image
		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthImage.bitmapData = e.frame;
		}

		//Store Skeleton
		private function onSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSkeletons = new <AIRKinectSkeleton>[];
			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;

			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeleton(j));
				}
			}
		}

		//Enterframe
		private function onEnterFrame(event:Event):void {
			drawSkeletons();
		}

		//Loop through all skeletons and all joints and draw them. Each joint will be a sprite
		private function drawSkeletons():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if (!AIRKinect.skeletonEnabled) return;

			var joint:AIRKinectSkeletonJoint;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, KinectMaxDepthInFlash);
			var jointSprite:Sprite;

			var color:uint;
			for each(var skeleton:AIRKinectSkeleton in _currentSkeletons) {
				for (var i:uint = 0; i < skeleton.numJoints; i++) {
					joint = skeleton.getJointScaled(i, scaler);

					jointSprite = new Sprite();
					color = (joint.z / (KinectMaxDepthInFlash * 4)) * 255 << 16 | (1 - (joint.z / (KinectMaxDepthInFlash * 4))) * 255 << 8 | 0;
					jointSprite.graphics.beginFill(color);
					jointSprite.graphics.drawCircle(0, 0, 15);
					jointSprite.x = joint.x;
					jointSprite.y = joint.y;
					jointSprite.z = joint.z;
					_skeletonsSprite.addChild(jointSprite);
				}
			}
		}
	}
}