#!/usr/bin/python
#coding=utf-8

import redis
import mysqlUtil
import httplib2
import json
import time
import datetime
from urllib import urlencode

################mysql conf
MYSQL_HOST = '127.0.0.1'
MYSQL_PORT = 3306
MYSQL_DB = 'test'
MYSQL_USER = 'root'
MYSQL_PASSWD = '123456'

################redis conf
REDIS_HOST = '127.0.0.1'
REDIS_PORT = 6379

#####
MQ = 'android_thirdstat_queue'
################


def up_pushstat():
    nn=0
    f = open('up_pushstat.log','a')
    while True:
        f.write( '--------up_pushstat'+str(nn)+'---------'+'\n')
        nn +=1
        mysqlClient = mysqlUtil.MySQLClient(host=MYSQL_HOST, database=MYSQL_DB, user=MYSQL_USER, password=MYSQL_PASSWD, port=MYSQL_PORT)
        #interval_time = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime("%Y-%m-%d %H:%M:%S") #查询现在到三天前的内容
        now_time = int(time.time())  #查询现在到三天前的内容
        interval_time = now_time - 3*24*60*60  #查询现在到三天前的内容
        SelectSQL ='select appid,third_appid,msgid,type,appsecret,req_id,ctime,interval_count from test where ctime > '+str(interval_time)+ ' and tag = 0 ;'
        f.write( SelectSQL+'\n')
        result = mysqlClient.getSQLResult( SelectSQL )
        for data in result:
#            print(data)
            if len(data) != 8:
                continue
            mysqlClient1 = mysqlUtil.MySQLClient(host=MYSQL_HOST, database=MYSQL_DB, user=MYSQL_USER, password=MYSQL_PASSWD, port=MYSQL_PORT)
            h = httplib2.Http()
            UpdateTableSQL = ''
            resolved = 0
            delivered = 0
            click = 0
            tag = 0
            
#            if (data[6]+data[7]*5*60) > now_time and now_time > (data[6]+(data[7]+1)*5*60) :
            num = data[7]*(data[7]+1)/2  #1,2.....n,之和n(n+1)/2
#            print(num)
            if not (data[6] <= (now_time - num*5*60)) :
                continue

            if data[3] == 2:
                url = 'https://api.xmpush.xiaomi.com/v1/trace/message/status?msg_id='+ data[5]    #小米
                resp, content = h.request(url, "GET",headers={'Authorization':'key='+data[4]})
                f.write( '' + url + '  resp:' +str(resp)+content+'\n')
                content = eval(content)
                if not content.has_key("data") or content["data"] == '' :
                    continue
                resolved = content["data"]["data"]["resolved"]
                delivered = content["data"]["data"]["delivered"]
                click = content["data"]["data"]["click"]
                if resolved == delivered :
                    tag = 1

            elif data[3] == 3:
                lstr = 'grant_type=client_credentials&client_id='+str(data[1])+'&client_secret='+str(data[4])         #华为
                resp, content = h.request("https://login.vmall.com/oauth2/token","POST",lstr,headers={'Content-Type':'application/x-www-form-urlencoded'})
                f.write( 'https://login.vmall.com/oauth2/token  POST_data: '+lstr + '  rsp_data: '+str(resp)+content+'\n')
                content = eval(content)
                if not content.has_key("access_token") :
                    continue
                tmp = {}
                tmp["access_token"] = ''+content["access_token"]
                ss = urlencode(tmp)
                curtime = int(time.time())
                lstr = 'request_id='+data["req_id"]+'&nsp_svc=openpush.openapi.query_msg_result&nsp_fmt=JSON&nsp_ts='+str(curtime)+'&'+ss
                resp, content = h.request("https://api.vmall.com/rest.php","POST",lstr,headers={'Content-Type':'application/x-www-form-urlencoded'})
                f.write( 'https://api.vmall.com/rest.php POST_data: '+lstr+' rsp_data: '+content+'\n')
                content = json.loads(content)
                if type(content) == dict: #huawei TMD 返回的数据类型不一致
                    continue
                content = eval(content)
                if not content.has_key("result")  :
                    continue
                resolved = len(content["result"])
                click = 0
                delivered = 0
                for i in content["result"]:
                    if i["status"] == 0 or i["status"] == 2 or i["status"] == 3 :
                        delivered +=1
                if resolved == delivered :
                    tag = 1
            else :
                f.write( "NO msg_id "+data[5]+" xiaomi and huawei"+'\n')

            interval_count = data[7]+1
            UpdateTableSQL = 'update test set delivered = '+str(delivered)+',resolved = '+str(resolved)+',click = '+str(click)+',tag = '+str(tag)+', interval_count = '+str(interval_count)+' where  appid = ' + str(data[0]) + ' and msgid = "'+ str(data[2]) + '" and type = ' + str(data[3]) + ';'

#            else :
#                interval_count = data[7]+1
#
#                UpdateTableSQL = 'update test set interval_count = '+str(interval_count)+' where  appid = ' + str(data[0]) + ' and msgid = "'+ str(data[2]) + '" and type = ' + str(data[3]) + ';'
#

            f.write( UpdateTableSQL+'\n')
            if not mysqlClient1.executeSQL( UpdateTableSQL ):
                raise Exception("update into test.test exception!")
            mysqlClient1.close()

        mysqlClient.close()
        time.sleep(5)
        f.flush()
    f.close()

if __name__ == '__main__':  
#    redis2db() 
    up_pushstat()
#    test()

