# Food Truck Images Guide

Your app now displays real images! Here's how the image system works and how to add your own.

## Current Setup ✅

The seed data now includes **real food images from Unsplash**:
- 🌮 Smoky Mountain Tacos - Taco image
- 🍔 Vol Burger - Burger image
- 🍣 Tennessee Sushi - Sushi image
- 🍕 Knoxville Pizza Co - Pizza image
- 🍜 Thai Volunteer - Thai food image

These images are already working in:
- ✅ Map markers
- ✅ List view cards
- ✅ Detail view
- ✅ Bottom sheet on map

## How It Works

**1. Images are stored in S3**
```
s3://foodtruckfinder-images-dev-{account-id}/food-trucks/
```

**2. URLs are stored in DynamoDB**
```json
{
  "id": "abc123",
  "name": "Taco Truck",
  "imageUrl": "https://bucket.s3.amazonaws.com/food-trucks/taco-truck.jpg"
}
```

**3. iOS app loads images**
```swift
AsyncImage(url: URL(string: imageUrl)) { image in
    image.resizable()...
}
```

## Option 1: Use Unsplash (Current)

Already set up! The seed data uses Unsplash images:
- Free to use
- High quality
- No upload needed
- Perfect for development/testing

## Option 2: Upload Your Own Images

### Step 1: Prepare Images

Create an `images/` folder:
```bash
cd aws-backend/scripts
mkdir images
```

Add your images (recommended specs):
- Format: JPG or PNG
- Size: 400x400px (square)
- File size: < 500KB
- Names: `taco-truck.jpg`, `burger-truck.jpg`, etc.

### Step 2: Upload to S3

```bash
cd aws-backend/scripts
python3 upload-images.py dev
```

This will:
1. Upload images to S3
2. Make them publicly accessible
3. Return URLs like: `https://foodtruckfinder-images-dev-{account-id}.s3.amazonaws.com/food-trucks/taco-truck.jpg`

### Step 3: Update DynamoDB

Update a specific truck:
```bash
aws dynamodb update-item \
  --table-name FoodTrucks-dev \
  --key '{"id":{"S":"truck-id-here"}}' \
  --update-expression "SET imageUrl = :url" \
  --expression-attribute-values '{":url":{"S":"https://your-bucket.s3.amazonaws.com/food-trucks/image.jpg"}}'
```

Or update seed-data.py and reseed:
```python
'imageUrl': 'https://foodtruckfinder-images-dev-{account-id}.s3.amazonaws.com/food-trucks/taco-truck.jpg'
```

## Option 3: Use a CDN

For production, use a CDN like CloudFront:

1. Create CloudFront distribution pointing to S3 bucket
2. Update image URLs to use CloudFront domain
3. Benefits: Faster loading, caching, HTTPS

## Image Best Practices

### Recommended Specs
- **Format**: JPG (smaller) or PNG (transparency)
- **Dimensions**: 400x400px (1:1 ratio)
- **File size**: 100-500KB
- **Quality**: 80-90% compression

### Optimization
```bash
# Install ImageMagick
brew install imagemagick

# Resize and optimize
convert input.jpg -resize 400x400^ -gravity center -extent 400x400 -quality 85 output.jpg
```

### Naming Convention
```
food-trucks/
  ├── {truck-id}.jpg          # Best: Use truck ID
  ├── taco-truck.jpg          # Good: Descriptive name
  └── smoky-mountain-tacos.jpg # OK: Full name
```

## Testing Images

### Test in iOS App
1. Run the app
2. Check map markers (should show images)
3. Check list view (should show images)
4. Tap a truck (detail card should show image)

### Test URLs Directly
```bash
# Test if image is accessible
curl -I "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400"

# Should return: HTTP/1.1 200 OK
```

### Check DynamoDB
```bash
aws dynamodb scan --table-name FoodTrucks-dev \
  --projection-expression "id,#n,imageUrl" \
  --expression-attribute-names '{"#n":"name"}'
```

## Troubleshooting

### Images Not Loading

**Problem**: Images show placeholder icon
**Solutions**:
1. Check URL is valid: `curl -I "your-image-url"`
2. Verify S3 bucket is public
3. Check CORS settings on S3
4. Ensure URL is HTTPS (not HTTP)

### S3 Access Denied

**Problem**: 403 Forbidden error
**Solution**: Update bucket policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::foodtruckfinder-images-dev-*/*"
    }
  ]
}
```

### Images Load Slowly

**Problem**: Images take time to load
**Solutions**:
1. Optimize image size (< 500KB)
2. Use CloudFront CDN
3. Implement image caching in iOS app
4. Use progressive JPEGs

## Advanced: Dynamic Image Upload

For food truck owners to upload their own images:

### Backend (Already Implemented)
```
POST /upload-url
→ Returns presigned S3 URL
→ Upload image directly to S3
→ Save URL in DynamoDB
```

### iOS Implementation
```swift
// 1. Get presigned URL
let response = try await AWSNetworkManager.shared.getPresignedUrl(
    fileName: "truck-image.jpg",
    contentType: "image/jpeg"
)

// 2. Upload image
var request = URLRequest(url: URL(string: response.uploadUrl)!)
request.httpMethod = "PUT"
request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
request.httpBody = imageData
try await URLSession.shared.data(for: request)

// 3. Save URL to food truck
let imageUrl = response.imageUrl
```

## Cost Considerations

### S3 Storage
- $0.023 per GB/month
- 100 images @ 200KB = 20MB = $0.0005/month
- Essentially free for small apps

### S3 Requests
- GET: $0.0004 per 1,000 requests
- PUT: $0.005 per 1,000 requests
- Very cheap for typical usage

### CloudFront (Optional)
- $0.085 per GB transferred
- Free tier: 1TB/month for 12 months
- Recommended for production

## Summary

✅ **Current**: Using Unsplash images (free, high quality)
✅ **iOS App**: Already supports images everywhere
✅ **S3 Bucket**: Already configured and public
✅ **Upload Script**: Ready to use for your own images

Your app is fully image-ready! Just run the app and you'll see beautiful food images on the map, in the list, and in detail views.
