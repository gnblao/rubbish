use test
set names 'utf8';

CREATE TABLE `test` (
  `appid` int(32) unsigned NOT NULL,
  `third_appId` int(32) unsigned NOT NULL,
  `appsecret` char(255),
  `msgid` char(255),
  `type` int(4) unsigned  NOT NULL, 
  `ctime` int(32),
  `req_id` char(255) NOT NULL,
  `interval_count` int(16) unsigned,
  `uuid_list` text,
  `delivered` int(32) unsigned,
  `resolved`  int(32) unsigned,
  `click` int(32) unsigned,
  `tag` int(1) unsigned,
  PRIMARY KEY (`AppId`,`msgid`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

