<?php
/*
This file is part of the Vidiun Collaborative Media Suite which allows users
to do with audio, video, and animation what Wiki platfroms allow them to do with
text.

Copyright (C) 2006-2008 Vidiun Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

class VidiunClientBase 
{
	const VIDIUN_API_VERSION = "0.7";
	const VIDIUN_SERVICE_FORMAT_JSON = 1;
	const VIDIUN_SERVICE_FORMAT_XML  = 2;
	const VIDIUN_SERVICE_FORMAT_PHP  = 3;

	/**
	 * @var VidiunConfiguration
	 */
	private $config;
	
	/**
	 * @var string
	 */
	private $vs;
	
	/**
	 * @var boolean
	 */
	private $shouldLog = false;
	
	/**
	 * Vidiun client constuctor, expecting configuration object 
	 *
	 * @param VidiunConfiguration $config
	 */
	public function __construct(VidiunConfiguration $config)
	{
		$this->config = $config;
		
		$logger = $this->config->getLogger();
		if ($logger instanceof IVidiunLogger)
		{
			$this->shouldLog = true;	
		}
	}
		
	public function hit($method, VidiunSessionUser $session_user, $params)
	{
		$start_time = microtime(true);
		
		$this->log("service url: [" . $this->config->serviceUrl . "]");
		$this->log("trying to call method: [" . $method . "] for user id: [" . $session_user->userId . "] using session: [" .$this->vs . "]");
		
		// append the basic params
		$params["vidiun_api_version"] 	= self::VIDIUN_API_VERSION;
		$params["partner_id"] 			= $this->config->partnerId;
		$params["subp_id"] 				= $this->config->subPartnerId;
		$params["format"] 				= $this->config->format;
		$params["uid"] 					= $session_user->userId;
		$this->addOptionalParam($params, "user_name", $session_user->screenName);
		$this->addOptionalParam($params, "vs", $this->vs);
		
		$url = $this->config->serviceUrl . "/index.php/partnerservices2/" . $method;
		$this->log("full reqeust url: [" . $url . "]");
		
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $params);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_USERAGENT, "");
		curl_setopt($ch, CURLOPT_TIMEOUT, 10);
		
		$signature = $this->signature($params);
		$params["vidsig"] = $signature;
		
		$curl_result = curl_exec($ch);
		
		$curl_error = curl_error($ch);
		
		if ($curl_error)
		{
			// TODO: add error code?
			$result["error"] = array($curl_error);
		}
		else 
		{
			$this->log("result (serialized): " . $curl_result);
			
			if ($this->config->format == self::VIDIUN_SERVICE_FORMAT_PHP)
			{
				$result = @unserialize($curl_result);

				if (!$result) {
					$result["result"] = null;
					 // TODO: add error code?
					$result["error"] = array("failed to serialize server result");
				}
				$dump = print_r($result, true);
				$this->log("result (object dump): " . $dump);
			}
			else
			{
				throw new Exception("unsupported format");
			}
		}
		
		$end_time = microtime (true);
		
		$this->log("execution time for method [" . $method . "]: [" . ($end_time - $start_time) . "]");
		
		return $result;
	}

	public function start(VidiunSessionUser $session_user, $secret, $admin = null, $privileges = null, $expiry = 86400)
	{
		$result = $this->startsession($session_user, $secret, $admin, $privileges, $expiry);

		$this->vs = @$result["result"]["vs"];
		return $result;
	}
	
	private function signature($params)
	{
		vsort($params);
		$str = "";
		foreach ($params as $k => $v)
		{
			$str .= $k.$v;
		}
		return md5($str);
	}
		
	public function getVs()
	{
		return $this->vs;
	}
	
	public function setVs($vs)
	{
		$this->vs = $vs;
	}
	
	protected function addOptionalParam(&$params, $paramName, $paramValue)
	{
		if ($paramValue !== null)
		{
			$params[$paramName] = $paramValue;
		}
	}
	
	protected function log($msg)
	{
		if ($this->shouldLog)
			$this->config->getLogger()->log($msg);
	}
}

class VidiunSessionUser
{
	var $userId;
	var $screenName;
}

class VidiunConfiguration
{
	private $logger;

	public $serviceUrl    = "http://www.vidiun.com";
	public $format        = VidiunClient::VIDIUN_SERVICE_FORMAT_PHP;
	public $partnerId     = null;
	public $subPartnerId  = null;
	
	/**
	 * Constructs new vidiun configuration object, expecting partner id & sub partner id
	 *
	 * @param int $partnerId
	 * @param int $subPartnerId
	 */
	public function __construct($partnerId, $subPartnerId)
	{
		$this->partnerId 	= $partnerId;
		$this->subPartnerId = $subPartnerId;
	}
	
	/**
	 * Set logger to get vidiun client debug logs
	 *
	 * @param IVidiunLogger $log
	 */
	public function setLogger(IVidiunLogger $log)
	{
		$this->logger = $log;
	}
	
	/**
	 * Gets the logger (Internal client use)
	 *
	 * @return unknown
	 */
	public function getLogger()
	{
		return $this->logger;
	}
}

/**
 * Implement to get vidiun client logs
 *
 */
interface IVidiunLogger 
{
	function log($msg); 
}


?>