import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['FOOD_TRUCKS_TABLE'])

def lambda_handler(event, context):
    """
    Update an existing food truck
    Requires authentication and ownership
    """
    try:
        user_id = event['requestContext']['authorizer']['claims']['sub']
        truck_id = event['pathParameters']['id']
        body = json.loads(event['body'])
        
        # Check if food truck exists and user owns it
        response = table.get_item(Key={'id': truck_id})
        
        if 'Item' not in response:
            return error_response(404, 'Food truck not found')
        
        existing_truck = response['Item']
        
        if existing_truck.get('ownerId') != user_id:
            return error_response(403, 'You do not have permission to update this food truck')
        
        # Build update expression
        update_expr = "SET updatedAt = :updated"
        expr_values = {':updated': context.aws_request_id}
        expr_names = {}
        
        # Update allowed fields
        allowed_fields = ['name', 'description', 'websiteUrl', 'cuisineType', 
                         'location', 'imageUrl', 'openUntil', 'menu']
        
        for field in allowed_fields:
            if field in body:
                if field == 'location':
                    update_expr += f", {field} = :location"
                    expr_values[':location'] = {
                        'description': body['location']['description'],
                        'latitude': Decimal(str(body['location']['latitude'])),
                        'longitude': Decimal(str(body['location']['longitude']))
                    }
                    # Update geohash if location changed
                    update_expr += ", geoHash = :geohash"
                    expr_values[':geohash'] = calculate_geohash(
                        float(body['location']['latitude']),
                        float(body['location']['longitude'])
                    )
                else:
                    update_expr += f", {field} = :{field}"
                    expr_values[f':{field}'] = body[field]
        
        table.update_item(
            Key={'id': truck_id},
            UpdateExpression=update_expr,
            ExpressionAttributeValues=expr_values
        )
        
        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps({'message': 'Food truck updated successfully'})
        }
        
    except json.JSONDecodeError:
        return error_response(400, 'Invalid JSON in request body')
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, f'Internal server error: {str(e)}')


def calculate_geohash(lat: float, lon: float, precision: int = 5) -> str:
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
