import logging
import os
import boto3
from botocore.exceptions import ClientError

if not os.path.exists('logs'):
    os.makedirs('logs')

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    handlers=[logging.StreamHandler(),
                              logging.FileHandler('logs/script_logs.log')])

logger = logging.getLogger('s3_automation')

def bucket_create(s3,bucket_tag,region_tag):
    
    work = "<< BUCKET CREATE >>"
    try:
        s3.create_bucket(Bucket=bucket_tag,
                        CreateBucketConfiguration={
                            'LocationConstraint': region_tag})
        
        
        waiter = s3.get_waiter('bucket_exists')
        waiter.wait(
        Bucket=bucket_tag,
        WaiterConfig={
            'Delay': 30,
            'MaxAttempts': 30
        })
        
        logger.info(f'[COMPLETE]-> {work} ')
        

    except ClientError as e:
        logger.error(f'[FAIL]-> {work}\t[CODE] -> {e}')
        raise    

def bucket_upload_obj(s3,db_file_path,static_web_zip_path,bucket_tag):

    work = "<< UPLOAD OBJ in BUCKET >>"
    try:

        upload_objs = [{db_file_path:"shopwise_db.sql"}]
        upload_objs.append({static_web_zip_path:"shopwise.zip"})
        for obj in upload_objs:
            for file,obj_key in obj.items():
                s3.upload_file(Filename=file,
                               Bucket=bucket_tag,
                               Key=obj_key)       
                
        logger.info(f'[COMPLETE]-> {work} ')

    except ClientError as e:
        logger.error(f'[FAIL]-> {work}\t[CODE] -> {e}')
        raise    

def main():
    
    s3 = boto3.client('s3')
    s3_resource = boto3.resource('s3')
    region_tag = 'eu-west-3'
    bucket_tag = "soo-dynamicweb-bucket"
    db_file_path = os.path.join("static_web_files","shopwise_db.sql")
    static_web_zip_path = os.path.join("static_web_files","shopwise.zip")


    try:
        logger.info(f'Target: S3 Bucket({bucket_tag})')

        logger.info('[Process]\tCreate Bucket --->')
        bucket_create(s3,bucket_tag,region_tag)
        bucket = s3_resource.Bucket(bucket_tag)
        logger.info(f'[Result]\tBucket[{bucket.name}] is created!')


        logger.info('[Process]\tUpload Bucket --->')
        bucket_upload_obj(s3,db_file_path,static_web_zip_path,bucket_tag)
        logger.info(f'[Result]\tUpload Objs in Bucket[{bucket.name}]')
        
        
    except ClientError as e:

        logger.error(f'[ERROR]: Unexpected Error Detected!\n[Code] -> {e}')
            

if __name__ =="__main__":
    main()