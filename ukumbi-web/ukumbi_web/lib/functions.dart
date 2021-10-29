import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Ukumbi {
  Ukumbi(
      {this.price,
      this.location,
      this.rating,
      this.category,
      this.houseId,
      this.name});
  List<String> images = [];
  List<String> videos = [];
  String houseId;
  DocumentReference owner;
  String name;
  int price;
  int seatCapacity;
  int parkingCapacity;
  String video;
  bool booked = false;
  List<Review> reviews = [];
  List<Booking> bookings = [];
  DateTime startDate;
  DateTime endDate;
  String location;
  String category;
  String description;
  String description2;
  double latitude;
  double longitude;
  double rating;
}

class Booking {
  DocumentReference user;
  int approved = 0;
  DateTime start;
  DateTime end;
  BookingForm form;
}

Booking mapToBook(Map<String, dynamic> map) {
  Booking booking = Booking();
  booking.user = map["user"];
  if (map["approved"] == null) {
    booking.approved = 0;
  } else {
    booking.approved = map["approved"];
  }
  booking.start = map["start"].toDate();
  if (map["form"] != null) {
    booking.form = mapToForm(map["form"]);
  }
  booking.end = map["end"].toDate();
  return booking;
}

Map<String, dynamic> bookToMap(Booking booking) {
  Map<String, dynamic> map = {
    "user": booking.user,
    "start": booking.start,
    "end": booking.end,
    "approved": booking.approved,
    "form": formToMap(booking.form)
  };

  return map;
}

class Owner extends User {
  List<DocumentReference> halls = [];
  Owner() : super();
  //bool middleman;
}

class User {
  String username;
  //List<DocumentReference>halls=[];
  String phoneNumber;
  String password;
  String dp;
  String name;
  //String password;
}

Map<String, dynamic> ownerToMap(Owner agent) {
  Map<String, dynamic> agentmap = <String, dynamic>{};
  agentmap["username"] = agent.username;
  //agentmap["password"]=agent.password;
  //agentmap["houseId"] = agent.halls;
  agentmap["phoneNumber"] = agent.phoneNumber;
  agentmap["name"] = agent.name;
  agentmap["dp"] = agent.dp;
  agentmap["halls"] = agent.halls;
  agentmap["password"] = agent.password;
  //agentmap["middleman"] = agent.middleman;
  return agentmap;
}

Map<String, dynamic> userToMap(User user) {
  Map<String, dynamic> usermap = <String, dynamic>{};
  usermap["username"] = user.username;
  usermap["phoneNumber"] = user.phoneNumber;
  usermap["name"] = user.name;
  usermap["dp"] = user.dp;
  usermap["password"] = user.password;
  //agentmap["middleman"] = agent.middleman;
  return usermap;
}

User mapToUser(Map<String, dynamic> map) {
  User user = User();
  user.username = map["username"];
  user.name = map["name"];
  user.dp = map["dp"];
  user.password = map["password"];
  user.phoneNumber = map["phoneNumber"];
  return user;
}

Owner mapToOwner(Map<String, dynamic> map) {
  Owner owner = Owner();
  owner.username = map["username"];
  owner.name = map["name"];
  owner.dp = map["dp"];
  owner.password = map["password"];
  if (map["halls"] != null) {
    for (int n = 0; n < map["halls"].length; ++n) {
      owner.halls.add(map["halls"][n]);
    }
  } else {
    owner.halls = [];
  }
  owner.phoneNumber = map["phoneNumber"];
  return owner;
}

class BookingForm {
  String seatCapacity;
  String parkingCapacity;
  String description;
  BookingForm({this.description, this.parkingCapacity, this.seatCapacity});
}

Map<String, dynamic> formToMap(BookingForm form) {
  Map<String, dynamic> formmap;
  if (form != null) {
    formmap = {
      "seatCapacity": form.seatCapacity,
      "parkingCapacity": form.parkingCapacity,
      "description": form.description
    };
  } else {
    formmap = null;
  }
  return formmap;
}

