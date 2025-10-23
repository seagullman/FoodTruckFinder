#!/usr/bin/env python3
"""
Upload food truck images to S3 and update DynamoDB with URLs
Usage: python3 upload-images.py [environment]
"""

import sys
import boto3
import os
from pathlib import Path

def upload_images_to_s3(environment='dev'):
    """Upload sample food truck images to S3"""
    
    s3 = boto3.client('s3')
    dynamodb = boto3.resource('dynamodb')
    
    # Get bucket name
    bucket_name = f'foodtruckfinder-images-{environment}-867605436045'
    table = dynamodb.Table(f'FoodTrucks-{environment}')
    
    print(f'📦 Uploading images to S3 bucket: {bucket_name}')
    
    # Sample image URLs (you can replace these with actual images)
    # For now, we'll use placeholder image service
    image_mappings = {
        'Smoky Mountain Tacos': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
        'Vol Burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        'Tennessee Sushi': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
        'Knoxville Pizza Co': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        'Thai Volunteer': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400'
    }
    
    # Get all food trucks
    response = table.scan()
    trucks = response.get('Items', [])
    
    print(f'Found {len(trucks)} food trucks to update')
    
    for truck in trucks:
        truck_name = truck['name']
        truck_id = truck['id']
        
        if truck_name in image_mappings:
            image_url = image_mappings[truck_name]
            
            # Update DynamoDB with image URL
            table.update_item(
                Key={'id': truck_id},
                UpdateExpression='SET imageUrl = :url',
                ExpressionAttributeValues={':url': image_url}
            )
            
            print(f'✅ Updated {truck_name} with image URL')
        else:
            print(f'⚠️  No image mapping for {truck_name}')
    
    print('\n✅ Image upload complete!')
    print('\nNote: Currently using Unsplash placeholder images.')
    print('To use your own images:')
    print('1. Place images in aws-backend/images/ folder')
    print('2. Run this script to upload them to S3')
    print('3. Images will be accessible at: https://{bucket_name}.s3.amazonaws.com/food-trucks/{filename}')

def upload_local_images(environment='dev'):
    """Upload local images from images/ folder to S3"""
    
    s3 = boto3.client('s3')
    bucket_name = f'foodtruckfinder-images-{environment}-867605436045'
    
    images_dir = Path('images')
    if not images_dir.exists():
        print('⚠️  No images/ folder found. Creating one...')
        images_dir.mkdir()
        print('📁 Place your food truck images in aws-backend/scripts/images/')
        return
    
    image_files = list(images_dir.glob('*.jpg')) + list(images_dir.glob('*.png'))
    
    if not image_files:
        print('⚠️  No images found in images/ folder')
        return
    
    print(f'📤 Uploading {len(image_files)} images to S3...')
    
    for image_file in image_files:
        key = f'food-trucks/{image_file.name}'
        
        with open(image_file, 'rb') as f:
            s3.put_object(
                Bucket=bucket_name,
                Key=key,
                Body=f,
                ContentType='image/jpeg' if image_file.suffix == '.jpg' else 'image/png',
                ACL='public-read'
            )
        
        url = f'https://{bucket_name}.s3.amazonaws.com/{key}'
        print(f'✅ Uploaded: {image_file.name} -> {url}')

if __name__ == '__main__':
    environment = sys.argv[1] if len(sys.argv) > 1 else 'dev'
    
    print('🖼️  Food Truck Image Uploader')
    print('=' * 50)
    
    # First, try to upload local images if they exist
    upload_local_images(environment)
    
    # Then update DynamoDB with image URLs
    upload_images_to_s3(environment)
