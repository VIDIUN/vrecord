package {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class VRecordContainerFlash extends Sprite
	{
		private var _vRecorderLoader:Loader = new Loader();

		private var button:Sprite = new Sprite();

		public function VRecordContainerFlash()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			addEventListener(Event.ADDED_TO_STAGE, startApplication);
		}

		private function startApplication (event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, startApplication);
			button.graphics.beginFill(0xff, 1);
			button.graphics.drawCircle(0, 0, 50);
			button.graphics.endFill();
			button.buttonMode = true;
			button.useHandCursor = true;
			button.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			addChild(button);

			_vRecorderLoader.x = 100;
			_vRecorderLoader.y = 100;
			_vRecorderLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, finishedLoading);
			_vRecorderLoader.load(new URLRequest("VRecord.swf"), new LoaderContext(true, ApplicationDomain.currentDomain));
		}

		private function finishedLoading(event:Event):void
		{
			//wait for the vrecord view to load -
			_vRecorderLoader.addEventListener("viewReady", vrecordReady);
			//when loading inside another flash application, to pass initialization parameters to the vrecord application, use the parameters object
			//if loaded through HTML directly, the initialization will be directed through the embed object flashVars.
			_vRecorderLoader.content['parameters'] = {themeUrl:"skin.swf",
														localeUrl:"locale.xml",
														autoPreview:"1",
														pid:"1",
														subpid:"100",
														vs:"some generated vs here..." };
			//_vRecorderLoader.content['parameters'] = root.loaderInfo.parameters;
			addChild(_vRecorderLoader);
		}

		private function vrecordReady (event:Event):void
		{
			//when vrecord view is ready, it can be resized
			_vRecorderLoader.width = 100 + Math.random() * 200;
			_vRecorderLoader.height = _vRecorderLoader.width * 0.75;

			//when vrecord application is ready, it can be accessed for APIs
			//to access vrecord application, use the application property:
			trace("Available microphones: " + _vRecorderLoader.content["application"].getMicrophones());
			(_vRecorderLoader.content["application"] as EventDispatcher).addEventListener("addEntryFault", addEntryFaultHandler);
		}

		private function addEntryFaultHandler (event:Event):void {
			trace ("can't save without VS...");
		}

		private function buttonClickHandler (event:MouseEvent):void
		{
			_vRecorderLoader.width = 100 + Math.random() * 600;
			_vRecorderLoader.height = _vRecorderLoader.width * 0.75;
		}
	}
}