BookingForm mapToForm(Map<String, dynamic> map) {
  return BookingForm(
      seatCapacity: map["seatCapacity"],
      parkingCapacity: map["parkingCapacity"],
      description: map["description"]);
}

Map<String, dynamic> ukumbiToMap(Ukumbi ukumbi) {
  Map<String, dynamic> map = <String, dynamic>{};
  map["houseId"] = ukumbi.houseId;
  map["price"] = ukumbi.price;
  map["name"] = ukumbi.name;
  map["owner"] = ukumbi.owner;
  map["location"] = ukumbi.location;
  map["category"] = ukumbi.category;
  List<Map<String, dynamic>> bookings = [];
  for (int n = 0; n < ukumbi.bookings.length; ++n) {
    bookings.add(bookToMap(ukumbi.bookings[n]));
  }
  map["bookings"] = bookings;
  map["description"] = ukumbi.description;
  map["description2"] = ukumbi.description2;
  map["booked"] = ukumbi.booked;
  map["startDate"] = ukumbi.startDate;
  map["endDate"] = ukumbi.endDate;
  map["parkingCapacity"] = ukumbi.parkingCapacity;
  map["seatCapacity"] = ukumbi.seatCapacity;
  map["rating"] = ukumbi.rating;
  List<Map<String, dynamic>> reviews = [];
  for (int n = 0; n < ukumbi.reviews.length; ++n) {
    reviews.add(reviewToMap(ukumbi.reviews[n]));
  }
  map["reviews"] = reviews;
  map["videos"] = ukumbi.videos;
  map["latitude"] = ukumbi.latitude;
  map["longitude"] = ukumbi.longitude;
  map["images"] = ukumbi.images;
  return map;
}

Ukumbi mapToUkumbi(Map<String, dynamic> map) {
  Ukumbi ukumbi = Ukumbi();
  ukumbi.description = map["description"];
  ukumbi.owner = map["owner"];
  ukumbi.houseId = map["houseId"];
  ukumbi.name = map["name"];
  ukumbi.location = map["location"];
  ukumbi.price = map["price"];
  for (int n = 0; n < map["bookings"].length; ++n) {
    ukumbi.bookings.add(mapToBook(map["bookings"][n]));
  }
  for (int n = 0; n < map["images"].length; ++n) {
    ukumbi.images.add(map["images"][n]);
  }
  for (int n = 0; n < map["videos"].length; ++n) {
    ukumbi.videos.add(map["videos"][n]);
  }
  ukumbi.booked = map["booked"];
  for (int n = 0; n < map["reviews"].length; ++n) {
    ukumbi.reviews.add(mapToReview(map["reviews"][n]));
  }
  ukumbi.startDate = map["startDate"];
  ukumbi.seatCapacity = map["SeatCapacity"];
  ukumbi.parkingCapacity = map["parkingCapacity"];
  ukumbi.endDate = map["endDate"];
  /*for (int n = 0; n < map["bookings"].length; ++n) {
    ukumbi.bookings.add(map["bookings"][n]);
  }*/
  //ukumbi.bookings = map["bookings"];
  ukumbi.rating = map["rating"];
  ukumbi.category = map["category"];
  return ukumbi;
}

class Review {
  String comment;
  DocumentReference user;
  Review(this.user, this.comment);
}

Review mapToReview(Map<String, dynamic> map) {
  Review review = Review(map["user"], map["comment"]);
  //review.comment = map["comment"];
  //review.user = map["user"];
  return review;
}

Map<String, dynamic> reviewToMap(Review review) {
  Map<String, dynamic> reviewMap = <String, dynamic>{};
  reviewMap["user"] = review.user;
  reviewMap["comment"] = review.comment;
  return reviewMap;
}

