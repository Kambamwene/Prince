import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

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
  String name;
  DocumentReference owner;
  int price;
  int seatCapacity;
  int parkingCapacity;
  List<Review> reviews = [];
  //List<DocumentReference> bookings = [];
  List<Booking> bookings = [];
  String location;
  String category;
  String description;
  String description2;
  double latitude;
  double longitude;
  double rating;
}

class Owner extends User {
  List<DocumentReference> halls = [];
  Owner() : super();
  //bool middleman;
}

class User {
  User({this.username, this.phoneNumber, this.name});
  String username;
  //List<DocumentReference>halls=[];
  String phoneNumber;
  String email;
  String dp;
  String name;
}

Map<String, dynamic> ownerToMap(Owner agent) {
  Map<String, dynamic> agentmap = <String, dynamic>{};
  agentmap["username"] = agent.username;
  agentmap["email"] = agent.email;
  //agentmap["houseId"] = agent.halls;
  agentmap["phoneNumber"] = agent.phoneNumber;
  agentmap["name"] = agent.name;
  agentmap["dp"] = agent.dp;
  agentmap["halls"] = agent.halls;
  //agentmap["middleman"] = agent.middleman;
  return agentmap;
}

Map<String, dynamic> userToMap(User user) {
  Map<String, dynamic> usermap = <String, dynamic>{};
  usermap["username"] = user.username;
  usermap["phoneNumber"] = user.phoneNumber;
  usermap["name"] = user.name;
  usermap["dp"] = user.dp;
  usermap["email"] = user.email;
  //agentmap["middleman"] = agent.middleman;
  return usermap;
}

User mapToUser(Map<String, dynamic> map) {
  User user = User();
  user.username = map["username"];
  user.name = map["name"];
  user.dp = map["dp"];
  user.phoneNumber = map["phoneNumber"];
  user.email = map["email"];
  return user;
}

Owner mapToOwner(Map<String, dynamic> map) {
  Owner owner = Owner();
  owner.username = map["username"];
  owner.email = map["email"];
  owner.name = map["name"];
  owner.dp = map["dp"];
  for (int n = 0; n < map["halls"].length; ++n) {
    owner.halls.add(map["halls"][n]);
  }
  owner.phoneNumber = map["phoneNumber"];
  return owner;
}

Map<String, dynamic> ukumbiToMap(Ukumbi ukumbi) {
  Map<String, dynamic> map = <String, dynamic>{};
  map["houseId"] = ukumbi.houseId;
  map["price"] = ukumbi.price;
  map["name"] = ukumbi.name;
  map["owner"] = ukumbi.owner;
  map["location"] = ukumbi.location;
  map["category"] = ukumbi.category;
  map["bookings"] = ukumbi.bookings;
  map["description"] = ukumbi.description;
  map["description2"] = ukumbi.description2;
  List<Map<String, dynamic>> bookings = [];
  for (int n = 0; n < ukumbi.bookings.length; ++n) {
    bookings.add(bookToMap(ukumbi.bookings[n]));
  }
  map["bookings"] = bookings;
  map["parkingCapacity"] = ukumbi.parkingCapacity;
  map["seatCapacity"] = ukumbi.seatCapacity;
  map["rating"] = ukumbi.rating;
  List<Map<String, dynamic>> reviews = [];
  for (int n = 0; n < ukumbi.reviews.length; ++n) {
    reviews.add(reviewToMap(ukumbi.reviews[n]));
  }
  map["reviews"] = reviews;
  map["video"] = ukumbi.videos;
  map["latitude"] = ukumbi.latitude;
  map["longitude"] = ukumbi.longitude;
  map["images"] = ukumbi.images;
  return map;
}

