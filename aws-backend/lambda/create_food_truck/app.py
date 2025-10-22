import json
import os
import boto3
import uuid
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['FOOD_TRUCKS_TABLE'])

def lambda_handler(event, context):
    """
    Create a new food truck
    Requires authentication
    """
    try:
        # Get user from Cognito authorizer
        user_id = event['requestContext']['authorizer']['claims']['sub']
        
        body = json.loads(event['body'])
        
        # Validate required fields
        required_fields = ['name', 'description', 'location', 'cuisineType']
        for field in required_fields:
            if field not in body:
                return error_response(400, f'Missing required field: {field}')
        
        # Generate unique ID
        truck_id = str(uuid.uuid4())
        
        # Create food truck item
        item = {
            'id': truck_id,
            'ownerId': user_id,
            'name': body['name'],
            'description': body['description'],
            'websiteUrl': body.get('websiteUrl', ''),
            'cuisineType': body['cuisineType'],
            'location': {
                'description': body['location']['description'],
                'latitude': Decimal(str(body['location']['latitude'])),
                'longitude': Decimal(str(body['location']['longitude']))
            },
            'imageUrl': body.get('imageUrl'),
            'openUntil': body.get('openUntil'),
            'menu': body.get('menu', []),
            'createdAt': context.aws_request_id,
            'updatedAt': context.aws_request_id
        }
        
        # Calculate geohash for location-based queries
        item['geoHash'] = calculate_geohash(
            float(body['location']['latitude']),
            float(body['location']['longitude'])
        )
        
        table.put_item(Item=item)
        
        return {
            'statusCode': 201,
            'headers': cors_headers(),
            'body': json.dumps({
                'id': truck_id,
                'message': 'Food truck created successfully'
            })
        }
        
    except json.JSONDecodeError:
        return error_response(400, 'Invalid JSON in request body')
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, f'Internal server error: {str(e)}')


def calculate_geohash(lat: float, lon: float, precision: int = 5) -> str:
    """
    Simple geohash implementation for location indexing
    For production, use a proper geohashing library
    """
    # This is a simplified version - use a proper library like pygeohash
    lat_grid = int((lat + 90) * (10 ** precision) / 180)
    lon_grid = int((lon + 180) * (10 ** precision) / 360)
    return f"{lat_grid}_{lon_grid}"


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
