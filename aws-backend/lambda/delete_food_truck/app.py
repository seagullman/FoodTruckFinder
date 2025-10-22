import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['FOOD_TRUCKS_TABLE'])

def lambda_handler(event, context):
    """
    Delete a food truck
    Requires authentication and ownership
    """
    try:
        user_id = event['requestContext']['authorizer']['claims']['sub']
        truck_id = event['pathParameters']['id']
        
        # Check if food truck exists and user owns it
        response = table.get_item(Key={'id': truck_id})
        
        if 'Item' not in response:
            return error_response(404, 'Food truck not found')
        
        existing_truck = response['Item']
        
        if existing_truck.get('ownerId') != user_id:
            return error_response(403, 'You do not have permission to delete this food truck')
        
        # Delete the food truck
        table.delete_item(Key={'id': truck_id})
        
        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps({'message': 'Food truck deleted successfully'})
        }
        
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
