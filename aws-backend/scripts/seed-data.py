#!/usr/bin/env python3
"""
Seed DynamoDB with sample food truck data
Usage: python3 seed-data.py [environment]
"""

import sys
import boto3
from decimal import Decimal
import uuid

def calculate_geohash(lat, lon, precision=3):
    """Calculate simple geohash for location indexing"""
    lat_grid = int((lat + 90) * (10 ** precision) / 180)
    lon_grid = int((lon + 180) * (10 ** precision) / 360)
    return f"{lat_grid}_{lon_grid}"

def seed_food_trucks(environment='dev'):
    """Seed sample food trucks into DynamoDB"""
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(f'FoodTrucks-{environment}')
    
    sample_trucks = [
        {
            'id': str(uuid.uuid4()),
            'name': 'Smoky Mountain Tacos',
            'description': 'Authentic Mexican street tacos with fresh ingredients',
            'cuisineType': 'mexican',
            'location': {
                'description': 'Market Square, Knoxville, TN',
                'latitude': Decimal('35.9606'),
                'longitude': Decimal('-83.9207')
            },
            'websiteUrl': 'https://smokymountaintacos.com',
            'imageUrl': 'https://example.com/taco-truck.jpg',
            'openUntil': '10:00 PM',
            'menu': [
                {
                    'category': 'Tacos',
                    'items': [
                        {
                            'name': 'Carne Asada Taco',
                            'description': 'Grilled steak with onions and cilantro',
                            'price': Decimal('3.50'),
                            'isVegetarian': False,
                            'isGlutenFree': True
                        },
                        {
                            'name': 'Fish Taco',
                            'description': 'Battered fish with cabbage slaw',
                            'price': Decimal('4.00'),
                            'isVegetarian': False,
                            'isGlutenFree': False
                        }
                    ]
                }
            ],
            'ownerId': 'seed-user',
            'geoHash': calculate_geohash(35.9606, -83.9207),
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z'
        },
        {
            'id': str(uuid.uuid4()),
            'name': 'Vol Burger',
            'description': 'Gourmet burgers made with locally sourced Tennessee beef',
            'cuisineType': 'american',
            'location': {
                'description': 'University of Tennessee, Knoxville, TN',
                'latitude': Decimal('35.9544'),
                'longitude': Decimal('-83.9295')
            },
            'websiteUrl': 'https://volburger.com',
            'imageUrl': 'https://example.com/burger-truck.jpg',
            'openUntil': '9:00 PM',
            'menu': [
                {
                    'category': 'Burgers',
                    'items': [
                        {
                            'name': 'Classic Cheeseburger',
                            'description': 'Angus beef with cheddar cheese',
                            'price': Decimal('8.99'),
                            'isVegetarian': False,
                            'isGlutenFree': False
                        },
                        {
                            'name': 'Veggie Burger',
                            'description': 'House-made black bean patty',
                            'price': Decimal('7.99'),
                            'isVegetarian': True,
                            'isGlutenFree': False
                        }
                    ]
                }
            ],
            'ownerId': 'seed-user',
            'geoHash': calculate_geohash(35.9544, -83.9295),
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z'
        },
        {
            'id': str(uuid.uuid4()),
            'name': 'Tennessee Sushi',
            'description': 'Fresh sushi and Japanese cuisine',
            'cuisineType': 'japanese',
            'location': {
                'description': 'Downtown Knoxville, TN',
                'latitude': Decimal('35.9640'),
                'longitude': Decimal('-83.9186')
            },
            'websiteUrl': 'https://tennesseesushi.com',
            'imageUrl': 'https://example.com/sushi-truck.jpg',
            'openUntil': '8:00 PM',
            'menu': [
                {
                    'category': 'Rolls',
                    'items': [
                        {
                            'name': 'California Roll',
                            'description': 'Crab, avocado, cucumber',
                            'price': Decimal('6.99'),
                            'isVegetarian': False,
                            'isGlutenFree': True
                        },
                        {
                            'name': 'Spicy Tuna Roll',
                            'description': 'Tuna with spicy mayo',
                            'price': Decimal('7.99'),
                            'isVegetarian': False,
                            'isGlutenFree': True
                        }
                    ]
                }
            ],
            'ownerId': 'seed-user',
            'geoHash': calculate_geohash(35.9640, -83.9186),
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z'
        },
        {
            'id': str(uuid.uuid4()),
            'name': 'Knoxville Pizza Co',
            'description': 'Wood-fired pizzas with artisan toppings',
            'cuisineType': 'italian',
            'location': {
                'description': 'Old City, Knoxville, TN',
                'latitude': Decimal('35.9676'),
                'longitude': Decimal('-83.9143')
            },
            'websiteUrl': 'https://knoxvillepizza.com',
            'imageUrl': 'https://example.com/pizza-truck.jpg',
            'openUntil': '11:00 PM',
            'menu': [
                {
                    'category': 'Pizzas',
                    'items': [
                        {
                            'name': 'Margherita',
                            'description': 'Fresh mozzarella, basil, tomato',
                            'price': Decimal('12.99'),
                            'isVegetarian': True,
                            'isGlutenFree': False
                        },
                        {
                            'name': 'Pepperoni',
                            'description': 'Classic pepperoni pizza',
                            'price': Decimal('13.99'),
                            'isVegetarian': False,
                            'isGlutenFree': False
                        }
                    ]
                }
            ],
            'ownerId': 'seed-user',
            'geoHash': calculate_geohash(35.9676, -83.9143),
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z'
        },
        {
            'id': str(uuid.uuid4()),
            'name': 'Thai Volunteer',
            'description': 'Authentic Thai dishes with bold flavors',
            'cuisineType': 'asian',
            'location': {
                'description': 'West Knoxville, TN',
                'latitude': Decimal('35.9500'),
                'longitude': Decimal('-84.0500')
            },
            'websiteUrl': 'https://thaivolunteer.com',
            'imageUrl': 'https://example.com/thai-truck.jpg',
            'openUntil': '9:30 PM',
            'menu': [
                {
                    'category': 'Noodles',
                    'items': [
                        {
                            'name': 'Pad Thai',
                            'description': 'Stir-fried rice noodles',
                            'price': Decimal('9.99'),
                            'isVegetarian': False,
                            'isGlutenFree': True
                        },
                        {
                            'name': 'Drunken Noodles',
                            'description': 'Spicy wide rice noodles',
                            'price': Decimal('10.99'),
                            'isVegetarian': False,
                            'isGlutenFree': True
                        }
                    ]
                }
            ],
            'ownerId': 'seed-user',
            'geoHash': calculate_geohash(35.9500, -84.0500),
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z'
        }
    ]
    
    print(f"Seeding {len(sample_trucks)} food trucks to {environment} environment...")
    
    for truck in sample_trucks:
        try:
            table.put_item(Item=truck)
            print(f"✅ Added: {truck['name']}")
        except Exception as e:
            print(f"❌ Failed to add {truck['name']}: {str(e)}")
    
    print(f"\n✅ Seeding complete! Added {len(sample_trucks)} food trucks.")

if __name__ == '__main__':
    environment = sys.argv[1] if len(sys.argv) > 1 else 'dev'
    seed_food_trucks(environment)
