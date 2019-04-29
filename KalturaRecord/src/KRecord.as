/*
   // ===================================================================================================
   //                           _  __     _ _
   //                          | |/ /__ _| | |_ _  _ _ _ __ _
   //                          | ' </ _` | |  _| || | '_/ _` |
   //                          |_|\_\__,_|_|\__|\_,_|_| \__,_|
   //
   // This file is part of the Vidiun Collaborative Media Suite which allows users
   // to do with audio, video, and animation what Wiki platfroms allow them to do with
   // text.
   //
   // Copyright (C) 2006-2008  Vidiun Inc.
   //
   // This program is free software: you can redistribute it and/or modify
   // it under the terms of the GNU Affero General Public License as
   // published by the Free Software Foundation, either version 3 of the
   // License, or (at your option) any later version.
   //
   // This program is distributed in the hope that it will be useful,
   // but WITHOUT ANY WARRANTY; without even the implied warranty of
   // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   // GNU Affero General Public License for more details.
   //
   // You should have received a copy of the GNU Affero General Public License
   // along with this program.  If not, see <http://www.gnu.org/licenses/>.
   //
   // @ignore
   // ===================================================================================================
 */
package {
	import com.vidiun.VidiunClient;
	import com.vidiun.config.VidiunConfig;
	import com.vidiun.devicedetection.DeviceDetectionEvent;
	import com.vidiun.net.streaming.events.ExNetConnectionEvent;
	import com.vidiun.net.streaming.events.FlushStreamEvent;
	import com.vidiun.net.streaming.events.RecordNetStreamEvent;
	import com.vidiun.recording.business.BaseRecorderParams;
	import com.vidiun.recording.controller.VRecordControl;
	import com.vidiun.recording.controller.events.AddEntryEvent;
	import com.vidiun.recording.controller.events.PreviewEvent;
	import com.vidiun.recording.controller.events.RecorderEvent;
	import com.vidiun.recording.view.VRecordViewParams;
	import com.vidiun.recording.view.UIComponent;
	import com.vidiun.recording.view.View;
	import com.vidiun.recording.view.ViewEvent;
	import com.vidiun.recording.view.ViewState;
	import com.vidiun.recording.view.ViewStatePreview;
	import com.vidiun.utils.VConfigUtil;
	import com.vidiun.utils.VUtils;
	import com.vidiun.utils.ObjectHelpers;
	import com.vidiun.vo.VidiunMediaEntry;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	
	import mx.utils.ObjectUtil;

	[SWF(width = '320', height = '240', frameRate = '30', backgroundColor = '#000000')]
	[Frame(factoryClass = "ApplicationLoader")]

	public class VRecord extends Sprite {
		
		/**
		 * parameters passed from a wrapper application, fixed to lower-no-underscore.
		 */
		public var pushParameters:Object;

		/**
		 * the id of the last entry saved 
		 */
		private var _mostRecentEntryId:String;

		private var _recordControl:VRecordControl = new VRecordControl();

		private var _message:TextField;

		private var _showErrorMessage:Boolean;

		private var _messageX:Number = 0;
		private var _messageY:Number = 0;

		private var _view:View = new View();
		
		private var _newViewState:String;
		
		/**
		 * limit in seconds to recording time. 0 means no limit
		 */
		private var _limitRecord:Number = 0;
		
		/**
		 * The timer for the recording limitation
		 */
		private var _limitRecordTimer:Timer;

		

		public static const VERSION:String = "v1.7.1";


		/**
		 * Constructor.
		 * @param init		if true will automatically call startApplication and initialize application.
		 *
		 */
		public function VRecord(init:Boolean = true):void {
			Global.RECORD_CONTROL = _recordControl;
			addEventListener(Event.ADDED_TO_STAGE, build);
		}


		private function build(evt:Event = null):void {
			Security.allowDomain("*");

			var customContextMenu:ContextMenu = new ContextMenu();
			customContextMenu.hideBuiltInItems();
			var menuItem:ContextMenuItem = new ContextMenuItem("Vrecord " + VERSION, true);
			customContextMenu.customItems.push(menuItem);
			this.contextMenu = customContextMenu;

			stageResize(null);
			// store flashvars
			var paramObj:Object = !pushParameters ? root.loaderInfo.parameters : pushParameters;
			pushParameters = ObjectHelpers.lowerNoUnderscore(paramObj);
			
			// read flashVars
			if (pushParameters.showui == "false") {
				UIComponent.visibleSkin = false
			}
			if (pushParameters.showerrormessage == "true" || pushParameters.showerrormessage == "1") {
				_showErrorMessage = true
			}
			// view params:
			var themeUrl:String = VConfigUtil.getDefaultValue(pushParameters.themeurl, "skin.swf");
			var localeUrl:String = VConfigUtil.getDefaultValue(pushParameters.localeurl, "locale.xml");
			var autoPreview:String = VConfigUtil.getDefaultValue(pushParameters.autopreview, "1");
			if (pushParameters.showpreviewtimer == "true" || pushParameters.showpreviewtimer == "1")
				Global.SHOW_PREVIEW_TIMER = true;
			
			Global.REMOVE_PLAYER = (pushParameters.removeplayer == "1" || pushParameters.removeplayer == "true");
			Global.VIEW_PARAMS = new VRecordViewParams(themeUrl, localeUrl, autoPreview);
			Global.DETECTION_DELAY = pushParameters.hasOwnProperty("detectiondelay") ? uint(pushParameters.detectiondelay) : 0;
			Global.DISABLE_GLOBAL_CLICK = (pushParameters.disableglobalclick == "1" || pushParameters.disableglobalclick == "true");
			
			Global.DEBUG_MODE = pushParameters.hasOwnProperty("debugmode") ? true : false;

			// create Vidiun client 
			var configuration:VidiunConfig = new VidiunConfig();
			configuration.partnerId = pushParameters.pid;
			configuration.ignoreNull = 1;
			configuration.domain = VUtils.hostFromCode(pushParameters.host);
			configuration.srvUrl = "api_v3/index.php"
			configuration.vs = pushParameters.vs;

			if (!pushParameters.httpprotocol) {
				var url:String = root.loaderInfo.url;
				configuration.protocol = isHttpURL(url) ? getProtocol(url) : "http";
			}
			else {
				configuration.protocol = pushParameters.httpprotocol;
			}
			configuration.protocol += "://";

			Global.VIDIUN_CLIENT = new VidiunClient(configuration);

			
			_view.addEventListener(ViewEvent.VIEW_READY, startApplication);
			addChild(_view);
		}

		
		/**
		 * initializes the application.
		 */
		public function startApplication(event:Event = null):void {
			if (Global.PRELOADER && Global.PRELOADER.parent) {
				Global.PRELOADER.parent.removeChild(Global.PRELOADER);
				Global.PRELOADER = null;
			}
			
			_view.showPopupMessage(Global.LOCALE.getString("Dialog.Connecting"));
			_view.addEventListener(ViewEvent.RECORD_START, onStartRecord);
			_view.addEventListener(ViewEvent.RECORD_STOP, onStopRecord);
			_view.addEventListener(ViewEvent.PREVIEW_SAVE, onSave);
			_view.addEventListener(ViewEvent.PREVIEW_RERECORD, onStartRecord);
			
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_messageX = VConfigUtil.getDefaultValue(pushParameters.messagex, 0);
			_messageY = VConfigUtil.getDefaultValue(pushParameters.messagey, 0);
			
			// Register External Interface calls
			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback("stopRecording", stopRecording);
					ExternalInterface.addCallback("startRecording", startRecording);
					ExternalInterface.addCallback("previewRecording", previewRecording);
					ExternalInterface.addCallback("stopPreviewRecording", stopPreviewRecording);
					ExternalInterface.addCallback("pausePreview", _recordControl.pausePreviewRecording);
					ExternalInterface.addCallback("resumePreview", _recordControl.resume);
					ExternalInterface.addCallback("addEntry", addEntry);
					ExternalInterface.addCallback("getRecordedTime", getRecordedTime);
					ExternalInterface.addCallback("setQuality", setQuality);
					ExternalInterface.addCallback("getMicrophones", getMicrophones);
					ExternalInterface.addCallback("getActiveMicrophone", getActiveMicrophone);
					ExternalInterface.addCallback("setActiveMicrophone", setActiveMicrophone);
					ExternalInterface.addCallback("getMicrophoneActivityLevel", getMicrophoneActivityLevel);
					ExternalInterface.addCallback("getMicrophoneGain", getMicrophoneGain);
					ExternalInterface.addCallback("setMicrophoneGain", setMicrophoneGain);
					ExternalInterface.addCallback("getMicrophoneRate", getMicrophoneRate);
					ExternalInterface.addCallback("setMicrophoneRate", setMicrophoneRate);
					ExternalInterface.addCallback("getCameras", getCameras);
					ExternalInterface.addCallback("getActiveCamera", getActiveCamera);
					ExternalInterface.addCallback("setActiveCamera", setActiveCamera);
					ExternalInterface.addCallback("getMostRecentEntryId", getMostRecentEntryId);
					
					ExternalInterface.marshallExceptions = true;
					notify("swfReady");
					if (Global.DEBUG_MODE)
						trace('VRecord: JS functions registered to wrapper.\n' + 'objectId - ' + ExternalInterface.objectID);
				}
				catch (err:Error) {
					trace('VRecord: Error initializing VRecord via JS: ', err.message);
				}
			}
			
			// read flashVars for recorder params
			_limitRecord = VConfigUtil.getDefaultValue(pushParameters.limitrecord, 0);
			var hostUrl:String = VConfigUtil.getDefaultValue(pushParameters.host, "http://www.vidiun.com");
			var rtmpHost:String = VConfigUtil.getDefaultValue(pushParameters.rtmphost, "rtmp://www.vidiun.com");
			var fmsApp:String = VConfigUtil.getDefaultValue(pushParameters.fmsapp, "oflaDemo");
			var isLive:Boolean = pushParameters.hasOwnProperty("islive") ? (pushParameters.islive == "1" || pushParameters.islive == "true") : false;
			var streamName:String = pushParameters.hasOwnProperty("streamname") ? pushParameters.streamname : '';
			_recordControl.initRecorderParameters = new BaseRecorderParams(hostUrl, rtmpHost, fmsApp, isLive, streamName);
			
			// optional flashvars:
			_recordControl.debugTrace = Global.DEBUG_MODE;
			// H264 codec related
			_recordControl.isH264 = (pushParameters.ish264 == "1" || pushParameters.ish264 == "true");
			if (pushParameters.hasOwnProperty("h264profile")) {
				_recordControl.h264Profile = pushParameters.h264profile;
			}
			if (pushParameters.hasOwnProperty("h264level")) {
				_recordControl.h264Level = pushParameters.h264level;
			}
			// sound codec to use:
			if (pushParameters.hasOwnProperty("soundcodec")) {
				_recordControl.soundCodec = pushParameters.soundcodec;
			}
			// sound rate to use:
			if (pushParameters.hasOwnProperty("soundrate")) {
				_recordControl.soundRate = pushParameters.soundrate;
			}
			// device detection timer:
			if (pushParameters.hasOwnProperty("timepermic")) {
				_recordControl.micCheckInterval = pushParameters.timepermic;
			}
			
			
			// device detection:
			_recordControl.addEventListener(DeviceDetectionEvent.DEBUG, deviceDetectionDebug);
			
			_recordControl.addEventListener(DeviceDetectionEvent.DETECTED_CAMERA, deviceDetected);
			_recordControl.addEventListener(DeviceDetectionEvent.ERROR_CAMERA, deviceError);
			_recordControl.addEventListener(DeviceDetectionEvent.CAMERA_DENIED, deviceError);
			
			_recordControl.addEventListener(DeviceDetectionEvent.DETECTED_MICROPHONE, deviceDetected);
			_recordControl.addEventListener(DeviceDetectionEvent.MIC_DENIED, deviceError);
			_recordControl.addEventListener(DeviceDetectionEvent.MIC_ALLOWED, deviceError);
			_recordControl.addEventListener(DeviceDetectionEvent.ERROR_MICROPHONE, deviceError);
			
			// net connection:
			_recordControl.addEventListener(ExNetConnectionEvent.NETCONNECTION_CONNECT_SUCCESS, netConnectionEventsHandler);
			_recordControl.addEventListener(ExNetConnectionEvent.NETCONNECTION_CONNECT_FAILED, netConnectionEventsHandler);
			_recordControl.addEventListener(ExNetConnectionEvent.NETCONNECTION_CONNECT_INVALIDAPP, netConnectionEventsHandler);
			_recordControl.addEventListener(ExNetConnectionEvent.NETCONNECTION_CONNECT_CLOSED, netConnectionEventsHandler);
			_recordControl.addEventListener(ExNetConnectionEvent.NETCONNECTION_CONNECT_REJECTED, netConnectionEventsHandler);
			
			_recordControl.addEventListener(RecorderEvent.CONNECTING, connectionEventsHandler);
			_recordControl.addEventListener(RecorderEvent.CONNECTING_FINISH, connectionEventsHandler);
			
			// ?
			_recordControl.addEventListener(FlushStreamEvent.FLUSH_COMPLETE, flushHandler);
			
			// recording:
			_recordControl.addEventListener(RecordNetStreamEvent.NETSTREAM_RECORD_START, recordStart);
			_recordControl.addEventListener(RecorderEvent.RECORD_COMPLETE, recordingCompleteHandler);
			
			_recordControl.addEventListener(RecorderEvent.STREAM_ID_CHANGE, dispatchClone);
			_recordControl.addEventListener(RecorderEvent.UPDATE_RECORDED_TIME, updateRecordrdTime);
			
			// preview:
			_recordControl.addEventListener(RecordNetStreamEvent.NETSTREAM_PLAY_COMPLETE, previewEventsHandler);
			_recordControl.addEventListener(PreviewEvent.PREVIEW_STARTED, previewEventsHandler);
			_recordControl.addEventListener(PreviewEvent.PREVIEW_STOPPED, previewEventsHandler);
			_recordControl.addEventListener(PreviewEvent.PREVIEW_PAUSED, previewEventsHandler);
			_recordControl.addEventListener(PreviewEvent.PREVIEW_RESUMED, previewEventsHandler);
			
			// adding entry:
			_recordControl.addEventListener(AddEntryEvent.ADD_ENTRY_RESULT, addEntryComplete);
			_recordControl.addEventListener(AddEntryEvent.ADD_ENTRY_FAULT, addEntryFailed);
			
			var skipDeviceDetection:Boolean = pushParameters.hasOwnProperty("skipdetection") ? (pushParameters.skipdetection == "true") : false;
			if (Global.DEBUG_MODE)
				trace("VRecord: call deviceDetection. skip detection: ", skipDeviceDetection);
			
			_recordControl.deviceDetection(skipDeviceDetection);
			
			if (this.stage == this.root.parent)
				stage.addEventListener(Event.RESIZE, stageResize);
		}
		
		
		private function deviceDetectionDebug(event:DeviceDetectionEvent):void
		{
			notify(event.type, event.detectedDevice);
		}
		
		/**
		 * handler for view evens that should start new recording (record, re-record) 
		 * @param evt event dispatched from view
		 */
		private function onStartRecord(evt:ViewEvent):void {
			startRecording();
		}


		/**
		 * Stop recording automatically.
		 * This function is here so we dont change the signature of  stopRecording function
		 * @param evt
		 *
		 */
		private function onRecordTimeComplete(evt:TimerEvent):void {
			if (Global.DEBUG_MODE) 
				trace("VRecord: AUTO STOP AFTER ", _limitRecord, " SECONDS")
			stopRecording();
			notify("autoStopRecord", _limitRecord);
		}



		private function onStopRecord(evt:ViewEvent = null):void {
			stopRecording();
		}

		
		public static function isHttpURL(url:String):Boolean {
			return url != null && (url.indexOf("http://") == 0 || url.indexOf("https://") == 0);
		}
		

		public static function getProtocol(url:String):String {
			var slash:int = url.indexOf("/");
			var indx:int = url.indexOf(":/");
			if (indx > -1 && indx < slash) {
				return url.substring(0, indx);
			}
			else {
				indx = url.indexOf("::");
				if (indx > -1 && indx < slash)
					return url.substring(0, indx);
			}

			return "";
		}


		private function onSave(evt:ViewEvent):void {
			_recordControl.stopPreviewRecording();
			// get entry flashvars:
			var entryName:String = VConfigUtil.getDefaultValue(pushParameters.entryname, "");
			var entryTags:String = VConfigUtil.getDefaultValue(pushParameters.entrytags, "");
			var entryDescription:String = VConfigUtil.getDefaultValue(pushParameters.entrydescription, "");
			var creditsScreenName:String = VConfigUtil.getDefaultValue(pushParameters.creditsscreenname, "");
			var creditsSiteUrl:String = VConfigUtil.getDefaultValue(pushParameters.creditssiteurl, "");
			var categories:String = VConfigUtil.getDefaultValue(pushParameters.categories, "");
			var adminTags:String = VConfigUtil.getDefaultValue(pushParameters.admintags, "");
			var licenseType:String = VConfigUtil.getDefaultValue(pushParameters.licensetype, "");
			var credit:String = VConfigUtil.getDefaultValue(pushParameters.credit, "");
			var groupId:String = VConfigUtil.getDefaultValue(pushParameters.groupid, "");
			var partnerData:String = VConfigUtil.getDefaultValue(pushParameters.partnerdata, "");
			var conversionQuality:String = VConfigUtil.getDefaultValue(pushParameters.conversionquality, "");

			addEntry(entryName, entryTags, entryDescription, creditsScreenName, creditsSiteUrl, categories, adminTags, licenseType, credit, groupId, partnerData, conversionQuality)
			
			if (Global.DEBUG_MODE)
				trace("VRecord: SAVE");
		}


		
		
		public function getMostRecentEntryId():String
		{
			return _mostRecentEntryId;
		}
		
		private function previewEventsHandler(event:Event):void
		{
			if (Global.DEBUG_MODE)
				trace('VRecord previewEventsHandler: ' + event.type);
			
			if (event.type == RecordNetStreamEvent.NETSTREAM_PLAY_COMPLETE) {
				notify("previewEnd");
			}
			else {
				notify(event.type);
			}
			dispatchEvent(event.clone());
		}
		
		
		/**
		 * tell the preview player to update total recording time 
		 */
		private function updateRecordrdTime(event:RecorderEvent = null):void {
			var currentState:ViewState = _view.getState();
			if (currentState is ViewStatePreview) {
				(currentState as ViewStatePreview).player.updateTotalTime();
			}
			if (event) {
				dispatchEvent(event.clone());
			}
		}
		
		private function dispatchClone(event:RecorderEvent):void {
			dispatchEvent(event.clone());
		}

		/**
		 * sets camera recording quality.
		 * @param quality		An integer that specifies the required level of picture quality,
		 * 						as determined by the amount of compression being applied to each video frame. Acceptable values range from 1
		 * 						(lowest quality, maximum compression) to 100 (highest quality, no compression).
		 * 						To specify that picture quality can vary as needed to avoid exceeding bandwidth, pass 0 for quality.
		 * @param bw			Specifies the maximum amount of bandwidth that the current outgoing video feed can use,
		 * 						in bytes per second. To specify that Flash Player video can use as much bandwidth as needed to
		 * 						maintain the value of quality, pass 0 for bandwidth.
		 * @param w				the width of the frame.
		 * @param h				the height of the frame.
		 * @param fps			frame per second to use.
		 * @param gop			Specifies which video frames are transmitted in full (called keyframes) instead of 
		 * 						being interpolated by the video compression algorithm. default value: 25
		 * @bufferTime			bufferTime specifies how long the outgoing buffer can grow before the application starts dropping frames. 
		 * 						On a high-speed connection, buffer time is not a concern; data is sent almost as quickly as the application 
		 * 						can buffer it. On a slow connection, however, there can be a significant difference between how fast the 
		 * 						application buffers the data and how fast it is sent to the client. default value: 70 
		 */
		public function setQuality(quality:int, bw:int, w:int, h:int, fps:Number, gop:int = 25, bufferTime:Number = 70):void {
			// default values:		85, 		0, 		336, 	252, 	25
			_recordControl.bufferTime = bufferTime;
			_recordControl.setQuality(quality, bw, w, h, fps, gop);
		}


		public function getMicrophones():String {
			return _recordControl.getMicrophones().toString();
		}
		
		public function getActiveMicrophone():String {
			return _recordControl.getActiveMicrophoneName();
			
		}


		public function setActiveMicrophone(microphoneName:String):void {
			_recordControl.setActiveMicrophone(microphoneName);
		}


		public function getMicrophoneActivityLevel():Number {
			return _recordControl.micophoneActivityLevel;
		}


		/**
		 * returns the volume of the microphone
		 * @return
		 *
		 */
		public function getMicrophoneGain():Number {
			return _recordControl.microphoneGain;
		}


		/**
		 * sets the gain of the microphone
		 * @param val the given volume, between 0 to 100
		 *
		 */
		public function setMicrophoneGain(val:String):void {
			_recordControl.microphoneGain = parseFloat(val);
		}

		
		/**
		 * returns the sample rate of the microphone
		 */
		public function getMicrophoneRate():Number {
			return _recordControl.soundRate;
		}


		/**
		 * sets microphone's sample rate
		 * @param val the required rate
		 * @see Microphone.rate 
		 */
		public function setMicrophoneRate(val:String):void {
			_recordControl.soundRate = parseInt(val);
		}

		
		public function getCameras():String {
			return _recordControl.getCameras().toString();
		}
		
		
		public function getActiveCamera():String {
			return _recordControl.getActiveCameraName();
			
		}
		
		
		public function setActiveCamera(cameraName:String):void {
			_recordControl.setActiveCamera(cameraName);
		}

		/**
		 *the duration of the recording in milliseconds.
		 */
		public function getRecordedTime():uint {
			return _recordControl.recordedTime;
		}


		/**
		 * if the window has a delegator object, trigger it's methods 
		 * @param methodName	name of delegator methods to trigger
		 * @param args	(Optional) method arguments
		 */
		public static function delegator(methodName:String, ... args):void {
			try {
				ExternalInterface.call("eval(window.delegator)", methodName, args);
			}
			catch (error:Error) {
				trace("VRecord delegator: " + error.message);
			}
		}


		/**
		 * general mechanism for notifications: triggers both EI calls and handles UI 
		 * @param methodName	name of EI method to be triggered
		 * @param args	(optional) arguments for EI method
		 */
		private function notify(methodName:String, ... args):void {
			delegator(methodName, args);
			try {
				// trigger EI methods on the delegate object
				var delegate:String = VConfigUtil.getDefaultValue(pushParameters.delegate, "window");
				ExternalInterface.call("eval(" + delegate + "." + methodName + ")", args);
			}
			catch (err:Error) {
				trace("VRecord notify: ", err.message);
			}
			// print message on screen
			if (_showErrorMessage)  {  
				showUIErrorMessage(methodName);
			}
		}

		/**
		 * show a UI error message 
		 * @param methodName
		 */		
		private function showUIErrorMessage(methodName:String):void {
			var messageText:String = "";
			switch (methodName) {
				case DeviceDetectionEvent.ERROR_CAMERA:
					messageText = "Error.CameraError";
					break;
				case DeviceDetectionEvent.ERROR_MICROPHONE:
					messageText = "Error.MichrophoneError";
					break;
				case DeviceDetectionEvent.MIC_DENIED:
					messageText = "Error.micDenied";
					break;
				case DeviceDetectionEvent.CAMERA_DENIED:
					messageText = "Error.cameraDenied";
					break;
				default:
					// handle only the above since the UI is not ready for them yet QND
					return;	
			}
			if (!_message) {
				_message = new TextField();
				_message.width = this.width;
				_message.height = this.height;
				_message.x = _messageX;
				_message.y = _messageY;
				//add drop shadow filter to message
				var my_shadow:DropShadowFilter = new DropShadowFilter();
				my_shadow.color = 0x000000;
				my_shadow.blurY = 3;
				my_shadow.blurX = 3;
				my_shadow.angle = 45;
				my_shadow.alpha = 1;
				my_shadow.distance = 2;
				var filtersArray:Array = new Array(my_shadow);
				_message.filters = filtersArray;
			}
			var tf:TextFormat = new TextFormat();
			tf.color = 0xFFFFFF;
			_message.text = Global.LOCALE.getString(messageText);
			_message.setTextFormat(tf);
			
			addChild(_message);
		}

		private function stageResize(event:Event):void {
			//set the _view width and height because any view resize by it's parent
			_view.width = _view.viewWidth = stage.stageWidth;
			_view.height = _view.viewHeight = stage.stageHeight;

			graphics.clear();
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, _view.viewWidth, _view.viewHeight);
			graphics.endFill();

			if (_recordControl && _recordControl.video) {
				if (contains(_recordControl.video))
					removeChild(_recordControl.video);
				_recordControl.resizeVideo(_view.viewWidth, _view.viewHeight);
				addChildAt(_recordControl.video, 0);
			}
		}


		private function deviceError(event:DeviceDetectionEvent):void {
			notify(event.type);
			switch (event.type) {
				case DeviceDetectionEvent.ERROR_CAMERA:
					_view.showPopupError(Global.LOCALE.getString("Error.CameraError"));
					break;
			}
			dispatchEvent(event.clone());
		}


		private function deviceDetected(event:DeviceDetectionEvent):void {
			// add the detected mic notification
			if (event.type == DeviceDetectionEvent.DETECTED_MICROPHONE) {
				notify(DeviceDetectionEvent.DETECTED_MICROPHONE);
			}

			if (event.type == DeviceDetectionEvent.DETECTED_CAMERA) {
				stageResize(null);
				setInitialQuality();
				_recordControl.connectToRecordingServie();
				notify("deviceDetected");
				
				notify(DeviceDetectionEvent.DETECTED_CAMERA);
			}
			dispatchEvent(event.clone());
		}

		/**
		 * set initial recording quality according to flashvars or default 
		 */
		private function setInitialQuality():void {
			var quality:int = pushParameters.hasOwnProperty("quality") ? pushParameters.quality : 85;
			var bw:int = pushParameters.hasOwnProperty("bw") ? pushParameters.bw : 0;
			var w:int = pushParameters.hasOwnProperty("width") ? pushParameters.width : 336;
			var h:int = pushParameters.hasOwnProperty("height") ? pushParameters.height : 252;
			var fps:Number = pushParameters.hasOwnProperty("fps") ? pushParameters.fps : 25;
			var gop:Number = pushParameters.hasOwnProperty("gop") ? pushParameters.gop : 25;
			var bufferTime:Number = pushParameters.hasOwnProperty("buffertime") ? pushParameters.buffertime : 70;
			setQuality(quality, bw, w, h, fps, gop, bufferTime);
		}

		private function netConnectionEventsHandler(event:ExNetConnectionEvent):void {
			if (Global.DEBUG_MODE)
				trace('VRecord netConnectionEventsHandler: ', event.type);
			var delegateMethod:String;
			switch (event.type) {
				case ExNetConnectionEvent.NETCONNECTION_CONNECT_SUCCESS:
					_view.setState("start");
					delegateMethod = "connected"
					break;
				
				case ExNetConnectionEvent.NETCONNECTION_CONNECT_FAILED:
				case ExNetConnectionEvent.NETCONNECTION_CONNECT_INVALIDAPP: 
				case ExNetConnectionEvent.NETCONNECTION_CONNECT_CLOSED:
				case ExNetConnectionEvent.NETCONNECTION_CONNECT_REJECTED:
					delegateMethod = event.type;
					if (event.type == ExNetConnectionEvent.NETCONNECTION_CONNECT_FAILED) {
						_view.showPopupError(Global.LOCALE.getString("Error.ConnectionError"));
					}
					else if (event.type == ExNetConnectionEvent.NETCONNECTION_CONNECT_CLOSED) {
						_view.showPopupError(Global.LOCALE.getString("Error.ConnectionClosed"));
					}
					break;
			}
			notify(delegateMethod);
			dispatchEvent(event.clone());
		}



		/**
		 * start publishing the video.
		 */
		public function startRecording():void {
			_newViewState = "recording"
			_view.setState(_newViewState);
			_recordControl.recordNewStream();
			limitRecording();
		}


		/**
		 * Check if this instance needs to limit the time and start the timer if needed.
		 */
		private function limitRecording():void {
			if (_limitRecord && !_limitRecordTimer) {
				_limitRecordTimer = new Timer(_limitRecord * 1000, 1);
				_limitRecordTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRecordTimeComplete);
				_limitRecordTimer.start();
			}
		}


		private function recordStart(event:RecordNetStreamEvent):void {
			notify("recordStart");
			dispatchEvent(event.clone());
		}


		/**
		 * stop publishing to the server.
		 */
		public function stopRecording():void {
			_view.showPopupMessage(Global.LOCALE.getString("Dialog.Processing"));
			
			if (_limitRecordTimer) {
				_limitRecordTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onRecordTimeComplete);
				_limitRecordTimer.stop();
				_limitRecordTimer = null;
			}

			_recordControl.stopRecording();
		}
		
		
		private function recordingCompleteHandler(event:RecorderEvent):void {
			notify(event.type); // RecorderEvent.RECORD_COMPLETE
			switchToPreview();
			if (Global.VIEW_PARAMS.autoPreview) {
				previewRecording();
			}
			else {
				updateRecordrdTime(null);
			}
		}
		
		/**
		 * go to "preview" state 
		 */
		private function switchToPreview() :void {
			_newViewState = "preview"
			_view.setState(_newViewState);
		}


		private function flushHandler(event:FlushStreamEvent):void {
			if (Global.DEBUG_MODE)
				trace("VRecord ", event.type + "  :   " + event.bufferSize + " / " + event.totalBuffer);
			
			notify("flushComplete");
			dispatchEvent(event.clone());
		}

		
		private function connectionEventsHandler(event:RecorderEvent):void {
			notify(event.type);
			switch (event.type) {
				case RecorderEvent.CONNECTING:
					// show loader connecting when needed.
					_view.showPopupMessage(Global.LOCALE.getString("Dialog.Connecting"));		
					break;
				case RecorderEvent.CONNECTING_FINISH:
					// remove loader connecting when needed and get back to the current view state.
					_view.setState(_newViewState);		
					break;
			}
			dispatchEvent(event.clone());
		}


		/**
		 * play the recorded stream.
		 */
		public function previewRecording():void {
			var currentState:ViewState = _view.getState();
			if (currentState is ViewStatePreview) {
				(currentState as ViewStatePreview).player.play(new MouseEvent(MouseEvent.CLICK));
			}
		}


		/**
		 * stop playing the recorded stream.
		 */
		public function stopPreviewRecording():void {
			var currentState:ViewState = _view.getState();
			if (currentState is ViewStatePreview) {
				(currentState as ViewStatePreview).player.stop();
			}
		}




		/**
		 * add the last recording as a new Vidiun entry in the Vidiun Network.
		 * @param entry_name				the name for the new added entry.
		 * @param entry_tags				user tags for the newly created entry.
		 * @param entry_description			description of the newly created entry.
		 * @param credits_screen_name		for anonymous user applications - the screen name of the user that contributed the entry.
		 * @param credits_site_url			for anonymous user applications - the website url of the user that contributed the entry.
		 * @param categories				Categories. comma seperated string
		 * @param admin_tags				admin tags for the newly created entry.
		 * @param license_type				the content license type to use (this is arbitrary to be set by the partner).
		 * @param credit					custom partner credit field, NOT USED.
		 * @param group_id					used to group multiple entries in a group.
		 * @param partner_data				special custom data for partners to store.
		 * @param conversionQuality			conversion profile to be used with entry. if null, partner defult profile is used
		 */
		public function addEntry(entry_name:String = '', entry_tags:String = '', entry_description:String = '', credits_screen_name:String = '', credits_site_url:String = '', categories:String = "", admin_tags:String = '',
			license_type:String = '', credit:String = '', group_id:String = '', partner_data:String = '', conversionQuality:String = ''):void {
			if (entry_name == '')
				entry_name = 'recorded_entry_pid' + Global.VIDIUN_CLIENT.partnerId + '_' + (Math.floor(Math.random() * 1000000)).toString();

			notify("beforeAddEntry");
			_recordControl.addEntry(entry_name, entry_tags, entry_description, credits_screen_name, credits_site_url, categories, admin_tags, license_type, credit, group_id, partner_data, conversionQuality);
		}


		private function addEntryFailed(event:AddEntryEvent):void {
			dispatchEvent(event.clone());
			notify("addEntryFailed", {errorCode: event.info.error.errorCode, errorMsg: event.info.error.errorMsg});
		}


		private function addEntryComplete(event:AddEntryEvent):void {
			var entry:VidiunMediaEntry = event.info as VidiunMediaEntry;
			if (entry) {
				_mostRecentEntryId = entry.id;
				notify("addEntryComplete", entry);
				
				if (Global.DEBUG_MODE)
					trace("VRecord: Your new entry is: " + entry.entryId + "\nthumb: " + entry.thumbnailUrl);
			}
			else {
				notify("addEntryFailed", event.info);
				
				if (Global.DEBUG_MODE)
					trace('VRecord: ', ObjectUtil.toString(event.info));
			}
			dispatchEvent(event.clone());
		}

	}
}
