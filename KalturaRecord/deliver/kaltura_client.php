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

require_once("vidiun_client_base.php");

class VidiunEntry
{
	public $name;
	public $tags;
	public $type;
	public $mediaType;
	public $source;
	public $sourceId;
	public $sourceLink;
	public $licenseType;
	public $credit;
	public $groupId;
	public $partnerData;
	public $conversionQuality;
	public $permissions;
	public $dataContent;
	public $desiredVersion;
	public $url;
	public $thumbUrl;
	public $filename;
	public $realFilename;
	public $indexedCustomData1;
	public $thumbOffset;
}

class VidiunVShow
{
	public $name;
	public $description;
	public $tags;
	public $indexedCustomData3;
	public $groupId;
	public $permissions;
	public $partnerData;
	public $allowQuickEdit;
}

class VidiunModeration
{
	public $comments;
	public $objectType;
	public $objectId;
}

class VidiunUser
{
	public $screenName;
	public $fullName;
	public $email;
	public $dateOfBirth;
	public $aboutMe;
	public $tags;
	public $gender;
	public $country;
	public $state;
	public $city;
	public $zip;
	public $urlList;
	public $networkHighschool;
	public $networkCollege;
	public $partnerData;
}

class VidiunWidget
{
	public $vshowId;
	public $entryId;
	public $sourceWidgetId;
	public $uiConfId;
	public $customData;
	public $partnerData;
	public $securityType;
}

class VidiunPuserVuser
{
}

class VidiunUiConf
{
	public $name;
}

class VidiunEntryFilter
{
	const ORDER_BY_CREATED_AT_ASC = "+created_at";
	const ORDER_BY_CREATED_AT_DESC = "-created_at";
	const ORDER_BY_VIEWS_ASC = "+views";
	const ORDER_BY_VIEWS_DESC = "-views";
	const ORDER_BY_ID_ASC = "+id";
	const ORDER_BY_ID_DESC = "-id";

	public $equalUserId;
	public $equalVshowId;
	public $equalType;
	public $inType;
	public $equalMediaType;
	public $inMediaType;
	public $equalIndexedCustomData;
	public $inIndexedCustomData;
	public $likeName;
	public $equalGroupId;
	public $greaterThanOrEqualViews;
	public $greaterThanOrEqualCreatedAt;
	public $lessThanOrEqualCreatedAt;
	public $inPartnerId;
	public $equalPartnerId;
	public $orderBy;
}

class VidiunVShowFilter
{
	const ORDER_BY_CREATED_AT_ASC = "+created_at";
	const ORDER_BY_CREATED_AT_DESC = "-created_at";
	const ORDER_BY_VIEWS_ASC = "+views";
	const ORDER_BY_VIEWS_DESC = "-views";
	const ORDER_BY_ID_ASC = "+id";
	const ORDER_BY_ID_DESC = "-id";

	public $greaterThanOrEqualViews;
	public $equalType;
	public $equalProducerId;
	public $greaterThanOrEqualCreatedAt;
	public $lessThanOrEqualCreatedAt;
	public $orderBy;
}

class VidiunModerationFilter
{
	const ORDER_BY_ID_ASC = "+id";
	const ORDER_BY_ID_DESC = "-id";

	public $equalId;
	public $equalPuserId;
	public $equalStatus;
	public $likeComments;
	public $equalObjectId;
	public $equalObjectType;
	public $equalGroupId;
	public $orderBy;
}

class VidiunNotificationFilter
{
	const ORDER_BY_ID_ASC = "+id";
	const ORDER_BY_ID_DESC = "-id";

	public $equalId;
	public $greaterThanOrEqualId;
	public $equalStatus;
	public $equalType;
	public $orderBy;
}

class VidiunNotification
{
	public $id;
	public $status;
	public $notificationResult;
}

class VidiunPartner
{
	public $name;
	public $url1;
	public $url2;
	public $appearInSearch;
	public $adminName;
	public $adminEmail;
	public $description;
	public $commercialUse;
}

class VidiunClient extends VidiunClientBase
{
	public function __constructor()
	{
		parent::__constructor();
	}

