#!/usr/bin/env python3
"""
Import exported Firebase data to DynamoDB
Usage: python3 import-dynamodb.py [environment] [json-file]
"""

import sys
import json
import boto3
from decimal import Decimal

def convert_to_decimal(obj):
    """Convert floats to Decimal for DynamoDB"""
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_to_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_to_decimal(item) for item in obj]
    return obj

def calculate_geohash(lat, lon, precision=5):
    """Calculate simple geohash for location indexing"""
    lat_grid = int((lat + 90) * (10 ** precision) / 180)
    lon_grid = int((lon + 180) * (10 ** precision) / 360)
    return f"{lat_grid}_{lon_grid}"

def import_food_trucks(environment='dev', json_file='food-trucks-export.json'):
    """Import food trucks from JSON to DynamoDB"""
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(f'FoodTrucks-{environment}')
    
    print(f'📦 Importing food trucks from {json_file} to {environment}...')
    
    try:
        with open(json_file, 'r') as f:
            trucks = json.load(f)
    except FileNotFoundError:
        print(f'❌ File not found: {json_file}')
        print('Run export-firebase.js first to export data from Firebase')
        sys.exit(1)
    
    success_count = 0
    error_count = 0
    
    for truck in trucks:
        try:
            # Transform to match DynamoDB schema
            item = {
                'id': truck['id'],
                'name': truck['name'],
                'description': truck['description'],
                'cuisineType': truck.get('cuisineType', 'other'),
                'location': {
                    'description': truck['location']['description'],
                    'latitude': truck['location']['latitude'],
                    'longitude': truck['location']['longitude']
                },
                'imageUrl': truck.get('imageUrl'),
                'websiteUrl': truck.get('websiteUrl', ''),
                'openUntil': truck.get('openUntil'),
                'menu': truck.get('menu', []),
                'ownerId': truck.get('ownerId', 'migrated'),
                'createdAt': truck.get('createdAt', ''),
                'updatedAt': truck.get('updatedAt', '')
            }
            
            # Calculate geohash
            item['geoHash'] = calculate_geohash(
                float(truck['location']['latitude']),
                float(truck['location']['longitude'])
            )
            
            # Convert floats to Decimal
            item = convert_to_decimal(item)
            
            # Put item in DynamoDB
            table.put_item(Item=item)
            
            print(f"✅ Imported: {truck['name']}")
            success_count += 1
            
        except Exception as e:
            print(f"❌ Failed to import {truck.get('name', 'Unknown')}: {str(e)}")
            error_count += 1
    
    print(f'\n✅ Import complete!')
    print(f'   Successful: {success_count}')
    print(f'   Failed: {error_count}')
    print(f'   Total: {len(trucks)}')

if __name__ == '__main__':
    environment = sys.argv[1] if len(sys.argv) > 1 else 'dev'
    json_file = sys.argv[2] if len(sys.argv) > 2 else 'food-trucks-export.json'
    
    import_food_trucks(environment, json_file)