Ukumbi mapToUkumbi(Map<String, dynamic> map) {
  Ukumbi ukumbi = Ukumbi();
  ukumbi.description = map["description"];
  ukumbi.houseId = map["houseId"];
  ukumbi.name = map["name"];
  ukumbi.owner = map["owner"];
  ukumbi.location = map["location"];
  ukumbi.price = map["price"];
  for (int n = 0; n < map["images"].length; ++n) {
    ukumbi.images.add(map["images"][n]);
  }
  for (int n = 0; n < map["videos"].length; ++n) {
    ukumbi.videos.add(map["videos"][n]);
  }
  for (int n = 0; n < map["reviews"].length; ++n) {
    ukumbi.reviews.add(mapToReview(map["reviews"][n]));
  }
  ukumbi.seatCapacity = map["SeatCapacity"];
  ukumbi.parkingCapacity = map["parkingCapacity"];
  for (int n = 0; n < map["bookings"].length; ++n) {
    ukumbi.bookings.add(mapToBook(map["bookings"][n]));
  }
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

class BookingForm {
  String seatCapacity;
  String parkingCapacity;
  String description;
  BookingForm({this.description, this.parkingCapacity, this.seatCapacity});
}

Map<String, dynamic> formToMap(BookingForm form) {
  Map<String, dynamic> formmap = {
    "seatCapacity": form.seatCapacity,
    "parkingCapacity": form.parkingCapacity,
    "description": form.description
  };
  return formmap;
}

BookingForm mapToForm(Map<String, dynamic> map) {
  return BookingForm(
      seatCapacity: map["seatCapacity"],
      parkingCapacity: map["parkingCapacity"],
      description: map["description"]);
}

class Booking {
  DocumentReference user;
  int approved = 0;
  BookingForm form;
  DateTime start;
  DateTime end;
}

Booking mapToBook(Map<String, dynamic> map) {
  Booking booking = Booking();
  booking.user = map["user"];
  if (map["approved"] == null) {
    booking.approved = 0;
  } else {
    booking.approved = map["approved"];
  }
  if (map["form"] != null) {
    booking.form = mapToForm(map["form"]);
  }
  booking.start = map["start"].toDate();
  booking.end = map["end"].toDate();
  return booking;
}

Map<String, dynamic> bookToMap(Booking booking) {
  Map<String, dynamic> map = {
    "user": booking.user,
    "start": booking.start,
    "end": booking.end,
    "approved": booking.approved
  };
  if (booking.form == null) {
    map["form"] = null;
  } else {
    map["form"] = formToMap(booking.form);
  }
  return map;
}

Future<Booking> book(User user, DateTime start, Ukumbi ukumbi,
    {DateTime end, BookingForm form}) async {
  DocumentReference ref =
      FirebaseFirestore.instance.doc("Users/${user.username}");
  Booking booking = Booking();
  booking.user = ref;
  booking.start = start;
  booking.form = form;
  if (end == null) {
    booking.end = booking.start;
  } else {
    booking.end = end;
  }
  ukumbi.bookings.add(booking);
  try {
    await FirebaseFirestore.instance
        .collection("Halls")
        .doc(ukumbi.houseId)
        .update(ukumbiToMap(ukumbi));
  } catch (err) {
    return null;
  }
  return booking;
}

List<DateTime> calculateDaysInterval(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

List<DateTime> getBookedDates(Ukumbi ukumbi) {
  List<DateTime> dates = [];
  for (int n = 0; n < ukumbi.bookings.length; ++n) {
    if (ukumbi.bookings[n].approved == 1) {
      dates.addAll(calculateDaysInterval(
          ukumbi.bookings[n].start, ukumbi.bookings[n].end));
    }
  }
  //print(dates.length);
  return dates;
}

Future<List<Ukumbi>> getUkumbis() async {
  QuerySnapshot docs =
      await FirebaseFirestore.instance.collection("Halls").get();
  List<Ukumbi> ukumbis = [];
  for (int n = 0; n < docs.size; ++n) {
    ukumbis.add(mapToUkumbi(docs.docs[n].data()));
  }
  return ukumbis;
}

Future<bool> submitUkumbi(Ukumbi ukumbi, Owner mwenyeji) async {
  Map<String, dynamic> toUkumbi = ukumbiToMap(ukumbi);
  Map<String, dynamic> landlord = ownerToMap(mwenyeji);
  CollectionReference getos = FirebaseFirestore.instance.collection("Getos");
  CollectionReference agents =
      FirebaseFirestore.instance.collection("landlords");
  try {
    await getos.doc(ukumbi.houseId).set(toUkumbi);
    if (mwenyeji.username.isEmpty) {
      await agents.doc(mwenyeji.username).set(landlord);
    } else {
      await agents.add(landlord);
    }
  } catch (err) {
    print(err);
    return false;
  }
  return true;
}

Future<void> uploadImages(List<Uint8List> images, Ukumbi ukumbi,
    StreamController<String> feedback) async {}

Future<Position> fetchLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  Position position;
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return position;
    }
  }
  position = await Geolocator.getCurrentPosition();
  return position;
}

Future<List<String>> getCategories() async {
  List<String> category = [];
  return FirebaseFirestore.instance
      .collection("Settings")
      .doc("categories")
      .get()
      .then((categories) {
    if (categories.exists) {
      dynamic map = (categories.data())["categories"];
      map.forEach((cat) {
        category.add(cat["category"] as String);
      });
      return category;
    }
    return ["error"];
  }).catchError((err) {
    print(err);
    return ["error"];
  });
}

