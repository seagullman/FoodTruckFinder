import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['FOOD_TRUCKS_TABLE'])

def lambda_handler(event, context):
    """
    Get the food truck owned by the authenticated user
    """
    try:
        user_id = event['requestContext']['authorizer']['claims']['sub']
        
        # Try to query by ownerId using GSI, fallback to scan if index not ready
        try:
            response = table.query(
                IndexName='OwnerIdIndex',
                KeyConditionExpression='ownerId = :ownerId',
                ExpressionAttributeValues={':ownerId': user_id}
            )
        except Exception as e:
            # If GSI is not ready, fall back to scan
            print(f"GSI query failed, falling back to scan: {str(e)}")
            response = table.scan(
                FilterExpression='ownerId = :ownerId',
                ExpressionAttributeValues={':ownerId': user_id}
            )
        
        if not response['Items']:
            return error_response(404, 'No food truck found for this owner')
        
        # Return the first truck (assuming one truck per owner for now)
        truck = response['Items'][0]
        
        # Transform to match iOS model
        food_truck = {
            'id': truck['id'],
            'name': truck['name'],
            'description': truck['description'],
            'websiteUrl': truck.get('websiteUrl', ''),
            'cuisineType': truck.get('cuisineType', 'other'),
            'location': {
                'description': truck['location']['description'],
                'latitude': float(truck['location']['latitude']),
                'longitude': float(truck['location']['longitude'])
            },
            'imageUrl': truck.get('imageUrl'),
            'openUntil': truck.get('openUntil'),
            'menu': truck.get('menu', [])
        }
        
        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps(food_truck, cls=DecimalEncoder)
        }
        
    except KeyError as e:
        return error_response(400, f'Missing required parameter: {str(e)}')
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


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)
