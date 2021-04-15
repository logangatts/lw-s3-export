import json
import urllib.parse
import os
import datetime
import boto3
from laceworksdk import LaceworkClient
print('Loading function')
s3 = boto3.client('s3')
def s3_export(event, context):
    # Use enviroment variables to instantiate a LaceworkClient instance
    lacework_client = LaceworkClient(api_key=os.getenv('lw_api_key'),
                                     api_secret=os.getenv('lw_api_secret'),
                                     account=os.getenv('lw_acct'))
    #Set compliance report name with current date/time
    key = f'Lacework Compliance Report - {str(datetime.datetime.now())} UTC.pdf'

    #Grab lacework compliance report - use the AWS Account ID of the account the report is being run against in Lacework
    ACCOUNT_ID = os.getenv('aws_account_id')
    pdf_path = f'/tmp/{key}'
    lacework_client.compliance.get_latest_aws_report(ACCOUNT_ID, file_format="pdf", pdf_path=pdf_path)

    # Grab bucket name and attempt to upload the pdf to the s3 bucket
    bucket = os.environ['bucket']
    try:
        response = s3.put_object(Bucket=bucket, Key=key, Body=open(pdf_path, 'rb'))
        print(response)
        return response
    except Exception as e:
        print(e)
        print('Error putting object {} from bucket {}. Make sure your bucket is in the same region as this function.'.format(key, bucket))
        raise e
