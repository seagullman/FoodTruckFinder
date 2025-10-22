#!/usr/bin/env node

/**
 * Export Firebase Firestore data to JSON
 * Usage: node export-firebase.js
 * 
 * Prerequisites:
 * 1. npm install firebase-admin
 * 2. Download serviceAccountKey.json from Firebase Console
 */

const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function exportFoodTrucks() {
  console.log('📦 Exporting food trucks from Firestore...');
  
  try {
    const snapshot = await db.collection('food-trucks').get();
    const trucks = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      trucks.push({
        id: doc.id,
        ...data,
        // Convert Firestore Timestamp to ISO string if needed
        createdAt: data.createdAt?.toDate?.()?.toISOString() || data.createdAt,
        updatedAt: data.updatedAt?.toDate?.()?.toISOString() || data.updatedAt
      });
    });
    
    // Save to file
    fs.writeFileSync(
      'food-trucks-export.json',
      JSON.stringify(trucks, null, 2)
    );
    
    console.log(`✅ Exported ${trucks.length} food trucks to food-trucks-export.json`);
    
    // Print summary
    console.log('\n📊 Summary:');
    console.log(`Total trucks: ${trucks.length}`);
    
    const cuisineTypes = {};
    trucks.forEach(truck => {
      const cuisine = truck.cuisineType || 'unknown';
      cuisineTypes[cuisine] = (cuisineTypes[cuisine] || 0) + 1;
    });
    
    console.log('\nBy cuisine type:');
    Object.entries(cuisineTypes).forEach(([cuisine, count]) => {
      console.log(`  ${cuisine}: ${count}`);
    });
    
  } catch (error) {
    console.error('❌ Error exporting data:', error);
    process.exit(1);
  }
}

async function exportUsers() {
  console.log('\n📦 Exporting users from Firestore...');
  
  try {
    const snapshot = await db.collection('users').get();
    const users = [];
    
    snapshot.forEach(doc => {
      users.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    fs.writeFileSync(
      'users-export.json',
      JSON.stringify(users, null, 2)
    );
    
    console.log(`✅ Exported ${users.length} users to users-export.json`);
    
  } catch (error) {
    console.error('❌ Error exporting users:', error);
  }
}

async function main() {
  await exportFoodTrucks();
  await exportUsers();
  
  console.log('\n✅ Export complete!');
  console.log('\nNext steps:');
  console.log('1. Review exported JSON files');
  console.log('2. Run import-dynamodb.py to import to AWS');
  console.log('3. Run migrate-images.py to move images to S3');
  
  process.exit(0);
}

main();
