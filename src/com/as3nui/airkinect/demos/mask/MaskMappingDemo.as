/**
 *
 * User: Wouter Verweirder
 * Date: 04/01/2012
 * Time: 10:29
 */
package com.as3nui.airkinect.demos.mask {
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class MaskMappingDemo extends BaseDemo {
		
		[Embed(source="/../assets/embeded/SantaHat.png")]
		private var SantaHat:Class;
		
		[Embed(source="/../assets/embeded/Sword.png")]
		private var Sword:Class;
		
		//Snowy Landscape Photo By http://www.flickr.com/photos/andiedg/
		[Embed(source="/../assets/embeded/SnowyLandscape.jpg")]
		private var SnowyLandscape:Class;
		
		private var _flags:uint;
		private var _playerMaskImage:Bitmap;
		private var _currentSkeletons:Vector.<AIRKinectSkeleton>;
		private var _skeletonsSprite:Sprite;
		
		private var _santaHat:Sprite;
		private var _sword:Sprite;
		private var _snowyLandscape:Bitmap;
		private var _photoField:TextField;
		
		public function MaskMappingDemo() {
			_demoName = "Mask Mapping Demo";
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
			
			_playerMaskImage.x = (stage.stageWidth - _playerMaskImage.width) * .5;
			_playerMaskImage.y = (stage.stageHeight - _playerMaskImage.height) * .5;
			
			_snowyLandscape.x = (stage.stageWidth - _snowyLandscape.width) * .5;
			_snowyLandscape.y = (stage.stageHeight -_snowyLandscape.height) * .5;
			
			_photoField.x = _snowyLandscape.x;
			_photoField.y = _snowyLandscape.y + _snowyLandscape.height + 10;
		}
		
		//----------------------------------
		// Demo
		//----------------------------------
		
		private function initDemo():void {
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX;
			initKinect();
		}
		
		private function uninitDemo():void {
			
			if(_photoField) {
				if(_photoField.parent)
				{
					_photoField.parent.removeChild(_photoField);
				}
				_photoField = null;
			}
			
			if (this.contains(_santaHat)) this.removeChild(_santaHat);
			if (this.contains(_sword)) this.removeChild(_sword);
			if(_skeletonsSprite) {
				while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
				if (this.contains(_skeletonsSprite)) this.removeChild(_skeletonsSprite);
			}
			
			if (_playerMaskImage) {
				_playerMaskImage.bitmapData.dispose();
				if (this.contains(_playerMaskImage)) this.removeChild(_playerMaskImage);
			}
			AIRKinect.removeEventListener(CameraFrameEvent.PLAYER_MASK, onPlayerMaskFrame);
			
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
				//Turn on the Player Mask Image
				AIRKinect.playerMaskEnabled = true;
				onKinectLoaded();
			}
		}
		
		private function onKinectLoaded():void {
			
			_snowyLandscape = new SnowyLandscape();
			addChild(_snowyLandscape);
			
			_photoField = new TextField();
			_photoField.autoSize = TextFieldAutoSize.LEFT;
			_photoField.textColor = 0x000000;
			_photoField.text = "Photo by http://www.flickr.com/photos/andiedg/ (creative commons)";
			addChild(_photoField);
			
			_playerMaskImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			_playerMaskImage.scaleX = _playerMaskImage.scaleY = 2;
			this.addChild(_playerMaskImage);
			AIRKinect.addEventListener(CameraFrameEvent.PLAYER_MASK, onPlayerMaskFrame);
			
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
			
			onStageResize(null);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}
		
		private function onPlayerMaskFrame(e:CameraFrameEvent):void {
			_playerMaskImage.bitmapData = e.frame;
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
					colorPoint.x += _playerMaskImage.x;
					colorPoint.y += _playerMaskImage.y;
					
					colorSprite = new Sprite();
					colorSprite.graphics.beginFill(0x00ff00);
					colorSprite.graphics.drawCircle(0, 0, 5);
					colorSprite.x = colorPoint.x;
					colorSprite.y = colorPoint.y;
					_skeletonsSprite.addChild(colorSprite);
				}
				
				var hatPoint:Point = skeleton.getJointInRGBSpace(AIRKinectSkeleton.HEAD);
				hatPoint.x += _playerMaskImage.x;
				hatPoint.y += _playerMaskImage.y;
				_santaHat.x = hatPoint.x;
				_santaHat.y = hatPoint.y;
				_santaHat.scaleX = _santaHat.scaleY = Math.abs(1 - ((skeleton.getJoint(AIRKinectSkeleton.HEAD).z) / 4));
				
				var swordPoint:Point = skeleton.getJointInRGBSpace(AIRKinectSkeleton.HAND_RIGHT);
				var elbowPoint:Point = skeleton.getJointInRGBSpace(AIRKinectSkeleton.ELBOW_RIGHT);
				var angle:Number = Math.atan2(swordPoint.y - elbowPoint.y, swordPoint.x - elbowPoint.x);
				_sword.rotation = angle * (180 / Math.PI);
				swordPoint.x += _playerMaskImage.x;
				swordPoint.y += _playerMaskImage.y;
				_sword.x = swordPoint.x;
				_sword.y = swordPoint.y;
				_sword.scaleX = _sword.scaleY = Math.abs(1 - ((skeleton.getJoint(AIRKinectSkeleton.HAND_RIGHT).z) / 4));
			}
		}
	}
}