Future<Review> addReview(Ukumbi ukumbi, User user, String comment,
    StreamController<String> feedback) async {
  Review review =
      Review(FirebaseFirestore.instance.doc("Users/${user.username}"), comment);
  feedback.add("Adding comment");
  DocumentReference userRef =
      FirebaseFirestore.instance.doc("Users/${user.username}");
  review.user = userRef;
  review.comment = comment;
  Map<String, dynamic> ukumbiMap = ukumbiToMap(ukumbi);
  List<Map<String, dynamic>> reviews = [];
  for (int n = 0; n < ukumbi.reviews.length; ++n) {
    reviews.add(
        {"user": ukumbi.reviews[n].user, "comment": ukumbi.reviews[n].comment});
  }
  reviews.add({"user": userRef, "comment": comment});
  ukumbiMap["reviews"] = reviews;
  //hostelMap["reviews"]=reviewMap;
  try {
    await FirebaseFirestore.instance
        .collection("Halls")
        .doc(ukumbi.houseId)
        .update(ukumbiMap);
  } catch (err) {
    feedback.add("There was an error adding this comment");
    return null;
  }
  feedback.add("Success");
  return review;
  //Map<String,dynamic>reviewMap=reviewToMap()
}

Future<User> getReviewer(DocumentReference ref) async {
  return mapToUser((await ref.get()).data());
}

Future<User> readUser() async {
  Directory directory = await getApplicationDocumentsDirectory();
  String path = directory.path + "/user.dat";
  File file = File(path);
  if (!file.existsSync()) {
    User user = User();
    user.username = "NULL";
    return user;
  }
  String userString = file.readAsStringSync();
  Map<String, dynamic> map = json.decode(userString);
  return mapToUser(map);
}

Future<void> saveUser(User user) async {
  Directory directory = await getApplicationDocumentsDirectory();
  String path = directory.path + "/user.dat";
  File file = File(path);
  file.open(mode: FileMode.write);
  file.writeAsStringSync(json.encode(userToMap(user)));
}

Future<void> deleteUser() async {
  Directory directory = await getApplicationDocumentsDirectory();
  String path = directory.path + "/user.dat";
  File file = File(path);
  if (file.existsSync()) {
    file.deleteSync();
  }
}

String currencyFormatter(int price) {
  //return StringUtils.addCharAtPosition(price.toString(),",",4,repeat:true);
  String curr = price.toString();
  int counter = 0;
  for (int n = curr.length - 1; n >= 0; --n) {
    counter++;
    if (counter == 3) {
      if (n == 0) break;
      curr = StringUtils.addCharAtPosition(curr, ",", n);
      counter = 0;
    }
  }
  return curr;
}

Future<User> login(
    String username, String password, StreamController<String> feedback) async {
  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection("Users").doc(username).get();
  if (!doc.exists) {
    feedback.add("The username you have entered doesn't exist");
    return null;
  }
  Map<String, dynamic> map = doc.data();
  if (map["password"] != password) {
    feedback.add("The password you have entered is incorrect");
    return null;
  }
  feedback.add("Success");
  return mapToUser(map);
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

Future<User> createAccount(Map<String, dynamic> usermap,
    FilePickerResult result, StreamController<String> feedback) async {
  if (result == null) {
    try {
      usermap["dp"] =
          await uploadMedia(result.files.first, "dp", usermap["username"]);
    } catch (err) {
      feedback.add("Couldn't upload your dp");
      usermap["dp"] = null;
    }
  } else {
    usermap["dp"] = null;
  }
  try {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(usermap["username"])
        .set(usermap);
    return mapToUser(usermap);
  } catch (err) {
    feedback.add("There was an unexpected error creating account");
    return null;
  }
}

Future<List<Ukumbi>> getRelatedUkumbi(Ukumbi ukumbi,
    {int range = 200000}) async {
  List<Ukumbi> ukumbis = [];
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection("Halls")
      .where("price", isLessThan: (ukumbi.price + range))
      .where("price", isGreaterThan: ukumbi.price - range)
      .get();
  for (int n = 0; n < query.size; ++n) {
    if (query.docs[n]["houseId"] == ukumbi.houseId) {
      continue;
    }
    ukumbis.add(mapToUkumbi(query.docs[n].data()));
  }
  return ukumbis;
}

Future<User> getUser(User user) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection("Users")
      .doc(user.username)
      .get();
  if (doc.exists) {
    //await saveUser(mapToUser(doc.data()));
    return mapToUser(doc.data());
  }
  return user;
}

