// use("bit");

// db.bit.insertOne({ "name": "nitesh" });

// db.bit.insertMany([
//     { "name": "vijay", "usn": "1bi24cd15", "age": 21 },
//     { "name": "nitesh", "usn": "1bi24cd19", "age": 25 },
//     { "name": "hero", "usn": "1bi24cd18", "age": 26 },
//     { "name": "vedant", "usn": "1bi24cd17", "age": 29 },
//     { "name": "ravindra", "usn": "1bi24cd16", "age": 22 }
//   ]);
  

// db.bit.find({ age: 21 });

// db.bit.find().sort({ age: 21 });  
// db.bit.find().limit(3);           
// db.bit.find().sort({ age: 21 }).limit(3); 


// db.bit.find({$and: [
//       { age: 22 },
//       { usn: "1bi24cd16" }
//     ]
//   });
  
// db.bit.find({
//     $or: [
//       { age: 25 },
//       { city: "Bangalore" }
//     ]
//   });
  

// db.bit.updateOne({ name: "nitesh" }, { $set: { age: 26 } });

// db.bit.deleteOne({ name: "vijay" });


// db.bit.find();




// new pgm


// db.goaplace.insertMany([
//     { name: "India Gate", location: { type: "Point", coordinates: [77.2295, 28.6129] } },
//     { name: "Taj Mahal", location: { type: "Point", coordinates: [78.0421, 27.1751] } },
//     { name: "Gateway of India", location: { type: "Point", coordinates: [72.8347, 18.9220] } },
//     { name: "Mysore Palace", location: { type: "Point", coordinates: [76.6551, 12.3052] } },
//     { name: "Charminar", location: { type: "Point", coordinates: [78.4747, 17.3616] } },
//     { name: "Red Fort", location: { type: "Point", coordinates: [77.2410, 28.6562] } },
//     { name: "Hawa Mahal", location: { type: "Point", coordinates: [75.8267, 26.9239] } },
//     { name: "Golden Temple", location: { type: "Point", coordinates: [74.8765, 31.6200] } }
//   ]);
  

// db.goaplace.createIndex({ location: "2dsphere" });


// db.goaplace.find({
//     location: {
//       $near: {
//         $geometry: {
//           type: "Point",
//           coordinates: [72.8347, 18.9220]
//         },
//         $maxDistance: 500000  
//       }
//     }
//   }).pretty();
  

// new pgm


// db.Devices.insertMany([
//     { name: "Device A", status: 5 }, 
//     { name: "Device B", status: 3 }, 
//     { name: "Device C", status: 12 }, 
//     { name: "Device D", status: 10 }, 
//     { name: "Device E", status: 7 }  
//   ])

// db.Devices.find({ status: { $bitsAllSet: [0, 1] } });


// db.Devices.find({ status: { $bitsAnySet: [1, 2] } });


// db.Devices.find({ status: { $bitsAllClear: [0, 1] } });


// db.Devices.find({ status: { $bitsAnyClear: [1, 2] } });




