# TDD -> Write the Test Code Before develop acutual code.
# Tests are simulated independently.
# Function: if the function/error works for (1) Bucket  Creation (+ Failure) 
#                                           (2) Files   Upload   (+ Failure)


import boto3
from botocore.exceptions import ClientError
from s3_automation import bucket_create,bucket_upload_obj
import os
import unittest
from unittest.mock import patch
from moto import mock_s3        # moto helps admin to test AWS Services.

class TestS3Automation(unittest.Testcase):

    @mock_s3            #   Common Variables to be used for test
    def setUp(self):
        self.region_tag = 'eu-west-3'
        self.s3 = boto3.client('s3')
        self.bucket_tag = 'soo-dynamicweb-bucket'
        self.db_file_path = os.path.join("static_web_files","shopwise_db.sql")
        self.static_web_zip_path = os.path.join("static_web_files","shopwise.zip")
        self.s3_resource = boto3.resource('s3')

    @mock_s3
    def tearDown(self):
        bucket = self.s3_resource.Bucket(self.bucket_tag)
        for obj in bucket.objects.all():    # bucket.objects.all() --- return --->
            obj.delete()                            # ---> list(ObjectSummary)
        bucket.delete()
    
    #TDD[1]: If the Bucket is created?
    @mock_s3
    def test_bucket_create_success(self):
        bucket_create(self.s3,self.bucket_tag,self.region_tag)
        response = self.s3.list_buckets()
        self.assertIn(self.bucket_tag,[bucket['Name']for bucket in response['Buckets']])



    #TDD[2]: If the bucket already exists, the Exception will be worked?
    @mock_s3
    def test_bucket_create_failure(self):
        # Scenario: After the Bucket Creation, 
        #               Trying to create the same Bucket. 
        self.s3.create_bucket(Bucket=self.bucket_tag,
                              CreateBucketConfiguration={
                                  'LocationConstraint': self.region_tag})
        with self.assertRaises(ClientError):
            bucket_create(self.s3,self.bucket_tag,self.region_tag)


    #TDD[3]: I will upload TWO essential Objects[ZIP file, sql file]
            # So, How many times to call this "upload_file()"? 
    @mock_s3
    def test_bucket_upload_obj_success(self):

        self.s3.create_bucket(Bucket=self.bucket_tag,
                              CreateBucketConfiguration={
                                  'LocationConstraint': self.region_tag})
        
        with patch("boto3.s3.transfer.S3Transfer.upload_file") as mock_upload:
            bucket_upload_obj(self.s3,self.db_file_path,self.static_web_zip_path,self.bucket_tag)
            self.assertEqual(mock_upload.call_count,2)

    
if __name__ == '__main__':
    unittest.main()        