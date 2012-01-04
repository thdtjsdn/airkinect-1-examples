/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.demos.mapping {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class SpaceMappingDemo extends BaseDemo {

		[Embed(source="/../assets/embeded/SantaHat.png")]
		private var SantaHat:Class;

		[Embed(source="/../assets/embeded/Sword.png")]
		private var Sword:Class;

		private var _flags:uint;
		private var _rgbImage:Bitmap;
		private var _currentSkeletons:Vector.<AIRKinectSkeleton>;
		private var _skeletonsSprite:Sprite;
		private var _depthImage:Bitmap;

		private var _santaHat:Sprite;
		private var _sword:Sprite;

		public function SpaceMappingDemo() {
			_demoName = "Space Mapping Demo";
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			initDemo();
			initSprites();

		}


		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			uninitSprites();
			uninitDemo();
		}

		override protected function onStageResize(event:Event):void {
			super.onStageResize(event);
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);

			_rgbImage.x = stage.stageWidth / 2 - _rgbImage.width / 2;
			_rgbImage.y = stage.stageHeight / 2 - _rgbImage.height / 2;
		}

		//----------------------------------
		// Sprites
		//----------------------------------
		private function initSprites():void {
			_santaHat = new Sprite();
			var innerHat:Bitmap = new SantaHat() as Bitmap;
			innerHat.scaleX = innerHat.scaleY = .70;
			innerHat.x -= innerHat.width / 2;
			innerHat.y -= innerHat.height * .95;
			_santaHat.addChild(innerHat);
			_santaHat.visible = false;
			this.addChild(_santaHat);

			_sword = new Sprite();
			var innerSword:Bitmap = new Sword() as Bitmap;
			innerSword.scaleX = innerSword.scaleY = 1.5;
			innerSword.x -= innerSword.width / 2;
			innerSword.y -= innerSword.height * .87;
			_sword.addChild(innerSword);
			_sword.visible = false;
			this.addChild(_sword);

			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);
		}

		private function uninitSprites():void {
			if (this.contains(_santaHat)) this.removeChild(_santaHat);
			if (this.contains(_sword)) this.removeChild(_sword);
			if(_skeletonsSprite) {
				while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
				if (this.contains(_skeletonsSprite)) this.removeChild(_skeletonsSprite);
			}
		}

		//----------------------------------
		// Demo
		//----------------------------------

		private function initDemo():void {
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR;
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

			if (AIRKinect.skeletonEnabled) {
				if (this.contains(_skeletonsSprite)) this.removeChild(_skeletonsSprite);
			}

			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
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
			this.addChild(_rgbImage);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);

			_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			this.addChild(_depthImage);
			AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

			onStageResize(null);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}

		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthImage.bitmapData = e.frame;
		}

		private function onSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSkeletons = new <AIRKinectSkeleton>[];
			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;

			_sword.visible = _santaHat.visible = skeletonFrame.numSkeletons > 0;
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeleton(j));
				}
			}
		}

		private function onEnterFrame(event:Event):void {
			drawSkeletons();
		}

		//Loop through all skeletons and all joints and draw them. Each joint will be a sprite
		private function drawSkeletons():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if (!AIRKinect.skeletonEnabled) return;

			var colorPoint:Point;
			var depthPoint:Point;
			var colorSprite:Sprite;
			var depthSprite:Sprite;
			for each(var skeleton:AIRKinectSkeleton in _currentSkeletons) {
				for (var i:uint = 0; i < skeleton.numJoints; i++) {
					colorPoint = skeleton.getJointInRGBSpace(i);
					colorPoint.x += _rgbImage.x;
					colorPoint.y += _rgbImage.y;

					colorSprite = new Sprite();
					colorSprite.graphics.beginFill(0x00ff00);
					colorSprite.graphics.drawCircle(0, 0, 5);
					colorSprite.x = colorPoint.x;
					colorSprite.y = colorPoint.y;
					_skeletonsSprite.addChild(colorSprite);

					depthPoint = skeleton.getJointInDepthSpace(i);
					depthPoint.x += _depthImage.x;
					depthPoint.y += _depthImage.y;

					depthSprite = new Sprite();
					depthSprite.graphics.beginFill(0xff0000);
					depthSprite.graphics.drawCircle(0, 0, 2);
					depthSprite.x = depthPoint.x;
					depthSprite.y = depthPoint.y;
					_skeletonsSprite.addChild(depthSprite);
				}

				var hatPoint:Point = skeleton.getJointInRGBSpace(AIRKinectSkeleton.HEAD);
				hatPoint.x += _rgbImage.x;
				hatPoint.y += _rgbImage.y;
				_santaHat.x = hatPoint.x;
				_santaHat.y = hatPoint.y;
				_santaHat.scaleX = _santaHat.scaleY = Math.abs(1 - ((skeleton.getJoint(AIRKinectSkeleton.HEAD).z) / 4));

				var swordPoint:Point = skeleton.getJointInRGBSpace(AIRKinectSkeleton.HAND_RIGHT);
				var elbowPoint:Point = skeleton.getJointInRGBSpace(AIRKinectSkeleton.ELBOW_RIGHT);
				var angle:Number = Math.atan2(swordPoint.y - elbowPoint.y, swordPoint.x - elbowPoint.x);
				_sword.rotation = angle * (180 / Math.PI);
				swordPoint.x += _rgbImage.x;
				swordPoint.y += _rgbImage.y;
				_sword.x = swordPoint.x;
				_sword.y = swordPoint.y;
				_sword.scaleX = _sword.scaleY = Math.abs(1 - ((skeleton.getJoint(AIRKinectSkeleton.HAND_RIGHT).z) / 4));
			}
		}
	}
}