import json
import os
import boto3
from decimal import Decimal
from typing import List, Dict, Any
import math

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['FOOD_TRUCKS_TABLE'])

def lambda_handler(event, context):
    """
    Get food trucks within a certain distance of a location
    Query params: latitude, longitude, distance (in miles)
    Uses geohash-based querying for better performance
    """
    try:
        params = event.get('queryStringParameters', {})
        
        if not params or 'latitude' not in params or 'longitude' not in params:
            return error_response(400, 'Missing required parameters: latitude, longitude')
        
        user_lat = float(params['latitude'])
        user_lon = float(params['longitude'])
        max_distance = float(params.get('distance', 10))  # Default 10 miles
        
        # Get nearby geohashes to query
        geohashes = get_nearby_geohashes(user_lat, user_lon, max_distance)
        
        print(f"Searching {len(geohashes)} geohash buckets for trucks within {max_distance} miles")
        
        # Query food trucks from nearby geohash buckets
        food_trucks = []
        seen_ids = set()
        
        for geohash in geohashes:
            try:
                response = table.query(
                    IndexName='GeoHashIndex',
                    KeyConditionExpression='geoHash = :gh',
                    ExpressionAttributeValues={':gh': geohash}
                )
                
                for item in response.get('Items', []):
                    # Avoid duplicates (trucks can appear in multiple buckets)
                    if item['id'] not in seen_ids:
                        food_trucks.append(item)
                        seen_ids.add(item['id'])
                        
            except Exception as e:
                print(f"Error querying geohash {geohash}: {str(e)}")
                continue
        
        print(f"Found {len(food_trucks)} trucks in geohash buckets")
        
        # Filter by actual distance and transform to list items
        nearby_trucks = []
        for truck in food_trucks:
            truck_lat = float(truck['location']['latitude'])
            truck_lon = float(truck['location']['longitude'])
            
            distance = calculate_distance(user_lat, user_lon, truck_lat, truck_lon)
            
            if distance <= max_distance:
                nearby_trucks.append({
                    'id': truck['id'],
                    'name': truck['name'],
                    'description': truck['description'],
                    'distanceInMiles': round(distance, 2),
                    'latitude': truck_lat,
                    'longitude': truck_lon,
                    'imageUrl': truck.get('imageUrl'),
                    'cuisineType': truck.get('cuisineType')
                })
        
        # Sort by distance
        nearby_trucks.sort(key=lambda x: x['distanceInMiles'])
        
        print(f"Returning {len(nearby_trucks)} trucks within {max_distance} miles")
        
        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps(nearby_trucks, cls=DecimalEncoder)
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, f'Internal server error: {str(e)}')


def calculate_geohash(lat: float, lon: float, precision: int = 3) -> str:
    """
    Calculate geohash for a location
    Precision 3 = ~12.5 miles x 12.5 miles grid (good for city-level searches)
    """
    lat_grid = int((lat + 90) * (10 ** precision) / 180)
    lon_grid = int((lon + 180) * (10 ** precision) / 360)
    return f"{lat_grid}_{lon_grid}"


def get_nearby_geohashes(lat: float, lon: float, radius_miles: float, precision: int = 3) -> List[str]:
    """
    Get all geohash buckets that could contain points within radius
    
    For precision 3:
    - We divide the 180° latitude range into 10^3 = 1000 cells
    - Each cell represents 180/1000 = 0.18 degrees
    - At latitude 36°: 0.18° ≈ 12.5 miles
    
    This is a good balance for city-level searches
    """
    # At precision 3, each cell is approximately 12.5 miles
    miles_per_cell = 12.5
    cells_to_check = int(math.ceil(radius_miles / miles_per_cell)) + 1  # Add buffer
    
    # Get center geohash
    center_lat_grid = int((lat + 90) * (10 ** precision) / 180)
    center_lon_grid = int((lon + 180) * (10 ** precision) / 360)
    
    print(f"Center geohash: {center_lat_grid}_{center_lon_grid}")
    print(f"Checking {cells_to_check} cells in each direction")
    
    # Generate all nearby geohashes
    geohashes = []
    for lat_offset in range(-cells_to_check, cells_to_check + 1):
        for lon_offset in range(-cells_to_check, cells_to_check + 1):
            lat_grid = center_lat_grid + lat_offset
            lon_grid = center_lon_grid + lon_offset
            geohashes.append(f"{lat_grid}_{lon_grid}")
    
    return geohashes


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate distance between two coordinates using Haversine formula
    Returns distance in miles
    """
    R = 3959  # Earth's radius in miles
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = (math.sin(delta_lat / 2) ** 2 +
         math.cos(lat1_rad) * math.cos(lat2_rad) *
         math.sin(delta_lon / 2) ** 2)
    
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c


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
