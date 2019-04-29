﻿/*
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
//o
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
package com.vidiun.recording.controller {
	// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/NetStatusEvent.html#info
	
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.media.MediaAddFromRecordedWebcam;
	import com.vidiun.devicedetection.DeviceDetectionEvent;
	import com.vidiun.devicedetection.DeviceDetector;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.net.streaming.RecordNetStream;
	import com.vidiun.net.streaming.events.ExNetConnectionEvent;
	import com.vidiun.net.streaming.events.FlushStreamEvent;
	import com.vidiun.net.streaming.events.RecordNetStreamEvent;
	import com.vidiun.recording.business.BaseRecorderParams;
	import com.vidiun.recording.controller.events.AddEntryEvent;
	import com.vidiun.recording.controller.events.PreviewEvent;
	import com.vidiun.recording.controller.events.RecorderEvent;
	import com.vidiun.utils.ConnectionTester;
	import com.vidiun.vo.VidiunMediaEntry;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;

	[Event(name = "detectedMicrophone", type = "com.vidiun.devicedetection.DeviceDetectionEvent")]
	[Event(name = "detectedCamera", type = "com.vidiun.devicedetection.DeviceDetectionEvent")]
	[Event(name = "errorMicrophone", type = "com.vidiun.devicedetection.DeviceDetectionEvent")]
	[Event(name = "errorCamera", type = "com.vidiun.devicedetection.DeviceDetectionEvent")]
	
	[Event(name = "netconnectionConnectClosed", type = "com.vidiun.net.streaming.events.ExNetConnectionEvent")]
	[Event(name = "netconnectionConnectFailed", type = "com.vidiun.net.streaming.events.ExNetConnectionEvent")]
	[Event(name = "netconnectionConnectSuccess", type = "com.vidiun.net.streaming.events.ExNetConnectionEvent")]
	[Event(name = "netconnectionConnectRejected", type = "com.vidiun.net.streaming.events.ExNetConnectionEvent")]
	[Event(name = "netconnectionConnectInvalidapp", type = "com.vidiun.net.streaming.events.ExNetConnectionEvent")]
	
	[Event(name = "netstreamRecordStart", type = "com.vidiun.net.streaming.events.RecordNetStreamEvent")]
	[Event(name = "netstreamPlayStop", type = "com.vidiun.net.streaming.events.RecordNetStreamEvent")]
	
	[Event(name = "flushComplete", type = "com.vidiun.net.streaming.events.FlushStreamEvent")]
	
	[Event(name = "addEntryResult", type = "com.vidiun.recording.controller.events.AddEntryEvent")]
	[Event(name = "addEntryFault", type = "com.vidiun.recording.controller.events.AddEntryEvent")]
	
	/**
	 * dispatched when the record stream's buffer is empty after recording has stopped
	 * */
	[Event(name = "recordComplete", type = "com.vidiun.recording.controller.events.RecorderEvent")]
	
	/**
	 * dispatched when the preview stream starts playing
	 * */
	[Event(name = "previewStarted", type = "com.vidiun.recording.controller.events.PreviewEvent")]
	
	/**
	 * dispatched when the preview stream stops playing
	 * */
	[Event(name = "previewStopped", type = "com.vidiun.recording.controller.events.PreviewEvent")]
	
	/**
	 * dispatched when the preview stream is paused
	 * */
	[Event(name = "previewPaused", type = "com.vidiun.recording.controller.events.PreviewEvent")]
	
	/**
	 * dispatched when the preview stream resumes playing
	 * */
	[Event(name = "previewResumed", type = "com.vidiun.recording.controller.events.PreviewEvent")]
	
	
	
	/**
	 * VRECORDER - Flash Video and Audio Recording and Contributing Application.
	 * <p>Goals:
	 *	1. Simplified Media Device Detection (Active Camera and Microphone).
	 *	2. Simplified Media Selection Interface (Functions for manually choosing devices from available devices array).
	 *	3. Server Connection and Error Handling.
	 *	4. Video and Audio Recording on Red5, Handling of internal NetStream Events and Errors.
	 *	5. Preview Mechanism - Live Preview using RTMP (Before addentry).
	 *	6. Simplified addentry function to Vidiun Network Servers.
	 *	7. Full JavaScript interaction layer.
	 *	8. Dispatching of Events by Single Object to simplify Development of Recording Applications.</p>
	 * VRecorder does NOT provide any visual elements beyond a native flash video component attached to the recording NetStream.
	 *</p>
	 * @author Zohar Babin
	 */
	public class VRecordControl extends EventDispatcher implements IRecordControl {

		private const EXPANDED_BUFFER_LENGTH:int = 15;
		private const START_BUFFER_LENGTH:int = 2;
		private const MAX_BUFFER_LENGTH:int = 40;

		
		/**
		 * container for soundCodec property
		 */
		private var _soundCodec:String = SoundCodec.NELLYMOSER;

		/**
		 * sound codec to use for recording audio
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/media/SoundCodec.html
		 * @default SoundCodec.NELLYMOSER
		 */
		public function get soundCodec():String
		{
			return _soundCodec;
		}

		/**
		 * @private
		 */
		public function set soundCodec(value:String):void
		{
			_soundCodec = value;
			if (microphone) {
				microphone.codec = value;
			}
		}

		
		/**
		 * container for _soundRate property
		 */
		private var _soundRate:int = 0;

		/**
		 * The rate at which the microphone is capturing sound, in kHz.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/media/Microphone.html#rate
		 */
		public function get soundRate():int
		{
			return _soundRate;
		}

		/**
		 * @private
		 */
		public function set soundRate(value:int):void
		{
			_soundRate = value;
			if (microphone) {
				microphone.rate = value;
			}
		}
		
		
		/**
		 * should recording and playback use H264 codec
		 */
		public var isH264:Boolean;
		
		/**
		 * profile to use when encoding to h264 codec
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/media/H264Profile.html 
		 */
		public var h264Profile:String = H264Profile.MAIN;
		
		/**
		 * level to use when encoding to h264 codec
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/media/H264Level.html 
		 */
		public var h264Level:String = H264Level.LEVEL_3_1;
		
		/**
		 * when looking for active microphone, time to spend on each mic (ms)
		 * @default 20000 
		 */
		public var micCheckInterval:int = 20000;
		
		/**
		 * partner and application settings.
		 */
		protected var _initRecorderParameters:BaseRecorderParams;
		
		/**
		 * the initialization recorder partner and application parameters.
		 */
		public function get initRecorderParameters():BaseRecorderParams {
			return _initRecorderParameters;
		}
		
		
		public function set initRecorderParameters(recorder_parameters:BaseRecorderParams):void {
			_initRecorderParameters = recorder_parameters;
		}
		

		/**
		 * when we need to wait for some operation to start we are connecting.
		 */
		private var _connecting:Boolean = false;


		public function get connecting():Boolean {
			return _connecting;
		}

		public function set connecting(value:Boolean):void {
			_connecting = value;

			if (_connecting)
				dispatchEvent(new RecorderEvent(RecorderEvent.CONNECTING, true));
			else
				dispatchEvent(new RecorderEvent(RecorderEvent.CONNECTING_FINISH, true));
		}

		
		/**
		 * monitors the connection status to the RTMP recording server.
		 */
		public var isConnected:Boolean = false;

		/**
		 * microphone device.
		 */
		protected var microphone:Microphone;
		
		/**
		 * camera device.
		 */
		protected var camera:Camera;
		
		/**
		 * if true, default camera/microphone will be used.
		 */
		protected var _skipDeviceDetection:Boolean = false;
		
		public var video:Video = new Video();


		/**
		 * sets the camera to use, and attaches it to the video component.
		 */
		protected function setCamera(_camera:Camera):void {
			camera = _camera;
			video.attachCamera(camera);
		}

		/**
		 * the NetConnection used for both streams (preview & record) 
		 */
		private var _connection:NetConnection;
		
		/**
		 * NetStream object used for recording 
		 */
		private var _recordStream:NetStream;
		
		/**
		 * NetStream object used for viewing the recorded video 
		 */		
		private var _previewStream:NetStream;
		
		/**
		 * holds the name of the last action requested from the preview stream
		 * while waiting for the stream to catch up (i.e. request preview -> buffer full). <br>
		 * do not forget to reset to null when stream actio is received!
		 */
		private var _waitForPreviewStreamAction:String;
		
		private var _connectionTester:ConnectionTester;
		
		
		protected var _streamUid:String = UIDUtil.createUID();
		
		/**
		 * the uid of the stream recorded.
		 */
		public function get streamUid():String {
			return _streamUid;
		}

		/**
		 * internal implicit setter to change the published stream uid.
		 * @param value		the new stream uid.
		 */
		private function setStreamUid(value:String):void {
			_streamUid = value;
			dispatchEvent(new RecorderEvent(RecorderEvent.STREAM_ID_CHANGE, _streamUid));
		}

		/**
		 * the timestamp of when the recording started.
		 */
		private var _recordStartTime:uint;

		private var _recordedTime:uint;

		private var _bufferTime:Number = 70;


		/**
		 * the duration of the recording in milliseconds.
		 */
		public function get recordedTime():uint {
			return _recordedTime;
		}


		/**
		 * show "trace"  
		 */
		public var debugTrace:Boolean;
		
		/**
		 * sets camera recording quality.
		 * @param quality		An integer that specifies the required level of picture quality,
		 * 						as determined by the amount of compression being applied to each video frame. Acceptable values range from 1
		 * 						(lowest quality, maximum compression) to 100 (highest quality, no compression).
		 * 						To specify that picture quality can vary as needed to avoid exceeding bandwidth, pass 0 for quality.
		 * @param bw			Specifies the maximum amount of bandwidth that the current outgoing video feed can use,
		 * 						in bytes per second. To specify that Flash Player video can use as much bandwidth as needed to
		 * 						maintain the value of quality, pass 0 for bandwidth. The default value is 16384.
		 * @param w				the width of the frame.
		 * @param h				the height of the frame.
		 * @param fps			frame per second to use.
		 * @param gop			Specifies which video frames are transmitted in full (called keyframes) instead of being interpolated 
		 * 						by the video compression algorithm (ie, fps = 30 and gop = 15, => 2 keyframes per second)
		 */
		public function setQuality(quality:int, bw:int, w:int, h:int, fps:Number, gop:int = 15):void {
			camera.setKeyFrameInterval(gop)
			camera.setMode(w, h, fps);
			camera.setQuality(bw, quality);
		}


		/**
		 * resize the video display.
		 * @param w		the new width.
		 * @param h		the new height.
		 */
		public function resizeVideo(w:Number, h:Number):void {
			if (camera) {
				video = new Video(w, h);
				video.width = w;
				video.height = h;
				video.attachCamera(camera);
			}
		}


		/**
		 * an internal implicit setter to recordTime property.
		 * @param value		the new stream recorded length.
		 */
		protected function setRecordedTime(value:uint):void {
			_recordedTime = value;
			dispatchEvent(new RecorderEvent(RecorderEvent.UPDATE_RECORDED_TIME, _recordedTime));
		}

		private var _blackRecordTime:uint = 0;


		/**
		 * this is the blacked out recording time since the client sent request to record and the server sent approve.
		 * we later cut the stream accordingly.
		 */
		public function get blackRecordTime():uint {
			return _blackRecordTime;
		}


		/**
		 * an internal implicit setter to the blackRecordTime property.
		 * @param val	the new duration between record command and actual publish start.
		 */
		protected function setBlackRecordTime(val:uint):void {
			_blackRecordTime = val;
		}


		/**
		 * activity level measured on the microphone: The amount of sound the microphone is detecting. 
		 * Values range from 0 (no sound is detected) to 100 (very loud sound is detected)
		 */
		public function get micophoneActivityLevel():Number {
			if (microphone)
				return microphone.activityLevel;
			else
				return 0;
		}


		/**
		 * The amount by which the microphone boosts the signal. Valid values are 0 to 100. 
		 * @default 50
		 */
		public function get microphoneGain():Number {
			if (microphone)
				return microphone.gain;
			else
				return 0;
		}


		public function set microphoneGain(val:Number):void {
			if (microphone) {
				microphone.gain = val;
			}

		}


		/**
		 * locate active input devices.
		 */
		public function deviceDetection(skip:Boolean = false):void {
			_skipDeviceDetection = skip;
			detectMicrophoneDevice();
		}


		/**
		 * detect the most active microphone device.
		 */
		protected function detectMicrophoneDevice():void {
			if (!microphone) {
				DeviceDetector.debugTrace = debugTrace;
				DeviceDetector.useDefaultDevices = _skipDeviceDetection;
				DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.DETECTED_MICROPHONE, microphoneDeviceDetected, false, 0, true);
				DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.ERROR_MICROPHONE, microphoneDetectionError, false, 0, true);
				DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.MIC_DENIED, allowDenyHandler, false, 0, true);
				DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.MIC_ALLOWED, allowDenyHandler, false, 0, true);
				DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.DEBUG, deviceDebugHandler, false, 0, true);
				DeviceDetector.getInstance().detectMicrophone(micCheckInterval);
			}
			else {
				detectCameraDevice();
			}
		}
		
		private function deviceDebugHandler(event:Event):void
		{
			dispatchEvent(event.clone());
		}

		/**
		 * microphone detected.
		 */
		private function microphoneDeviceDetected(event:DeviceDetectionEvent):void {
//			removeMicrophoneDetectionListeners();
			microphone = event.detectedDevice as Microphone;
			microphone.codec = _soundCodec;
			if (_soundRate) {
				microphone.rate = _soundRate;
			}
			dispatchEvent(event.clone());
			detectCameraDevice();
		}


		/**
		 * microphone deny/allow, camera deny.
		 */
		private function allowDenyHandler(event:DeviceDetectionEvent):void {
			dispatchEvent(event.clone());
		}


		/**
		 * no microphone detected.
		 */
		private function microphoneDetectionError(event:DeviceDetectionEvent):void {
//			removeMicrophoneDetectionListeners();
			dispatchEvent(event.clone());
			detectCameraDevice();
		}


		private function removeMicrophoneDetectionListeners():void {
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.DETECTED_MICROPHONE, microphoneDeviceDetected);
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.ERROR_MICROPHONE, microphoneDetectionError);
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.MIC_DENIED, allowDenyHandler);
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.MIC_ALLOWED, allowDenyHandler);
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.DEBUG, deviceDebugHandler);
		}


		/**
		 * detect the most active camera device.
		 */
		protected function detectCameraDevice():void {
			DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.DETECTED_CAMERA, cameraDeviceDetected, false, 0, true);
			DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.CAMERA_DENIED, allowDenyHandler, false, 0, true);
			DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.ERROR_CAMERA, cameraDetectionError, false, 0, true);
			DeviceDetector.getInstance().addEventListener(DeviceDetectionEvent.DEBUG, deviceDebugHandler, false, 0, true);
			if (Global.DETECTION_DELAY != 0) {
				DeviceDetector.getInstance().detectCamera(Global.DETECTION_DELAY);
			}
			else {
				DeviceDetector.getInstance().detectCamera();
			}
		}


		/**
		 * camera detected.
		 */
		private function cameraDeviceDetected(event:DeviceDetectionEvent):void {
			removeCameraDetectionListeners();
			setCamera(DeviceDetector.getInstance().webCam);
			dispatchEvent(event.clone());
		}


		/**
		 * no camera detected.
		 */
		private function cameraDetectionError(event:DeviceDetectionEvent):void {
			removeCameraDetectionListeners();
			dispatchEvent(event.clone());
		}


		private function removeCameraDetectionListeners():void {
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.DETECTED_CAMERA, cameraDeviceDetected);
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.ERROR_CAMERA, cameraDetectionError);
			DeviceDetector.getInstance().removeEventListener(DeviceDetectionEvent.DEBUG, deviceDebugHandler);
		}


		/**
		 * a list of available camera devices on the system.
		 */
		public function getCameras():Array {
			return Camera.names;
		}


		/**
		 * manually set the camera device to use.
		 */
		public function setActiveCamera(camera_name:String):void {
			removeCameraDetectionListeners();
			var i:int;
			var found:Boolean = false;
			for (i = 0; i < Camera.names.length; ++i) {
				if (camera_name == Camera.names[i]) {
					found = true;
					break;
				}
			}
			setCamera(Camera.getCamera(found == true ? i.toString() : null));
		}
		
		public function getActiveCameraName():String {
			return camera.name;
		}


		/**
		 * a list of available microphone devices on the system.
		 */
		public function getMicrophones():Array {
			return Microphone.names;
		}


		/**
		 * manually select the microphone device to use.
		 */
		public function setActiveMicrophone(microphone_name:String):void {
//			removeMicrophoneDetectionListeners();
			var i:int;
			var found:Boolean = false;
			for (i = 0; i < Microphone.names.length; ++i) {
				if (microphone_name == Microphone.names[i]) {
					found = true;
					break;
				}
			}
			microphone = Microphone.getMicrophone(found == true ? i : null);
		}
		
		
		public function getActiveMicrophoneName():String {
			return microphone.name;
		}


		/**
		 * start a connection to the streaming server.
		 */
		public function connectToRecordingServie():void {
			isConnected = false;
			_connection = new NetConnection();
			_connection.client = new NetConnectionDummyClient();
			NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			_connection.connect(_initRecorderParameters.rtmpHost);
		}


		/**
		 * connected to the streaming server successfully.
		 */
		private function connectionSuccess(event:NetStatusEvent):void {
			var exEvent:ExNetConnectionEvent = new ExNetConnectionEvent(ExNetConnectionEvent.NETCONNECTION_CONNECT_SUCCESS, null, event.info);
			// the event is dispatched from here:
			createRecordStream(exEvent);
			createPreviewStream();
		}


		/**
		 * there was an error in connecting the streaming server.
		 */
		private function connectionFailed(event:NetStatusEvent):void {
			var exEventType:String;
			switch (event.info.code) {
				case "NetConnection.Connect.InvalidApp":
					exEventType = ExNetConnectionEvent.NETCONNECTION_CONNECT_INVALIDAPP;
					break;
				case "NetConnection.Connect.Closed":
					exEventType = ExNetConnectionEvent.NETCONNECTION_CONNECT_CLOSED;
					break;
				case "NetConnection.Connect.Rejected":
					exEventType = ExNetConnectionEvent.NETCONNECTION_CONNECT_REJECTED;
					break;
				case "NetConnection.Connect.Failed":
				default:
					exEventType = ExNetConnectionEvent.NETCONNECTION_CONNECT_FAILED;
					break;
			}
			var exEvent:ExNetConnectionEvent = new ExNetConnectionEvent(exEventType, null, event.info)
			isConnected = false;
			trace("VRecordControl: can't connect to streaming server, " + ObjectUtil.toString(exEvent.connectionInfo));
			dispatchEvent(exEvent);
		}


		/**
		 * open a stream to publish on.
		 */
		protected function createRecordStream(event:ExNetConnectionEvent = null):void {
			if (_recordStream) {
				_recordStream.removeEventListener(NetStatusEvent.NET_STATUS, onRecordNetStatus);
			}
			_recordStream = new NetStream(_connection);
			_recordStream.client = new VRecordNetClient();
			_recordStream.addEventListener(NetStatusEvent.NET_STATUS, onRecordNetStatus);
			_recordStream.bufferTime = MAX_BUFFER_LENGTH;

			isConnected = true;
			if (event)
				dispatchEvent(event.clone());
		}


		private function createPreviewStream():void {
			if (_previewStream) {
				_previewStream.removeEventListener(NetStatusEvent.NET_STATUS, onPreviewNetStatus);
			}
			if (_connectionTester) {
				_connectionTester.removeEventListener(ConnectionTester.SUCCESS, handlePreviewConnectionTest);
				_connectionTester.removeEventListener(ConnectionTester.FAIL, handlePreviewConnectionTest);
			}

			// Create the playBack Stream
			_previewStream = new NetStream(_connection);
			_previewStream.client = new VRecordNetClient();
			_previewStream.addEventListener(NetStatusEvent.NET_STATUS, onPreviewNetStatus);
			_connectionTester = new ConnectionTester(_previewStream, 1500);
			_connectionTester.addEventListener(ConnectionTester.SUCCESS, handlePreviewConnectionTest);
			_connectionTester.addEventListener(ConnectionTester.FAIL, handlePreviewConnectionTest);
		}
		
		
		private function handlePreviewConnectionTest(event:Event):void {
			if (event.type == ConnectionTester.SUCCESS) {
				// do nothing, we're good
			}
			else if (event.type == ConnectionTester.FAIL) {
				stopPreviewRecording();
				connecting = false;
				notifyPreviewEnd();
			}
			
		}
		
		private function onRecordNetStatus(evt:NetStatusEvent):void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: Record NetStatusEvent: " + evt.info.code);
			switch (evt.info.code) {
				case "NetStream.Buffer.Flush":
					var flushEvent:FlushStreamEvent = new FlushStreamEvent(FlushStreamEvent.FLUSH_COMPLETE, 0, 0);
					dispatchEvent(flushEvent);
					break;
				case "NetStream.Record.Start":
					recordStarted();
					break;
			}
		}


		/**
		 * the net connection status report while working.
		 */
		protected function onNetConnectionStatus(event:NetStatusEvent):void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: NetConnectionStatus: " + event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectionSuccess(event);
					break;
				
				case "NetConnection.Connect.InvalidApp":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Rejected":
					connectionFailed(event);
					break;
			}
			dispatchEvent(event);
		}

		private var _previewBufferEmptyInterval:int;
		
		/**
		 * the stream report on a net status event while working.
		 */
		private function onPreviewNetStatus(event:NetStatusEvent):void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: Preview NetStatusEvent: " + event.info.code);

			switch (event.info.code) {
				case "NetStream.Play.Start":
				case "NetStream.Pause.Notify":
					if (_previewBufferEmptyInterval) {
						clearInterval(_previewBufferEmptyInterval);
					}
					(event.target).bufferTime = START_BUFFER_LENGTH;
					break;
				case "NetStream.Play.InsufficientBW":
				case "NetStream.Buffer.Full":
					(event.target).bufferTime = EXPANDED_BUFFER_LENGTH;

					if (_connectionTester.running) {
						_connectionTester.stop();
					}
					connecting = false;
					if (_waitForPreviewStreamAction == 'previewStart') {
						dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW_STARTED));
					}
					else if (_waitForPreviewStreamAction == 'previewResume') {
						dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW_RESUMED));
					}
					_waitForPreviewStreamAction = null;
					break;
				
				case "NetStream.Buffer.Empty":
					(event.target).bufferTime = START_BUFFER_LENGTH;
					_connectionTester.test();
					connecting = true;
					break;
				
				case "NetStream.Play.Stop":
				case "NetStream.Unpause.Notify":
					// wait until buffer is empty before closing
					if (_previewBufferEmptyInterval) {
						// in case we double clicked the "resume preview"
						clearInterval(_previewBufferEmptyInterval);
					}
					_previewBufferEmptyInterval = setInterval(checkPreviewBufferFlushed, 50);
					
					if (_connectionTester.running) {
						_connectionTester.stop();
					}
					break;
			}

			dispatchEvent(event);
		}

		/**
		 * if buffer empty, close stream and notify
		 * */
		private function checkPreviewBufferFlushed():void {
			if (_previewStream.bufferLength <= 0) {
				clearInterval(_previewBufferEmptyInterval);
				connecting = false;
				notifyPreviewEnd();
			}
		}

		private function notifyPreviewEnd():void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: notifyPreviewEnd");
			var evt:RecordNetStreamEvent = new RecordNetStreamEvent(RecordNetStreamEvent.NETSTREAM_PLAY_COMPLETE);
			dispatchEvent(evt);
		}


		/**
		 * the server confirmed start recording.
		 */
		protected function recordStarted():void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: recordStarted");
			connecting = false;
			var recordNetStreamEvt:RecordNetStreamEvent = new RecordNetStreamEvent(RecordNetStreamEvent.NETSTREAM_RECORD_START);
			dispatchEvent(recordNetStreamEvt);
			setBlackRecordTime(getTimer() - _recordStartTime);
		}


		/**
		 * clear the preview and set camera back
		 */
		public function clearVideoAndSetCamera():void {
			video.attachNetStream(null);
			createRecordStream();
			setCamera(camera);
		}


		/**
		 * start publishing the audio.
		 */
		public function recordNewStream():void {
			if (_recordStream) {
				setCamera(camera);
				if (camera) {
					_recordStream.attachCamera(camera);
				}
				if (microphone) {
					_recordStream.attachAudio(microphone);
				}
				
				if (_initRecorderParameters.isLive && _initRecorderParameters.streamName) {
					setStreamUid(_initRecorderParameters.streamName);
				}
				else {
					setStreamUid(UIDUtil.createUID());
				}
				
				
				if (debugTrace) 
					trace(new Date(), "VRecordControl: publishing: " + _streamUid);
				connecting = true; //setting loader until the Record.Start is called
				
				var metaData:Object = new Object();
				if (isH264) {
					var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
					h264Settings.setProfileLevel(h264Profile, h264Level);
					_recordStream.videoStreamSettings = h264Settings;
					if (_initRecorderParameters.isLive) {
						// live - don't add .f4v					
						_recordStream.publish("mp4:" + _streamUid , RecordNetStream.PUBLISH_METHOD_RECORD);
					}
					else {
						// recording - add .f4v
						_recordStream.publish("mp4:" + _streamUid + ".f4v", RecordNetStream.PUBLISH_METHOD_RECORD);
					}
					
					metaData.codec = _recordStream.videoStreamSettings.codec; 
					metaData.profile = h264Settings.profile; 
					metaData.level = h264Settings.level; 
					metaData.fps = camera.fps; 
					metaData.bandwidth = camera.bandwidth; 
					metaData.height = camera.height;
					metaData.width = camera.width;
					metaData.keyFrameInterval = camera.keyFrameInterval;
					_recordStream.send( "@setDataFrame", "onMetaData", metaData);
				}
				else {
					_recordStream.publish(_streamUid, RecordNetStream.PUBLISH_METHOD_RECORD);
					
					metaData.fps = camera.fps; 
					metaData.bandwidth = camera.bandwidth; 
					metaData.height = camera.height;
					metaData.width = camera.width;
					metaData.keyFrameInterval = camera.keyFrameInterval;
					_recordStream.send( "@setDataFrame", "onMetaData", metaData);
				}
				
				_recordStartTime = getTimer();
			}
		}
		
		private var _recordBufferEmptyInterval:int;
		
		/**
		 * if buffer empty, close stream and notify
		 * */
		private function checkRecordBufferFlushed():void {
			if (debugTrace) 
				trace("VRecordControl: buffer: ", _recordStream.bufferLength);
			
			if (_recordStream.bufferLength <= 0) {
				clearInterval(_recordBufferEmptyInterval);
				_recordStream.close();
				_recordHalted = false;
				dispatchEvent(new RecorderEvent(RecorderEvent.RECORD_COMPLETE));
			}
		}

		/**
		 * stop publishing to the server: attach null camera and mic so the stream 
		 * will keep publishing. when buffer is empty, we close it.
		 * @see checkBufferFlushed()
		 */
		public function stopRecording():void {
			setRecordedTime(getTimer() - _recordStartTime);
			if (_recordStream) {
				_recordHalted = true;
				_recordStream.attachAudio(null);
				_recordStream.attachCamera(null);
				_recordBufferEmptyInterval = setInterval(checkRecordBufferFlushed, 50);
			}
		}

		private var _recordHalted:Boolean;

		/**
		 * play the recorded stream.
		 */
		public function previewRecording():void {
			if (_previewStream) {
				connecting = true;
				video.attachNetStream(_previewStream);
				if (debugTrace) 
					trace(new Date(), "VRecordControl: playing: " + _streamUid);
				
				if (isH264) {
					_previewStream.play("mp4:" + _streamUid + ".f4v");
				}
				else {
					_previewStream.play(_streamUid);
				}
				_waitForPreviewStreamAction = 'previewStart';
			}
		}


		/**
		 * stop the playing stream.
		 */
		public function stopPreviewRecording():void {
			if (_previewStream) {
				_previewStream.close();
				dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW_STOPPED));
			}
		}


		/**
		  * pause the playing stream.
		  */
		public function pausePreviewRecording():void {
			if (_previewStream) {
				_previewStream.pause();
				dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW_PAUSED));
			}
		}


		/**
		 * seek the playing stream.
		 */
		public function seek(offset:Number):void {
			if (_previewStream)
				_previewStream.seek(offset);
		}


		/**
		 * resume the playing stream.
		 */
		public function resume():void {
			if (_previewStream) {
				_previewStream.resume();
				_waitForPreviewStreamAction = 'previewResume';
			}
		}


		/**
		 * The position of the playing stream playhead, in seconds.
		 */
		public function get playheadTime():Number {
			if (_previewStream) {
				return _previewStream.time;
			}

			return NaN;
		}


		/**
		 * set the recorder netStream bufferTime.
		 */
		public function set bufferTime(value:Number):void {
			_bufferTime = value;

			if (_recordStream)
				_recordStream.bufferTime = _bufferTime;
		}


		/**
		 * get the recorder netStream bufferLength.
		 */
		public function get bufferLength():Number {
			if (_recordStream)
				return _recordStream.bufferLength;

			return NaN;
		}



		/**
		 * add the last recording as a new Vidiun entry in the Vidiun Network.
		 * @param entry_name				the name for the new added entry.
		 * @param entry_tags				user tags for the newly created entry.
		 * @param entry_description			description of the newly created entry.
		 * @param credits_screen_name		for anonymous user applications - the screen name of the user that contributed the entry.
		 * @param credits_site_url			for anonymous user applications - the website url of the user that contributed the entry.
		 * @param categories				categories of entry
		 * @param admin_tags				admin tags for the newly created entry.
		 * @param license_type				the content license type to use (this is arbitrary to be set by the partner).
		 * @param credit					custom partner credit field, NOT USED.
		 * @param group_id					used to group multiple entries in a group.
		 * @param partner_data				special custom data for partners to store.
		 * @param conversionQuality			conversion profile to be used with entry. if null, partner defult profile is used
		 * @see com.vidiun.recording.business.AddEntryDelegate
		 */
		public function addEntry(entry_name:String, entry_tags:String, entry_description:String, credits_screen_name:String = '',
			credits_site_url:String = '', categories:String = "", admin_tags:String = '', license_type:String = '',
			credit:String = '', group_id:String = '', partner_data:String = '', conversionQuality:String = ''):void {

			var vc:VidiunClient = Global.VIDIUN_CLIENT;
			var entry:VidiunMediaEntry = new VidiunMediaEntry();
			entry.mediaType = 1;
			entry.name = entry_name;
			entry.tags = entry_tags;
			entry.description = entry_description;
			entry.creditUserName = credits_screen_name;
			if (categories && categories != "") {
				entry.categories = categories;
			}
			entry.creditUrl = credits_site_url;
			if (admin_tags && admin_tags != "") {
				entry.adminTags = admin_tags;
			}
			entry.licenseType = int(license_type);
			entry.groupId = int(group_id);
			entry.partnerData = partner_data;
			if (conversionQuality) {
				entry.conversionProfileId = parseInt(conversionQuality);
			}
			//
			var addEntry:MediaAddFromRecordedWebcam = new MediaAddFromRecordedWebcam(entry, streamUid);
			addEntry.useTimeout = false;
			addEntry.addEventListener(VidiunEvent.COMPLETE, addEntryResultHandler);
			addEntry.addEventListener(VidiunEvent.FAILED, addEntryFaultHandler);
			vc.post(addEntry);
		}


		private function addEntryResultHandler(data:Object):void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: result, ", ObjectUtil.toString(data));
			dispatchEvent(new AddEntryEvent(AddEntryEvent.ADD_ENTRY_RESULT, data.data));
		}


		private function addEntryFaultHandler(info:Object):void {
			if (debugTrace) 
				trace(new Date(), "VRecordControl: fault, ", ObjectUtil.toString(info));
			dispatchEvent(new AddEntryEvent(AddEntryEvent.ADD_ENTRY_FAULT, info));
		}
	}
}