Future<List<Ukumbi>> getMyBookings(User user) async {
  QuerySnapshot query =
      await FirebaseFirestore.instance.collection("Halls").get();
  Set<Ukumbi> ukumbis = {};
  for (int n = 0; n < query.docs.length; ++n) {
    Ukumbi ukumbi = Ukumbi();
    ukumbi = mapToUkumbi(query.docs[n].data());
    if (ukumbi.bookings.isNotEmpty) {
      for (var booking in ukumbi.bookings) {
        if (booking.end.isBefore(DateTime.now())) {
          continue;
        }
        if (booking.user ==
            FirebaseFirestore.instance.doc("Users/${user.username}")) {
          ukumbis.add(ukumbi);
        } else {
          continue;
        }
      }
    } else {
      continue;
    }
    //ukumbis.add(mapToUkumbi(query.docs[n].data()));
  }
  return ukumbis.toList();
}

List<String> getAvailableLocations(List<Ukumbi> ukumbis) {
  Set<String> locations = {};
  //List<Ukumbi>ukumbis=await getUkumbis();
  for (int n = 0; n < ukumbis.length; ++n) {
    locations.add(ukumbis[n].location);
  }
  return locations.toList(growable: false);
}

List<Ukumbi> filterByPrice(List<Ukumbi> halls,
    {int minPrice = 0, int maxPrice = 1000000000}) {
  List<Ukumbi> filtered = [];
  for (int n = 0; n < halls.length; ++n) {
    if (halls[n].price > minPrice && halls[n].price < maxPrice) {
      filtered.add(halls[n]);
    }
  }
  return filtered;
}

List<Ukumbi> filterBySeats(List<Ukumbi> halls,
    {int minPrice = 0, int maxPrice = 10000}) {
  List<Ukumbi> filtered = [];
  for (int n = 0; n < halls.length; ++n) {
    if (halls[n].seatCapacity != null) {
      if (halls[n].seatCapacity > minPrice &&
          halls[n].seatCapacity < maxPrice) {
        filtered.add(halls[n]);
      }
    }
  }
  return filtered;
}

List<Ukumbi> filterByParking(List<Ukumbi> halls,
    {int minPrice = 0, int maxPrice = 10000}) {
  List<Ukumbi> filtered = [];
  for (int n = 0; n < halls.length; ++n) {
    if (halls[n].parkingCapacity != null) {
      if (halls[n].parkingCapacity > minPrice &&
          halls[n].parkingCapacity < maxPrice) {
        filtered.add(halls[n]);
      }
    }
  }
  return filtered;
}

List<Ukumbi> searchEngine(List<Ukumbi> halls, String query) {
  List<Ukumbi> filtered = [];
  query = query.toLowerCase();
  //List<String>locations=getAvailableLocations(halls);
  for (int n = 0; n < halls.length; ++n) {
    if (query.contains(halls[n].name.toLowerCase())) {
      filtered.add(halls[n]);
    }
  }
  if (filtered.isEmpty) {
    for (int n = 0; n < halls.length; ++n) {
      if ((halls[n].name.toLowerCase()).contains(query)) {
        filtered.add(halls[n]);
      }
    }
    if (filtered.isEmpty) {
      for (int n = 0; n < halls.length; ++n) {
        if (query.contains(halls[n].location.toLowerCase())) {
          filtered.add(halls[n]);
        }
      }
    }
  }
  return filtered;
}

Future<Owner> getUkumbiOwner(Ukumbi ukumbi) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection("Owners")
      .where("halls",
          arrayContains:
              FirebaseFirestore.instance.doc("Halls/${ukumbi.houseId}"))
      .get();
  Owner owner;
  for (int n = 0; n < query.size; ++n) {
    if (query.docs[n].exists) {
      owner = mapToOwner(query.docs[n].data());
      break;
    }
  }
  return owner;
}

Future<bool> updateUser(Map<String, dynamic> user) async {
  try {
    await FirebaseFirestore.instance
        .doc("Users/${user['username']}")
        .update(user);
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> uploadDp(FilePickerResult result) async {
  Reference ref =
      FirebaseStorage.instance.ref("/Users/${result.files.first.name}");
  try {
    await ref.putData(result.files.first.bytes);
    return await ref.getDownloadURL();
  } catch (e) {
    return null;
  }
}
