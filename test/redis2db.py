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

def redis2db():
    red = redis.Redis(host=REDIS_HOST,port=REDIS_PORT)
    nn=0
    f = open('redis2db.log','a')
    while True:
        f.write( '--------'+str(nn)+'---------'+'\n')
        nn +=1
        list = red.zrange(MQ,0,-1)
        for i in list:
            data = eval(red.get(i))
            f.write( 'redis key :' +i+'\n')
            if len(data) < 6 :
                continue
            mysqlClient = mysqlUtil.MySQLClient(host=MYSQL_HOST, database=MYSQL_DB, user=MYSQL_USER, password=MYSQL_PASSWD, port=MYSQL_PORT)
            #ctime = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            ctime = int(time.time())
            uuid_list = ''.join(json.dumps(data["uuid_list"])).encode()
            
            h = httplib2.Http()
            InsertTableSQL = ''
            resolved = 0
            delivered = 0
            click = 0
            check = 0
            interval_count = 1

            if data["type"] == 2:
                url = 'https://api.xmpush.xiaomi.com/v1/trace/message/status?msg_id='+ data["req_id"]    #小米
                resp, content = h.request(url, "GET",headers={'Authorization':'key='+data["thirdinfo"]["appsecret"]})
                f.write( '' + url + '  resp:' +str(resp)+content+'\n')
                content = eval(content)
                if not content.has_key("data") or content["data"] == '' :
                    continue
                resolved = content["data"]["data"]["resolved"]
                delivered = content["data"]["data"]["delivered"]
                click = content["data"]["data"]["click"]
                if resolved == delivered :
                    check = 1

            elif data["type"] == 3:
                lstr = 'grant_type=client_credentials&client_id='+data["thirdinfo"]["appid"]+'&client_secret='+data["thirdinfo"]["appsecret"]         #华为
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
                    check = 1
            else :
                f.write( "NO msg_id "+data["msgid"]+" xiaomi and huawei"+'\n')

            InsertTableSQL = 'insert into test (appid,third_appid,appsecret,msgid,type,ctime,req_id,uuid_list,delivered,resolved,click,tag,interval_count) values("' + data["appid"] + '","' + data["thirdinfo"]["appid"] + '","' + data["thirdinfo"]["appsecret"] + '","' + str(data["msgid"]) + '",' + str(data["type"]) + ',"' + str(ctime) + '","' + str(data["req_id"]) + '",\'' + uuid_list + '\','+str(delivered)+','+str(resolved)+','+str(click)+','+str(check)+','+str(interval_count)+');'
            f.write( InsertTableSQL+'\n')
            if not mysqlClient.executeSQL( InsertTableSQL ):
                raise Exception("insert into test.test exception!")
            mysqlClient.close()
            red.zrem(MQ,i)
            red.delete(i)
        time.sleep(5)
        f.flush()    
    f.close()

if __name__ == '__main__':  
    redis2db() 
#    up_pushstat()
#    test()