Future<Owner> login(
    String username, String password, StreamController<String> feedback) async {
  feedback.add("Checking username...");
  DocumentSnapshot doc;
  Owner owner = Owner();
  try {
    doc = await FirebaseFirestore.instance
        .collection("Owners")
        .doc(username)
        .get();
    if (!doc.exists) {
      feedback.add("The username you have entered doesn't exist");
      return null;
    }
    Map<String, dynamic> data = doc.data();
    if (data["password"] != password) {
      feedback.add("You have entered an incorrect password");
      return null;
    }
    feedback.add("Success");
    owner = mapToOwner(data);
    return owner;
  } catch (err) {
    feedback.add("There was an unexpected error");
    return null;
  }
}

Future<List<Ukumbi>> getUkumbis(Owner owner) async {
  List<Ukumbi> ukumbis = [];
  List<DocumentReference> refs = [];
  for (int n = 0; n < owner.halls.length; ++n) {
    refs.add(owner.halls[n]);
  }
  List<DocumentSnapshot> docs = [];
  try {
    for (int n = 0; n < refs.length; ++n) {
      docs.add(await refs[n].get());
    }
  } catch (err) {
    return [];
  }
  for (int n = 0; n < docs.length; ++n) {
    if (!docs[n].exists) {
      continue;
    } else {
      ukumbis.add(mapToUkumbi(docs[n].data()));
    }
  }
  return ukumbis;
}

Future<List<User>> getUsersFromReference(
    List<DocumentReference> userRefs) async {
  List<DocumentSnapshot> docs = [];
  List<User> users = [];
  for (int n = 0; n < userRefs.length; ++n) {
    docs.add(await userRefs[n].get());
  }
  for (int n = 0; n < docs.length; ++n) {
    if (!docs[n].exists) {
      continue;
    } else {
      users.add(mapToUser(docs[n].data()));
    }
  }
  return users;
}

