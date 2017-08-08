#!/usr/bin/env python
#-*- coding:utf8 -*-

import logging
import logging.handlers

LOG_FILE = './test.log'
handler = logging.handlers.RotatingFileHandler(LOG_FILE, maxBytes = 1024*1024, backupCount = 5) # 实例化handler
fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(message)s' 
formatter = logging.Formatter(fmt)   # 实例化formatter
handler.setFormatter(formatter)      # 为handler添加formatter


logger = logging.getLogger('test')
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

import sqlalchemy


class MySQLClient:
	def __init__(self, host, database, user, password, port=3306, charset='utf8', autocommit=True):
		self.host = host
		self.port = port
		self.database = database
		self.user = user
		self.password = password
		self.charset = charset
		self.connection = None
		self.autocommit = autocommit

		self.connection = None
		self.engine = None

	def __del__(self):
		if self.connection is not None:
			try:
				self.connection.close()
			except Exception, e:
				logger.error("in MySQLOP __del__ exception:%s" % e)
	
	def close(self):
		if self.connection is not None:
			try:
				self.connection.close()
			except Exception, e:
				logger.error("in MySQLOP __del__ exception:%s" % e)

	def connect(self):
		if self.connection is None:
			connectionURL = 'mysql://{user}:{passwd}@{host}:{port}/{db}?local_infile=1'.format(
					user=self.user,
					passwd=self.password,
					host=self.host,
					port=self.port,
					db=self.database,
				)
			logger.info('MySQLClient connectionURL:%s' % connectionURL)
			self.engine = sqlalchemy.create_engine(connectionURL, encoding=self.charset, echo=False)
			self.connection = self.engine.connect()

	
	def executeSQL(self, sql):
		if self.connection is None:
			self.connect()

		tran = self.connection.begin()
		try:
			self.connection.execute(sql)
			tran.commit()
			logger.info('MySQLClient executeSQL:### %s ###, return True' % sql)
			return True
		except Exception, e:
			logger.error('MySQLClient executeSQL exception:%s' % e)
			tran.rollback()
			logger.info('MySQLClient executeSQL:### %s ###, return False' % sql)
			return False


	def getSQLResult(self, sql):
		if self.connection is None:
			self.connect()

		try:
			ret = self.connection.execute(sql)
			logger.info('MySQLClient getSQLResult:### %s ###, no error' % sql)
			return ret
		except Exception, e:
			logger.error('MySQLClient getSQLResult:### %s ###, exception:%s' % (sql, e))
			raise e


	
	def isTableExists(self, table):
		if self.connection is None:
			self.connect()
		
		try:
			result = self.connection.execute("SHOW TABLES LIKE '{}'".format(table))
			row = result.fetchone()
			return row is not None
		except Exception, e:
			logger.error("MySQLOP isTableExists exception:%s" % e)
			raise e
		





if __name__ == '__main__':
	pass
	#createTableSQL = '''
	#	CREATE TABLE IF NOT EXISTS `device_tmp` (
	#	    `appid`         INT(5),
	#	    `country`       INT(11),
	#	    `province`      INT(11),
	#	    `city`          INT(11),
	#	    `dv_id`         VARCHAR(50),
	#	    INDEX (`appid`, `country`, `province`, `city`),
	#	    INDEX (`appid`, `province`, `city`),
	#	    INDEX (`dv_id`)
	#	) ENGINE=innodb, CHARACTER SET=utf8;
	#	'''
	#mysqlClient = MySQLClient(host='10.10.9.186', port=5506, database='device_info', user='work', password='mojie2013')
	#print "%r" % mysqlClient.executeSQL( '''DROP TABLE device_tmp''' )
	#print "%r" % mysqlClient.executeSQL( createTableSQL )
	#print "%r" % mysqlClient.executeSQL('''LOAD DATA LOCAL INFILE "/home/work/env/LuigiWorker/deviceTQ/data/20140529/000000_0" INTO TABLE device_info.device_tmp FIELDS TERMINATED by " "''')

	#print mysqlClient.isTableExists('device_tmp')
	#print mysqlClient.isTableExists('device_tm')

	#engine = sqlalchemy.create_engine('mysql://work:mojie2013@10.10.9.186:5506/device_info?local_infile=1', encoding='utf8', echo=True)
	#con = engine.connect()

	#trans = con.begin()
	#con.execute(createTableSQL)
	#trans.commit()

	#trans = con.begin()
	#con.execute('''LOAD DATA LOCAL INFILE "/home/work/env/LuigiWorker/deviceTQ/data/20140529/000000_0" INTO TABLE device_info.device_tmp FIELDS TERMINATED by " "''')
	#trans.commit()

