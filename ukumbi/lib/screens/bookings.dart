import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ukumbi/modules.dart';

class Bookings extends StatefulWidget {
  final User user;
  const Bookings(this.user, {Key key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  Future<List<Ukumbi>> bookings;
  @override
  void initState() {
    bookings = getMyBookings(widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      //crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height:MediaQuery.of(context).padding.top),
        Expanded(
            child: FutureBuilder(
                future: bookings,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data.isEmpty) {
                    return const Center(
                        child: Text("You have made no bookings yet"));
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      padding: const EdgeInsets.only(right: 10),
                      itemBuilder: (context, index) {
                        return Container(
                            alignment: Alignment.centerLeft,
                            //width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: tiles(snapshot.data[index]));
                      });
                }))
        //Center(child:Text("You have made no bookings yet"))
      ],
    ));
  }

  Widget tiles(Ukumbi ukumbi) {
    List<Booking> bookings = [];
    for (var booking in ukumbi.bookings) {
      if (booking.user ==
          FirebaseFirestore.instance.doc("Users/${widget.user.username}")) {
        bookings.add(booking);
      }
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: bookings.length,
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return bookingTile(ukumbi, bookings[index]);
          },
          separatorBuilder: (context, index) {
            return const SizedBox.shrink();
          }),
    );
  }

  Widget bookingTile(Ukumbi ukumbi, Booking booking) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          //height:300,
          padding: const EdgeInsets.only(top: 8.0),
          child: Material(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      color: Colors.grey,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: ukumbi.images[0],
                        //height:250,
                        fit: BoxFit.cover,
                      ),
                    )),
                Positioned(
                  right: 10.0,
                  top: 10.0,
                  child: (booking.approved == 1)
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () async {
                            ukumbi.bookings.remove(booking);
                            try {
                              await FirebaseFirestore.instance
                                  .collection("Halls")
                                  .doc(ukumbi.houseId)
                                  .update(ukumbiToMap(ukumbi));
                              setState(() {
                                bookings = getMyBookings(widget.user);
                              });
                            } catch (err) {}
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                ),
                Positioned(
                  bottom: 20.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(ukumbi.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
                        Text(ukumbi.location,
                            style: const TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Material(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                        "From: ${booking.start.day}-${booking.start.month}-${booking.start.year} To: ${booking.end.day}-${booking.end.month}-${booking.end.year}",
                        style: const TextStyle(
                          fontSize: 16.0,
                        )),
                  ),
                  const SizedBox(height: 8),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Status: "),
                        (booking.approved == 0)
                            ? const Text("PENDING",
                                style: TextStyle(color: Colors.red))
                            : (booking.approved == 1)
                                ? const Text("APPROVED")
                                : const Text("DENIED",
                                    style: TextStyle(color: Colors.red))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
