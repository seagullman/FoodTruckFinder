import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['FOOD_TRUCKS_TABLE'])

def lambda_handler(event, context):
    """
    Get detailed food truck information by ID
    """
    try:
        truck_id = event['pathParameters']['id']
        
        response = table.get_item(Key={'id': truck_id})
        
        if 'Item' not in response:
            return error_response(404, 'Food truck not found')
        
        truck = response['Item']
        
        # Transform to match iOS model
        food_truck = {
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