	public function addDvdEntry(VidiunSessionUser $vidiunSessionUser, VidiunEntry $dvdEntry)
	{
		$params = array();
		$this->addOptionalParam($params, "dvdEntry_name", $dvdEntry->name);
		$this->addOptionalParam($params, "dvdEntry_tags", $dvdEntry->tags);
		$this->addOptionalParam($params, "dvdEntry_type", $dvdEntry->type);
		$this->addOptionalParam($params, "dvdEntry_mediaType", $dvdEntry->mediaType);
		$this->addOptionalParam($params, "dvdEntry_source", $dvdEntry->source);
		$this->addOptionalParam($params, "dvdEntry_sourceId", $dvdEntry->sourceId);
		$this->addOptionalParam($params, "dvdEntry_sourceLink", $dvdEntry->sourceLink);
		$this->addOptionalParam($params, "dvdEntry_licenseType", $dvdEntry->licenseType);
		$this->addOptionalParam($params, "dvdEntry_credit", $dvdEntry->credit);
		$this->addOptionalParam($params, "dvdEntry_groupId", $dvdEntry->groupId);
		$this->addOptionalParam($params, "dvdEntry_partnerData", $dvdEntry->partnerData);
		$this->addOptionalParam($params, "dvdEntry_conversionQuality", $dvdEntry->conversionQuality);
		$this->addOptionalParam($params, "dvdEntry_permissions", $dvdEntry->permissions);
		$this->addOptionalParam($params, "dvdEntry_dataContent", $dvdEntry->dataContent);
		$this->addOptionalParam($params, "dvdEntry_desiredVersion", $dvdEntry->desiredVersion);
		$this->addOptionalParam($params, "dvdEntry_url", $dvdEntry->url);
		$this->addOptionalParam($params, "dvdEntry_thumbUrl", $dvdEntry->thumbUrl);
		$this->addOptionalParam($params, "dvdEntry_filename", $dvdEntry->filename);
		$this->addOptionalParam($params, "dvdEntry_realFilename", $dvdEntry->realFilename);
		$this->addOptionalParam($params, "dvdEntry_indexedCustomData1", $dvdEntry->indexedCustomData1);
		$this->addOptionalParam($params, "dvdEntry_thumbOffset", $dvdEntry->thumbOffset);

		$result = $this->hit("adddvdentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function addEntry(VidiunSessionUser $vidiunSessionUser, $vshowId, VidiunEntry $entry, $uid = null)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "entry_name", $entry->name);
		$this->addOptionalParam($params, "entry_tags", $entry->tags);
		$this->addOptionalParam($params, "entry_type", $entry->type);
		$this->addOptionalParam($params, "entry_mediaType", $entry->mediaType);
		$this->addOptionalParam($params, "entry_source", $entry->source);
		$this->addOptionalParam($params, "entry_sourceId", $entry->sourceId);
		$this->addOptionalParam($params, "entry_sourceLink", $entry->sourceLink);
		$this->addOptionalParam($params, "entry_licenseType", $entry->licenseType);
		$this->addOptionalParam($params, "entry_credit", $entry->credit);
		$this->addOptionalParam($params, "entry_groupId", $entry->groupId);
		$this->addOptionalParam($params, "entry_partnerData", $entry->partnerData);
		$this->addOptionalParam($params, "entry_conversionQuality", $entry->conversionQuality);
		$this->addOptionalParam($params, "entry_permissions", $entry->permissions);
		$this->addOptionalParam($params, "entry_dataContent", $entry->dataContent);
		$this->addOptionalParam($params, "entry_desiredVersion", $entry->desiredVersion);
		$this->addOptionalParam($params, "entry_url", $entry->url);
		$this->addOptionalParam($params, "entry_thumbUrl", $entry->thumbUrl);
		$this->addOptionalParam($params, "entry_filename", $entry->filename);
		$this->addOptionalParam($params, "entry_realFilename", $entry->realFilename);
		$this->addOptionalParam($params, "entry_indexedCustomData1", $entry->indexedCustomData1);
		$this->addOptionalParam($params, "entry_thumbOffset", $entry->thumbOffset);
		$this->addOptionalParam($params, "uid", $uid);

		$result = $this->hit("addentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function addVShow(VidiunSessionUser $vidiunSessionUser, VidiunVShow $vshow, $detailed = null, $allowDuplicateNames = null)
	{
		$params = array();
		$this->addOptionalParam($params, "vshow_name", $vshow->name);
		$this->addOptionalParam($params, "vshow_description", $vshow->description);
		$this->addOptionalParam($params, "vshow_tags", $vshow->tags);
		$this->addOptionalParam($params, "vshow_indexedCustomData3", $vshow->indexedCustomData3);
		$this->addOptionalParam($params, "vshow_groupId", $vshow->groupId);
		$this->addOptionalParam($params, "vshow_permissions", $vshow->permissions);
		$this->addOptionalParam($params, "vshow_partnerData", $vshow->partnerData);
		$this->addOptionalParam($params, "vshow_allowQuickEdit", $vshow->allowQuickEdit);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "allow_duplicate_names", $allowDuplicateNames);

		$result = $this->hit("addvshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function addModeration(VidiunSessionUser $vidiunSessionUser, VidiunModeration $moderation)
	{
		$params = array();
		$this->addOptionalParam($params, "moderation_comments", $moderation->comments);
		$this->addOptionalParam($params, "moderation_objectType", $moderation->objectType);
		$this->addOptionalParam($params, "moderation_objectId", $moderation->objectId);

		$result = $this->hit("addmoderation", $vidiunSessionUser, $params);
		return $result;
	}

	public function addPartnerEntry(VidiunSessionUser $vidiunSessionUser, $vshowId, VidiunEntry $entry, $uid = null)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "entry_name", $entry->name);
		$this->addOptionalParam($params, "entry_tags", $entry->tags);
		$this->addOptionalParam($params, "entry_type", $entry->type);
		$this->addOptionalParam($params, "entry_mediaType", $entry->mediaType);
		$this->addOptionalParam($params, "entry_source", $entry->source);
		$this->addOptionalParam($params, "entry_sourceId", $entry->sourceId);
		$this->addOptionalParam($params, "entry_sourceLink", $entry->sourceLink);
		$this->addOptionalParam($params, "entry_licenseType", $entry->licenseType);
		$this->addOptionalParam($params, "entry_credit", $entry->credit);
		$this->addOptionalParam($params, "entry_groupId", $entry->groupId);
		$this->addOptionalParam($params, "entry_partnerData", $entry->partnerData);
		$this->addOptionalParam($params, "entry_conversionQuality", $entry->conversionQuality);
		$this->addOptionalParam($params, "entry_permissions", $entry->permissions);
		$this->addOptionalParam($params, "entry_dataContent", $entry->dataContent);
		$this->addOptionalParam($params, "entry_desiredVersion", $entry->desiredVersion);
		$this->addOptionalParam($params, "entry_url", $entry->url);
		$this->addOptionalParam($params, "entry_thumbUrl", $entry->thumbUrl);
		$this->addOptionalParam($params, "entry_filename", $entry->filename);
		$this->addOptionalParam($params, "entry_realFilename", $entry->realFilename);
		$this->addOptionalParam($params, "entry_indexedCustomData1", $entry->indexedCustomData1);
		$this->addOptionalParam($params, "entry_thumbOffset", $entry->thumbOffset);
		$this->addOptionalParam($params, "uid", $uid);

		$result = $this->hit("addpartnerentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function addUser(VidiunSessionUser $vidiunSessionUser, $userId, VidiunUser $user)
	{
		$params = array();
		$params["user_id"] = $userId;
		$this->addOptionalParam($params, "user_screenName", $user->screenName);
		$this->addOptionalParam($params, "user_fullName", $user->fullName);
		$this->addOptionalParam($params, "user_email", $user->email);
		$this->addOptionalParam($params, "user_dateOfBirth", $user->dateOfBirth);
		$this->addOptionalParam($params, "user_aboutMe", $user->aboutMe);
		$this->addOptionalParam($params, "user_tags", $user->tags);
		$this->addOptionalParam($params, "user_gender", $user->gender);
		$this->addOptionalParam($params, "user_country", $user->country);
		$this->addOptionalParam($params, "user_state", $user->state);
		$this->addOptionalParam($params, "user_city", $user->city);
		$this->addOptionalParam($params, "user_zip", $user->zip);
		$this->addOptionalParam($params, "user_urlList", $user->urlList);
		$this->addOptionalParam($params, "user_networkHighschool", $user->networkHighschool);
		$this->addOptionalParam($params, "user_networkCollege", $user->networkCollege);
		$this->addOptionalParam($params, "user_partnerData", $user->partnerData);

		$result = $this->hit("adduser", $vidiunSessionUser, $params);
		return $result;
	}

	public function addWidget(VidiunSessionUser $vidiunSessionUser, VidiunWidget $widget)
	{
		$params = array();
		$this->addOptionalParam($params, "widget_vshowId", $widget->vshowId);
		$this->addOptionalParam($params, "widget_entryId", $widget->entryId);
		$this->addOptionalParam($params, "widget_sourceWidgetId", $widget->sourceWidgetId);
		$this->addOptionalParam($params, "widget_uiConfId", $widget->uiConfId);
		$this->addOptionalParam($params, "widget_customData", $widget->customData);
		$this->addOptionalParam($params, "widget_partnerData", $widget->partnerData);
		$this->addOptionalParam($params, "widget_securityType", $widget->securityType);

		$result = $this->hit("addwidget", $vidiunSessionUser, $params);
		return $result;
	}

	public function checkNotifications(VidiunSessionUser $vidiunSessionUser, $notificationIds, $separator = ",", $detailed = null)
	{
		$params = array();
		$params["notification_ids"] = $notificationIds;
		$this->addOptionalParam($params, "separator", $separator);
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("checknotifications", $vidiunSessionUser, $params);
		return $result;
	}

	public function cloneVShow(VidiunSessionUser $vidiunSessionUser, $vshowId, $detailed = null)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("clonevshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function collectStats(VidiunSessionUser $vidiunSessionUser, $objType, $objId, $command, $value, $extraInfo, $vshowId = null)
	{
		$params = array();
		$params["obj_type"] = $objType;
		$params["obj_id"] = $objId;
		$params["command"] = $command;
		$params["value"] = $value;
		$params["extra_info"] = $extraInfo;
		$this->addOptionalParam($params, "vshow_id", $vshowId);

		$result = $this->hit("collectstats", $vidiunSessionUser, $params);
		return $result;
	}

	public function deleteEntry(VidiunSessionUser $vidiunSessionUser, $entryId, $vshowId = null)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$this->addOptionalParam($params, "vshow_id", $vshowId);

		$result = $this->hit("deleteentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function deleteVShow(VidiunSessionUser $vidiunSessionUser, $vshowId)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;

		$result = $this->hit("deletevshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function deleteUser(VidiunSessionUser $vidiunSessionUser, $userId)
	{
		$params = array();
		$params["user_id"] = $userId;

		$result = $this->hit("deleteuser", $vidiunSessionUser, $params);
		return $result;
	}

	public function getAllEntries(VidiunSessionUser $vidiunSessionUser, $entryId, $vshowId, $listType = null, $version = null)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "list_type", $listType);
		$this->addOptionalParam($params, "version", $version);

		$result = $this->hit("getallentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function getDvdEntry(VidiunSessionUser $vidiunSessionUser, $dvdEntryId, $detailed = null)
	{
		$params = array();
		$params["dvdEntry_id"] = $dvdEntryId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("getdvdentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function getEntries(VidiunSessionUser $vidiunSessionUser, $entryIds, $separator = ",", $detailed = null)
	{
		$params = array();
		$params["entry_ids"] = $entryIds;
		$this->addOptionalParam($params, "separator", $separator);
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("getentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function getEntry(VidiunSessionUser $vidiunSessionUser, $entryId, $detailed = null, $version = null)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "version", $version);

		$result = $this->hit("getentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function getVShow(VidiunSessionUser $vidiunSessionUser, $vshowId, $detailed = null)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("getvshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function getLastVersionsInfo(VidiunSessionUser $vidiunSessionUser, $vshowId)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;

		$result = $this->hit("getlastversionsinfo", $vidiunSessionUser, $params);
		return $result;
	}

	public function getMetaDataAction(VidiunSessionUser $vidiunSessionUser, $entryId, $vshowId, $version)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$params["vshow_id"] = $vshowId;
		$params["version"] = $version;

		$result = $this->hit("getmetadata", $vidiunSessionUser, $params);
		return $result;
	}

	public function getPartner(VidiunSessionUser $vidiunSessionUser, $partnerAdminEmail, $cmsPassword, $partnerId)
	{
		$params = array();
		$params["partner_adminEmail"] = $partnerAdminEmail;
		$params["cms_password"] = $cmsPassword;
		$params["partner_id"] = $partnerId;

		$result = $this->hit("getpartner", $vidiunSessionUser, $params);
		return $result;
	}

	public function getThumbnail(VidiunSessionUser $vidiunSessionUser, $filename)
	{
		$params = array();
		$params["filename"] = $filename;

		$result = $this->hit("getthumbnail", $vidiunSessionUser, $params);
		return $result;
	}

	public function getUIConf(VidiunSessionUser $vidiunSessionUser, $uiConfId, $detailed = null)
	{
		$params = array();
		$params["ui_conf_id"] = $uiConfId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("getuiconf", $vidiunSessionUser, $params);
		return $result;
	}

	public function getUser(VidiunSessionUser $vidiunSessionUser, $userId, $detailed = null)
	{
		$params = array();
		$params["user_id"] = $userId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("getuser", $vidiunSessionUser, $params);
		return $result;
	}

	public function getWidget(VidiunSessionUser $vidiunSessionUser, $widgetId, $detailed = null)
	{
		$params = array();
		$params["widget_id"] = $widgetId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("getwidget", $vidiunSessionUser, $params);
		return $result;
	}

	public function handleModeration(VidiunSessionUser $vidiunSessionUser, $moderationId, $moderationStatus)
	{
		$params = array();
		$params["moderation_id"] = $moderationId;
		$params["moderation_status"] = $moderationStatus;

		$result = $this->hit("handlemoderation", $vidiunSessionUser, $params);
		return $result;
	}

	public function listDvdEntries(VidiunSessionUser $vidiunSessionUser, VidiunEntryFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_user_id", $filter->equalUserId);
		$this->addOptionalParam($params, "filter__eq_vshow_id", $filter->equalVshowId);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__in_type", $filter->inType);
		$this->addOptionalParam($params, "filter__eq_media_type", $filter->equalMediaType);
		$this->addOptionalParam($params, "filter__in_media_type", $filter->inMediaType);
		$this->addOptionalParam($params, "filter__eq_indexed_custom_data_1", $filter->equalIndexedCustomData);
		$this->addOptionalParam($params, "filter__in_indexed_custom_data_1", $filter->inIndexedCustomData);
		$this->addOptionalParam($params, "filter__like_name", $filter->likeName);
		$this->addOptionalParam($params, "filter__eq_group_id", $filter->equalGroupId);
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__in_partner_id", $filter->inPartnerId);
		$this->addOptionalParam($params, "filter__eq_partner_id", $filter->equalPartnerId);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listdvdentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function listEntries(VidiunSessionUser $vidiunSessionUser, VidiunEntryFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_user_id", $filter->equalUserId);
		$this->addOptionalParam($params, "filter__eq_vshow_id", $filter->equalVshowId);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__in_type", $filter->inType);
		$this->addOptionalParam($params, "filter__eq_media_type", $filter->equalMediaType);
		$this->addOptionalParam($params, "filter__in_media_type", $filter->inMediaType);
		$this->addOptionalParam($params, "filter__eq_indexed_custom_data_1", $filter->equalIndexedCustomData);
		$this->addOptionalParam($params, "filter__in_indexed_custom_data_1", $filter->inIndexedCustomData);
		$this->addOptionalParam($params, "filter__like_name", $filter->likeName);
		$this->addOptionalParam($params, "filter__eq_group_id", $filter->equalGroupId);
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__in_partner_id", $filter->inPartnerId);
		$this->addOptionalParam($params, "filter__eq_partner_id", $filter->equalPartnerId);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function listVShows(VidiunSessionUser $vidiunSessionUser, VidiunVShowFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__eq_producer_id", $filter->equalProducerId);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listvshows", $vidiunSessionUser, $params);
		return $result;
	}

	public function listModerations(VidiunSessionUser $vidiunSessionUser, VidiunModerationFilter $filter, $detailed = null, $pageSize = 10, $page = 1)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_id", $filter->equalId);
		$this->addOptionalParam($params, "filter__eq_puser_id", $filter->equalPuserId);
		$this->addOptionalParam($params, "filter__eq_status", $filter->equalStatus);
		$this->addOptionalParam($params, "filter__like_comments", $filter->likeComments);
		$this->addOptionalParam($params, "filter__eq_object_id", $filter->equalObjectId);
		$this->addOptionalParam($params, "filter__eq_object_type", $filter->equalObjectType);
		$this->addOptionalParam($params, "filter__eq_group_id", $filter->equalGroupId);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);

		$result = $this->hit("listmoderations", $vidiunSessionUser, $params);
		return $result;
	}

	public function listMyDvdEntries(VidiunSessionUser $vidiunSessionUser, VidiunEntryFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_user_id", $filter->equalUserId);
		$this->addOptionalParam($params, "filter__eq_vshow_id", $filter->equalVshowId);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__in_type", $filter->inType);
		$this->addOptionalParam($params, "filter__eq_media_type", $filter->equalMediaType);
		$this->addOptionalParam($params, "filter__in_media_type", $filter->inMediaType);
		$this->addOptionalParam($params, "filter__eq_indexed_custom_data_1", $filter->equalIndexedCustomData);
		$this->addOptionalParam($params, "filter__in_indexed_custom_data_1", $filter->inIndexedCustomData);
		$this->addOptionalParam($params, "filter__like_name", $filter->likeName);
		$this->addOptionalParam($params, "filter__eq_group_id", $filter->equalGroupId);
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__in_partner_id", $filter->inPartnerId);
		$this->addOptionalParam($params, "filter__eq_partner_id", $filter->equalPartnerId);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listmydvdentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function listMyEntries(VidiunSessionUser $vidiunSessionUser, VidiunEntryFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_user_id", $filter->equalUserId);
		$this->addOptionalParam($params, "filter__eq_vshow_id", $filter->equalVshowId);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__in_type", $filter->inType);
		$this->addOptionalParam($params, "filter__eq_media_type", $filter->equalMediaType);
		$this->addOptionalParam($params, "filter__in_media_type", $filter->inMediaType);
		$this->addOptionalParam($params, "filter__eq_indexed_custom_data_1", $filter->equalIndexedCustomData);
		$this->addOptionalParam($params, "filter__in_indexed_custom_data_1", $filter->inIndexedCustomData);
		$this->addOptionalParam($params, "filter__like_name", $filter->likeName);
		$this->addOptionalParam($params, "filter__eq_group_id", $filter->equalGroupId);
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__in_partner_id", $filter->inPartnerId);
		$this->addOptionalParam($params, "filter__eq_partner_id", $filter->equalPartnerId);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listmyentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function listMyVShows(VidiunSessionUser $vidiunSessionUser, VidiunVShowFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__eq_producer_id", $filter->equalProducerId);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listmyvshows", $vidiunSessionUser, $params);
		return $result;
	}

	public function listNotifications(VidiunSessionUser $vidiunSessionUser, VidiunNotificationFilter $filter, $pageSize = 10, $page = 1)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_id", $filter->equalId);
		$this->addOptionalParam($params, "filter__gte_id", $filter->greaterThanOrEqualId);
		$this->addOptionalParam($params, "filter__eq_status", $filter->equalStatus);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);

		$result = $this->hit("listnotifications", $vidiunSessionUser, $params);
		return $result;
	}

	public function listPartnerEntries(VidiunSessionUser $vidiunSessionUser, VidiunEntryFilter $filter, $detailed = null, $pageSize = 10, $page = 1, $useFilterPuserId = null)
	{
		$params = array();
		$this->addOptionalParam($params, "filter__eq_user_id", $filter->equalUserId);
		$this->addOptionalParam($params, "filter__eq_vshow_id", $filter->equalVshowId);
		$this->addOptionalParam($params, "filter__eq_type", $filter->equalType);
		$this->addOptionalParam($params, "filter__in_type", $filter->inType);
		$this->addOptionalParam($params, "filter__eq_media_type", $filter->equalMediaType);
		$this->addOptionalParam($params, "filter__in_media_type", $filter->inMediaType);
		$this->addOptionalParam($params, "filter__eq_indexed_custom_data_1", $filter->equalIndexedCustomData);
		$this->addOptionalParam($params, "filter__in_indexed_custom_data_1", $filter->inIndexedCustomData);
		$this->addOptionalParam($params, "filter__like_name", $filter->likeName);
		$this->addOptionalParam($params, "filter__eq_group_id", $filter->equalGroupId);
		$this->addOptionalParam($params, "filter__gte_views", $filter->greaterThanOrEqualViews);
		$this->addOptionalParam($params, "filter__gte_created_at", $filter->greaterThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__lte_created_at", $filter->lessThanOrEqualCreatedAt);
		$this->addOptionalParam($params, "filter__in_partner_id", $filter->inPartnerId);
		$this->addOptionalParam($params, "filter__eq_partner_id", $filter->equalPartnerId);
		$this->addOptionalParam($params, "filter__order_by", $filter->orderBy);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "use_filter_puser_id", $useFilterPuserId);

		$result = $this->hit("listpartnerentries", $vidiunSessionUser, $params);
		return $result;
	}

	public function rankVShow(VidiunSessionUser $vidiunSessionUser, $vshowId, $rank, $pageSize = 10, $page = 1)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$params["rank"] = $rank;
		$this->addOptionalParam($params, "page_size", $pageSize);
		$this->addOptionalParam($params, "page", $page);

		$result = $this->hit("rankvshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function registerPartner(VidiunSessionUser $vidiunSessionUser, VidiunPartner $partner, $cmsPassword = null)
	{
		$params = array();
		$this->addOptionalParam($params, "partner_name", $partner->name);
		$this->addOptionalParam($params, "partner_url1", $partner->url1);
		$this->addOptionalParam($params, "partner_url2", $partner->url2);
		$this->addOptionalParam($params, "partner_appearInSearch", $partner->appearInSearch);
		$this->addOptionalParam($params, "partner_adminName", $partner->adminName);
		$this->addOptionalParam($params, "partner_adminEmail", $partner->adminEmail);
		$this->addOptionalParam($params, "partner_description", $partner->description);
		$this->addOptionalParam($params, "partner_commercialUse", $partner->commercialUse);
		$this->addOptionalParam($params, "cms_password", $cmsPassword);

		$result = $this->hit("registerpartner", $vidiunSessionUser, $params);
		return $result;
	}

	public function reportEntry(VidiunSessionUser $vidiunSessionUser, VidiunModeration $moderation)
	{
		$params = array();
		$this->addOptionalParam($params, "moderation_comments", $moderation->comments);
		$this->addOptionalParam($params, "moderation_objectType", $moderation->objectType);
		$this->addOptionalParam($params, "moderation_objectId", $moderation->objectId);

		$result = $this->hit("reportentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function reportVShow(VidiunSessionUser $vidiunSessionUser, VidiunModeration $moderation)
	{
		$params = array();
		$this->addOptionalParam($params, "moderation_comments", $moderation->comments);
		$this->addOptionalParam($params, "moderation_objectType", $moderation->objectType);
		$this->addOptionalParam($params, "moderation_objectId", $moderation->objectId);

		$result = $this->hit("reportvshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function rollbackVShow(VidiunSessionUser $vidiunSessionUser, $vshowId, $vshowVersion)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$params["vshow_version"] = $vshowVersion;

		$result = $this->hit("rollbackvshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function search(VidiunSessionUser $vidiunSessionUser, $mediaType, $mediaSource, $search, $authData, $page = 1, $pageSize = 10)
	{
		$params = array();
		$params["media_type"] = $mediaType;
		$params["media_source"] = $mediaSource;
		$params["search"] = $search;
		$params["auth_data"] = $authData;
		$this->addOptionalParam($params, "page", $page);
		$this->addOptionalParam($params, "page_size", $pageSize);

		$result = $this->hit("search", $vidiunSessionUser, $params);
		return $result;
	}

	public function searchAuthData(VidiunSessionUser $vidiunSessionUser, $mediaSource, $username, $password)
	{
		$params = array();
		$params["media_source"] = $mediaSource;
		$params["username"] = $username;
		$params["password"] = $password;

		$result = $this->hit("searchauthdata", $vidiunSessionUser, $params);
		return $result;
	}

	public function searchFromUrl(VidiunSessionUser $vidiunSessionUser, $url, $mediaType)
	{
		$params = array();
		$params["url"] = $url;
		$params["media_type"] = $mediaType;

		$result = $this->hit("searchfromurl", $vidiunSessionUser, $params);
		return $result;
	}

	public function searchMediaInfo(VidiunSessionUser $vidiunSessionUser)
	{
		$params = array();

		$result = $this->hit("searchmediainfo", $vidiunSessionUser, $params);
		return $result;
	}

	public function searchmediaproviders(VidiunSessionUser $vidiunSessionUser)
	{
		$params = array();

		$result = $this->hit("searchmediaproviders", $vidiunSessionUser, $params);
		return $result;
	}

	public function setMetaData(VidiunSessionUser $vidiunSessionUser, $entryId, $vshowId, $hasRoughCut, $xml)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$params["vshow_id"] = $vshowId;
		$params["HasRoughCut"] = $hasRoughCut;
		$params["xml"] = $xml;

		$result = $this->hit("setmetadata", $vidiunSessionUser, $params);
		return $result;
	}

	public function startSession(VidiunSessionUser $vidiunSessionUser, $secret, $admin = null, $privileges = null, $expiry = 86400)
	{
		$params = array();
		$params["secret"] = $secret;
		$this->addOptionalParam($params, "admin", $admin);
		$this->addOptionalParam($params, "privileges", $privileges);
		$this->addOptionalParam($params, "expiry", $expiry);

		$result = $this->hit("startsession", $vidiunSessionUser, $params);
		return $result;
	}

	public function startWidgetSession(VidiunSessionUser $vidiunSessionUser, $widgetId, $expiry = 86400)
	{
		$params = array();
		$params["widget_id"] = $widgetId;
		$this->addOptionalParam($params, "expiry", $expiry);

		$result = $this->hit("startwidgetsession", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateDvdEntry(VidiunSessionUser $vidiunSessionUser, $entryId, VidiunEntry $entry)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$this->addOptionalParam($params, "entry_name", $entry->name);
		$this->addOptionalParam($params, "entry_tags", $entry->tags);
		$this->addOptionalParam($params, "entry_type", $entry->type);
		$this->addOptionalParam($params, "entry_mediaType", $entry->mediaType);
		$this->addOptionalParam($params, "entry_source", $entry->source);
		$this->addOptionalParam($params, "entry_sourceId", $entry->sourceId);
		$this->addOptionalParam($params, "entry_sourceLink", $entry->sourceLink);
		$this->addOptionalParam($params, "entry_licenseType", $entry->licenseType);
		$this->addOptionalParam($params, "entry_credit", $entry->credit);
		$this->addOptionalParam($params, "entry_groupId", $entry->groupId);
		$this->addOptionalParam($params, "entry_partnerData", $entry->partnerData);
		$this->addOptionalParam($params, "entry_conversionQuality", $entry->conversionQuality);
		$this->addOptionalParam($params, "entry_permissions", $entry->permissions);
		$this->addOptionalParam($params, "entry_dataContent", $entry->dataContent);
		$this->addOptionalParam($params, "entry_desiredVersion", $entry->desiredVersion);
		$this->addOptionalParam($params, "entry_url", $entry->url);
		$this->addOptionalParam($params, "entry_thumbUrl", $entry->thumbUrl);
		$this->addOptionalParam($params, "entry_filename", $entry->filename);
		$this->addOptionalParam($params, "entry_realFilename", $entry->realFilename);
		$this->addOptionalParam($params, "entry_indexedCustomData1", $entry->indexedCustomData1);
		$this->addOptionalParam($params, "entry_thumbOffset", $entry->thumbOffset);

		$result = $this->hit("updatedvdentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateEntriesThumbnails(VidiunSessionUser $vidiunSessionUser, $entryIds, $timeOffset)
	{
		$params = array();
		$params["entry_ids"] = $entryIds;
		$params["time_offset"] = $timeOffset;

		$result = $this->hit("updateentriesthumbnails", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateEntry(VidiunSessionUser $vidiunSessionUser, $entryId, VidiunEntry $entry)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$this->addOptionalParam($params, "entry_name", $entry->name);
		$this->addOptionalParam($params, "entry_tags", $entry->tags);
		$this->addOptionalParam($params, "entry_type", $entry->type);
		$this->addOptionalParam($params, "entry_mediaType", $entry->mediaType);
		$this->addOptionalParam($params, "entry_source", $entry->source);
		$this->addOptionalParam($params, "entry_sourceId", $entry->sourceId);
		$this->addOptionalParam($params, "entry_sourceLink", $entry->sourceLink);
		$this->addOptionalParam($params, "entry_licenseType", $entry->licenseType);
		$this->addOptionalParam($params, "entry_credit", $entry->credit);
		$this->addOptionalParam($params, "entry_groupId", $entry->groupId);
		$this->addOptionalParam($params, "entry_partnerData", $entry->partnerData);
		$this->addOptionalParam($params, "entry_conversionQuality", $entry->conversionQuality);
		$this->addOptionalParam($params, "entry_permissions", $entry->permissions);
		$this->addOptionalParam($params, "entry_dataContent", $entry->dataContent);
		$this->addOptionalParam($params, "entry_desiredVersion", $entry->desiredVersion);
		$this->addOptionalParam($params, "entry_url", $entry->url);
		$this->addOptionalParam($params, "entry_thumbUrl", $entry->thumbUrl);
		$this->addOptionalParam($params, "entry_filename", $entry->filename);
		$this->addOptionalParam($params, "entry_realFilename", $entry->realFilename);
		$this->addOptionalParam($params, "entry_indexedCustomData1", $entry->indexedCustomData1);
		$this->addOptionalParam($params, "entry_thumbOffset", $entry->thumbOffset);

		$result = $this->hit("updateentry", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateEntryThumbnail(VidiunSessionUser $vidiunSessionUser, $entryId, $sourceEntryId = null, $timeOffset = null)
	{
		$params = array();
		$params["entry_id"] = $entryId;
		$this->addOptionalParam($params, "source_entry_id", $sourceEntryId);
		$this->addOptionalParam($params, "time_offset", $timeOffset);

		$result = $this->hit("updateentrythumbnail", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateEntryThumbnailJpeg(VidiunSessionUser $vidiunSessionUser, $entryId)
	{
		$params = array();
		$params["entry_id"] = $entryId;

		$result = $this->hit("updateentrythumbnailjpeg", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateVShow(VidiunSessionUser $vidiunSessionUser, $vshowId, VidiunVShow $vshow, $detailed = null, $allowDuplicateNames = null)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "vshow_name", $vshow->name);
		$this->addOptionalParam($params, "vshow_description", $vshow->description);
		$this->addOptionalParam($params, "vshow_tags", $vshow->tags);
		$this->addOptionalParam($params, "vshow_indexedCustomData3", $vshow->indexedCustomData3);
		$this->addOptionalParam($params, "vshow_groupId", $vshow->groupId);
		$this->addOptionalParam($params, "vshow_permissions", $vshow->permissions);
		$this->addOptionalParam($params, "vshow_partnerData", $vshow->partnerData);
		$this->addOptionalParam($params, "vshow_allowQuickEdit", $vshow->allowQuickEdit);
		$this->addOptionalParam($params, "detailed", $detailed);
		$this->addOptionalParam($params, "allow_duplicate_names", $allowDuplicateNames);

		$result = $this->hit("updatevshow", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateVshowOwner(VidiunSessionUser $vidiunSessionUser, $vshowId, $detailed = null)
	{
		$params = array();
		$params["vshow_id"] = $vshowId;
		$this->addOptionalParam($params, "detailed", $detailed);

		$result = $this->hit("updatevshowowner", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateNotification(VidiunSessionUser $vidiunSessionUser, VidiunNotification $notification)
	{
		$params = array();
		$this->addOptionalParam($params, "notification_id", $notification->id);
		$this->addOptionalParam($params, "notification_status", $notification->status);
		$this->addOptionalParam($params, "notification_notificationResult", $notification->notificationResult);

		$result = $this->hit("updatenotification", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateUser(VidiunSessionUser $vidiunSessionUser, $userId, VidiunUser $user)
	{
		$params = array();
		$params["user_id"] = $userId;
		$this->addOptionalParam($params, "user_screenName", $user->screenName);
		$this->addOptionalParam($params, "user_fullName", $user->fullName);
		$this->addOptionalParam($params, "user_email", $user->email);
		$this->addOptionalParam($params, "user_dateOfBirth", $user->dateOfBirth);
		$this->addOptionalParam($params, "user_aboutMe", $user->aboutMe);
		$this->addOptionalParam($params, "user_tags", $user->tags);
		$this->addOptionalParam($params, "user_gender", $user->gender);
		$this->addOptionalParam($params, "user_country", $user->country);
		$this->addOptionalParam($params, "user_state", $user->state);
		$this->addOptionalParam($params, "user_city", $user->city);
		$this->addOptionalParam($params, "user_zip", $user->zip);
		$this->addOptionalParam($params, "user_urlList", $user->urlList);
		$this->addOptionalParam($params, "user_networkHighschool", $user->networkHighschool);
		$this->addOptionalParam($params, "user_networkCollege", $user->networkCollege);
		$this->addOptionalParam($params, "user_partnerData", $user->partnerData);

		$result = $this->hit("updateuser", $vidiunSessionUser, $params);
		return $result;
	}

	public function updateUserId(VidiunSessionUser $vidiunSessionUser, $userId, $newUserId)
	{
		$params = array();
		$params["user_id"] = $userId;
		$params["new_user_id"] = $newUserId;

		$result = $this->hit("updateuserid", $vidiunSessionUser, $params);
		return $result;
	}

	public function upload(VidiunSessionUser $vidiunSessionUser, $filename)
	{
		$params = array();
		$params["filename"] = $filename;

		$result = $this->hit("upload", $vidiunSessionUser, $params);
		return $result;
	}

	public function uploadJpeg(VidiunSessionUser $vidiunSessionUser, $filename, $hash)
	{
		$params = array();
		$params["filename"] = $filename;
		$params["hash"] = $hash;

		$result = $this->hit("uploadjpeg", $vidiunSessionUser, $params);
		return $result;
	}

	public function viewWidget(VidiunSessionUser $vidiunSessionUser, $entryId = null, $vshowId = null, $widgetId = null, $host = null)
	{
		$params = array();
		$this->addOptionalParam($params, "entry_id", $entryId);
		$this->addOptionalParam($params, "vshow_id", $vshowId);
		$this->addOptionalParam($params, "widget_id", $widgetId);
		$this->addOptionalParam($params, "host", $host);

		$result = $this->hit("viewwidget", $vidiunSessionUser, $params);
		return $result;
	}

}
?>
