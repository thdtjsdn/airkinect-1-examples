/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.demos {
	import away3d.containers.View3D;
	import away3d.extrusions.Elevation;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;

	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;

	public class AirKinectBumpMapDemo extends Sprite {

		private var _flags:uint;

		private var _rgbImage:Bitmap;
		private var _depthImage:Bitmap;

		private var _view:View3D;
		private var _elevation:Elevation;
		private var _light:PointLight;
		private var _material:ColorMaterial;
		private var _rotationSpeed:int = 1;

		public function AirKinectBumpMapDemo() {
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

			if (_depthImage) _depthImage.x = stage.stageWidth - _depthImage.width;
			if (_view) {
				_view.x = stage.stageWidth/2 - _view.width/2;
				_view.y = stage.stageHeight/2 - _view.height/2;
			}
		}

		private function initDemo():void {
			_flags = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH;
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
			_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
			_rgbImage.scaleX = _rgbImage.scaleY = .5;
			this.addChild(_rgbImage);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);

			_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			this.addChild(_depthImage);
			AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

			//Listeners
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			onStageResize(null);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			init3D();
		}
		private function onExiting(event:Event):void {
			AIRKinect.shutdown();
		}

		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}

		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthImage.bitmapData = e.frame;
			updateElevation();
		}
		
		private function init3D():void {
			_view = new View3D();
			_view.backgroundColor = 0xffffff;
			this.addChild(_view);
			_material  = new ColorMaterial(0xff0000);
			_material.bothSides = true;
			_light = new PointLight();
			_light.x = 1000;
			_light.y = 1000;
			_light.z = -1000;
			_light.color = 0xffeeaa;

			_material.lights = [_light];
			_view.scene.addChild(_light);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function updateElevation():void {
			if(_view.scene.contains(_elevation)) {
				_elevation.heightMap = _depthImage.bitmapData;
				_elevation.updateGeometry();
			}else{
				_elevation = new Elevation(_material, _depthImage.bitmapData,320,25,240, 50);
				_elevation.rotationX = -90;
				_view.scene.addChild(_elevation);
			}
		}

		private function onEnterFrame(event:Event):void {
			_view.render();
			if(_elevation) {
				_elevation.rotationY+=_rotationSpeed;
				if(_elevation.rotationY > 60) {
					_elevation.rotationY = 60;
					_rotationSpeed *= -1;
				}else if(_elevation.rotationY < 0){
					_elevation.rotationY = 0;
					_rotationSpeed *= -1;
				}
			}


		}
	}
}