String getRandomString(int length) {
  const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  Random _rnd = Random();

  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

Future<String> uploadMedia(PlatformFile file, String type, Owner owner) async {
  String downloadUrl;
  Reference reference =
      FirebaseStorage.instance.ref("/${owner.username}/$type/${file.name}");
  try {
    await reference.putData(file.bytes);
    downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  } catch (err) {
    return null;
  }
}

Future<Ukumbi> submitUkumbi(Owner owner, Ukumbi ukumbi, FilePickerResult images,
    FilePickerResult videos, StreamController<String> feedback) async {
  String url;
  if (images != null) {
    for (int n = 0; n < images.count; ++n) {
      feedback.add("Uploading ${images.files[n].name}...");
      url = await uploadMedia(images.files[n], "images", owner);
      if (url != null) {
        ukumbi.images.add(url);
      } else {
        feedback.add(
            "${images.files[n].name} couldn't be uploaded and will be skipped");
      }
    }
  }
  if (videos != null) {
    for (int n = 0; n < videos.count; ++n) {
      feedback.add("Uploading ${videos.files[n].name}...");
      url = await uploadMedia(videos.files[n], "videos", owner);
      if (url != null) {
        ukumbi.videos.add(url);
      } else {
        feedback.add(
            "${videos.files[n].name} couldn't be uploaded and will be skipped");
      }
    }
  }
  ukumbi.owner = FirebaseFirestore.instance.doc("/Owners/${owner.username}");
  feedback.add("Generating hall ID");
  DocumentSnapshot doc;
  String hallId;
  do {
    hallId = getRandomString(6);
    try {
      doc = await FirebaseFirestore.instance
          .collection("Halls")
          .doc(hallId)
          .get();
    } catch (err) {
      feedback.add("There was an error saving this hall");
      return null;
    }
  } while (doc.exists);
  feedback.add("Saving hall...");
  ukumbi.houseId = hallId;
  try {
    await FirebaseFirestore.instance
        .collection("Halls")
        .doc(hallId)
        .set(ukumbiToMap(ukumbi));
    owner.halls.add(FirebaseFirestore.instance.doc("/Halls/$hallId"));
    await FirebaseFirestore.instance
        .collection("Owners")
        .doc(owner.username)
        .update(ownerToMap(owner));
    feedback.add("Your hall ID is $hallId");
    return ukumbi;
  } catch (err) {
    feedback.add("There was an error saving this hall");
    return null;
  }
}

Future<Owner> createAccount(Owner owner, FilePickerResult result,
    StreamController<String> feedback) async {
  if (result != null) {
    feedback.add("Uploading dp...");
    owner.dp = await uploadMedia(result.files.first, "dp", owner);
    if (owner.dp == null) {
      feedback.add("Couldn't upload dp. You can upload it again later on");
    }
  }
  feedback.add("Creating account...");
  try {
    await FirebaseFirestore.instance
        .collection("Owners")
        .doc(owner.username)
        .set(ownerToMap(owner));
  } catch (err) {
    feedback.add("There was an unexpected error");
    return null;
  }
  feedback.add("Success");
  return owner;
}

Future<bool> checkUsername(
    String username, StreamController<String> feedback) async {
  DocumentSnapshot doc;
  try {
    doc = await FirebaseFirestore.instance
        .collection("Owners")
        .doc(username)
        .get();
  } catch (err) {
    feedback.add("Couldn't check usernames at this time");
    return false;
  }
  if (doc.exists) {
    feedback.add("This username is already taken");
    return false;
  }
  feedback.add("Available");
  return true;
}

Future<String> deleteUkumbi(
    Owner owner, Ukumbi ukumbi, StreamController<String> feedback) async {
  //Check if hall has active bookings
  for (var booking in ukumbi.bookings) {
    if (booking.approved == 1) {
      if (booking.start.isAfter(DateTime.now())) {
        feedback.add("This hall has active bookings and cannot be deleted");
        return "WITH_BOOKING";
      }
    }
  }
  if (ukumbi.images != null) {
    for (int n = 0; n < ukumbi.images.length; ++n) {
      feedback.add("Deleting image ${n + 1}....");
      try {
        await FirebaseStorage.instance.refFromURL(ukumbi.images[n]).delete();
      } catch (err) {
        feedback.add("Couldn't delete image ${n + 1}. Skipping...");
        continue;
      }
    }
  }
  if (ukumbi.videos != null) {
    feedback.add("Deleting video...");
    for (int n = 0; n < ukumbi.videos.length; ++n) {
      feedback.add("Deleting video ${n + 1}....");
      try {
        await FirebaseStorage.instance.refFromURL(ukumbi.videos[n]).delete();
      } catch (err) {
        feedback.add("Couldn't delete video ${n + 1}. Skipping...");
        continue;
      }
    }
  }
  try {
    feedback.add("Removing ukumbi...");
    await FirebaseFirestore.instance
        .collection("Halls")
        .doc(ukumbi.houseId)
        .delete();
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("Owners")
        .doc(owner.username)
        .get();
    Map<String, dynamic> map = doc.data();
    for (int n = 0; n < map["halls"].length; ++n) {
      if (map["halls"][n] ==
          FirebaseFirestore.instance.doc("/Halls/${ukumbi.houseId}")) {
        map["halls"].removeAt(n);
      }
    }
    await FirebaseFirestore.instance
        .collection("Owners")
        .doc(owner.username)
        .update(map);
  } catch (err) {
    feedback.add("There was an error deleting this hall");
    return "ERROR";
  }
  feedback.add("Success");
  return "SUCCESS";
}

Future<List<Owner>> getAllOwners() async {
  List<Owner> owners = [];
  QuerySnapshot query;
  try {
    query = await FirebaseFirestore.instance.collection("Owners").get();
    for (int n = 0; n < query.size; ++n) {
      if (query.docs[n].exists) {
        owners.add(mapToOwner(query.docs[n].data()));
      }
    }
  } catch (err) {
    return [];
  }
  return owners;
}

Future<List<Ukumbi>> getAllUkumbis() async {
  List<Ukumbi> ukumbis = [];
  QuerySnapshot query;
  try {
    query = await FirebaseFirestore.instance.collection("Halls").get();
    for (int n = 0; n < query.size; ++n) {
      if (query.docs[n].exists) {
        ukumbis.add(mapToUkumbi(query.docs[n].data()));
      }
    }
  } catch (err) {
    return [];
  }
  return ukumbis;
}

Future<List<User>> getAllUsers() async {
  List<User> users = [];
  QuerySnapshot query;
  try {
    query = await FirebaseFirestore.instance.collection("Users").get();
    for (int n = 0; n < query.size; ++n) {
      if (query.docs[n].exists) {
        users.add(mapToUser(query.docs[n].data()));
      }
    }
  } catch (err) {
    return [];
  }
  return users;
}

Future<String> deleteUser(User user, StreamController<String> feedback) async {
  //Search if user has any bookings
  QuerySnapshot query;
  feedback.add("Deleting...");
  List<Ukumbi> halls = [];
  try {
    query = await FirebaseFirestore.instance.collection("Halls").get();
    //Loop through all database halls searching for user bookings
    for (var doc in query.docs) {
      if (!doc.exists) {
        continue;
      }
      Ukumbi ukumbi = mapToUkumbi(doc.data());
      //identify user bookings and delete them
      for (int n = 0; n < ukumbi.bookings.length; ++n) {
        if (ukumbi.bookings[n].user ==
            FirebaseFirestore.instance.doc("Users/${user.username}")) {
          //If user has active bookings exit delete process
          if (ukumbi.bookings[n].approved == 1) {
            if (ukumbi.bookings[n].start.isAfter(DateTime.now())) {
              feedback.add(
                  "This user has an active booking and cannot at this moment be deleted");
              return "WITH_BOOKING";
            }
          }
          ukumbi.bookings.removeAt(n);
        }
      }
      //save new updated hall
      halls.add(ukumbi);
    }
    //Update halls on server
    for (int n = 0; n < halls.length; ++n) {
      await FirebaseFirestore.instance
          .doc("Halls/${halls[n].houseId}")
          .update(ukumbiToMap(halls[n]));
    }
    //Delete User
    await FirebaseFirestore.instance.doc("Users/${user.username}").delete();
    feedback.add("Success");
    return "SUCCESS";
  } catch (err) {
    feedback.add("Error");
    return "ERROR";
  }
}

Future<bool> deleteOwner(
    Owner owner, List<Ukumbi> halls, StreamController<String> feedback) async {
  //Delete owner halls
  feedback.add("Deleting...");
  bool success = true;
  try {
    for (int n = 0; n < halls.length; ++n) {
      String response = await deleteUkumbi(owner, halls[n], feedback);
      if (response != "SUCCESS") {
        success = false;
      }
    }
    if (success) {
      await FirebaseFirestore.instance.doc("Owners/${owner.username}").delete();
    }
    return true;
  } catch (err) {
    return false;
  }
}

Future<bool> deleteBooking(Booking booking) async {
  Ukumbi ukumbi = await getHallFromBooking(booking);
  ukumbi.bookings.remove(booking);

  try {
    await FirebaseFirestore.instance
        .doc("Halls/${ukumbi.houseId}")
        .update(ukumbiToMap(ukumbi));
    return true;
  } catch (e) {
    return false;
  }
}

Future<Ukumbi> getHallFromBooking(Booking booking) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection("Halls")
      .where("bookings", arrayContains: bookToMap(booking))
      .get();
  return mapToUkumbi(query.docs.first.data());
}

Future<bool>updateHall(Map<String,dynamic>map)async{
  try{
    await FirebaseFirestore.instance.doc("Halls/${map['houseId']}").update(map);
    return true;
  }
  catch(err){
    return false;
  }
}