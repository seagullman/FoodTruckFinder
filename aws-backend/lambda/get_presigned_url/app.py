import json
import os
import boto3
import uuid
from urllib.parse import urlparse

s3_client = boto3.client('s3')
bucket_name = os.environ['IMAGES_BUCKET']

def lambda_handler(event, context):
    """
    Generate presigned URL for uploading images to S3
    Requires authentication
    """
    try:
        user_id = event['requestContext']['authorizer']['claims']['sub']
        body = json.loads(event['body'])
        
        file_name = body.get('fileName')
        content_type = body.get('contentType', 'image/jpeg')
        
        if not file_name:
            return error_response(400, 'fileName is required')
        
        # Validate content type
        allowed_types = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp']
        if content_type not in allowed_types:
            return error_response(400, f'Content type must be one of: {", ".join(allowed_types)}')
        
        # Generate unique file key
        file_extension = file_name.split('.')[-1]
        unique_key = f"food-trucks/{user_id}/{uuid.uuid4()}.{file_extension}"
        
        # Generate presigned URL for PUT operation
        presigned_url = s3_client.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': bucket_name,
                'Key': unique_key,
                'ContentType': content_type
            },
            ExpiresIn=3600  # URL valid for 1 hour
        )
        
        # Generate the public URL for the uploaded file
        public_url = f"https://{bucket_name}.s3.amazonaws.com/{unique_key}"
        
        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps({
                'uploadUrl': presigned_url,
                'imageUrl': public_url,
                'key': unique_key
            })
        }
        
    except json.JSONDecodeError:
        return error_response(400, 'Invalid JSON in request body')
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, f'Internal server error: {str(e)}')


def cors_headers():
    return {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    }


def error_response(status_code: int, message: str):
    return {
        'statusCode': status_code,
        'headers': cors_headers(),
        'body': json.dumps({'error': message})
    }
