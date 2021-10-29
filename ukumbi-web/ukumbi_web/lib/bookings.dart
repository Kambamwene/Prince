// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'functions.dart';
import 'responsive.dart';

class Bookings extends StatefulWidget {
  List<Ukumbi> ukumbis;
  final String page;
  Bookings({Key key, this.ukumbis, this.page}) : super(key: key);

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  List<Map<String, dynamic>> bookings = [];
  Booking selectedBooking;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      bookings = [];
      if (widget.ukumbis == null) {
        return const Center(child: Text("You have no halls registered"));
      } else {
        for (int n = 0; n < widget.ukumbis.length; ++n) {
          for (int m = 0; m < widget.ukumbis[n].bookings.length; ++m) {
            if (widget.page == "upcoming") {
              if (widget.ukumbis[n].bookings[m].approved == 1) {
                if (widget.ukumbis[n].bookings[m].start
                    .isAfter(DateTime.now())) {
                  bookings.add({
                    "ukumbi": widget.ukumbis[n],
                    "bookings": widget.ukumbis[n].bookings[m]
                  });
                }
              }
            } else {
              if (widget.ukumbis[n].bookings[m].approved != 1) {
                if (widget.ukumbis[n].bookings[m].start
                    .isAfter(DateTime.now())) {
                  bookings.add({
                    "ukumbi": widget.ukumbis[n],
                    "bookings": widget.ukumbis[n].bookings[m]
                  });
                }
              }
            }
          }
        }
        return Row(children: [
          Expanded(
              child: Scrollbar(
            isAlwaysShown: true,
            child: (bookings.isEmpty)
                ? const Center(child: Text("You currently have no bookings"))
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: FutureBuilder(
                              future: bookings[index]["bookings"].user.get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                User user = mapToUser(snapshot.data.data());
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedBooking =
                                          bookings[index]["bookings"];
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                            title: Text(
                                                "${bookings[index]["ukumbi"].name}"),
                                            leading: CircleAvatar(
                                              radius: 30,
                                              foregroundImage: (user.dp == null)
                                                  ? null
                                                  : NetworkImage(user.dp),
                                            ),
                                            subtitle: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${user.name} \n ${user.phoneNumber}"),
                                                const SizedBox(height: 5),
                                                (widget.page == "upcoming")
                                                    ? const SizedBox.shrink()
                                                    : Text(
                                                        "${bookings[index]["bookings"].start} to ${bookings[index]["bookings"].end}",
                                                        style: const TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic))
                                              ],
                                            )),
                                      ),
                                      (widget.page == "upcoming")
                                          ? Column(children: [
                                              Text(
                                                  "From: ${bookings[index]["bookings"].start}"),
                                              const SizedBox(height: 5),
                                              Text(
                                                  "To: ${bookings[index]["bookings"].end}")
                                            ])
                                          : Row(
                                              children: [
                                                IconButton(
                                                    icon: const Icon(
                                                        Icons.check,
                                                        color: Colors.blue),
                                                    onPressed: () async {
                                                      for (int n = 0;
                                                          n <
                                                              widget.ukumbis
                                                                  .length;
                                                          ++n) {
                                                        if (widget.ukumbis[n]
                                                                .houseId ==
                                                            bookings[index]
                                                                    ["ukumbi"]
                                                                .houseId) {
                                                          Booking booking =
                                                              bookings[index]
                                                                  ["bookings"];
                                                          booking.approved = 1;
                                                          setState(() {
                                                            widget.ukumbis[n]
                                                                .bookings
                                                                .remove(bookings[
                                                                        index][
                                                                    "bookings"]);
                                                            widget.ukumbis[n]
                                                                .bookings
                                                                .add(booking);
                                                          });
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "Halls")
                                                                .doc(widget
                                                                    .ukumbis[n]
                                                                    .houseId)
                                                                .update(ukumbiToMap(
                                                                    widget.ukumbis[
                                                                        n]));
                                                          } catch (err) {}
                                                        }
                                                      }
                                                    }),
                                                IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.red),
                                                    onPressed: () async {
                                                      for (int n = 0;
                                                          n <
                                                              widget.ukumbis
                                                                  .length;
                                                          ++n) {
                                                        if (widget.ukumbis[n]
                                                                .houseId ==
                                                            bookings[index]
                                                                    ["ukumbi"]
                                                                .houseId) {
                                                          setState(() {
                                                            widget.ukumbis[n]
                                                                .bookings
                                                                .remove(bookings[
                                                                        index][
                                                                    "bookings"]);
                                                          });
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "Halls")
                                                                .doc(widget
                                                                    .ukumbis[n]
                                                                    .houseId)
                                                                .update(ukumbiToMap(
                                                                    widget.ukumbis[
                                                                        n]));
                                                          } catch (err) {}
                                                        }
                                                      }
                                                    }),
                                              ],
                                            )
                                    ],
                                  ),
                                );
                              }),
                        ),
                      );
                    }),
          )),
          (Responsive.isMobile(context))
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.all(10),
                  width: 250,
                  height: MediaQuery.of(context).size.height,
                  child: Card(
                    child: Builder(builder: (context) {
                      if (selectedBooking == null) {
                        return const Center(
                            child: Text(
                          "Select on a booking to view more info",
                          textAlign: TextAlign.center,
                        ));
                      }
                      return BookingInfo(booking: selectedBooking);
                    }),
                  ))
        ]);
      }
    });
  }
}

class Header extends StatelessWidget {
  const Header({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class BookingInfo extends StatefulWidget {
  final Booking booking;
  const BookingInfo({Key key, this.booking}) : super(key: key);

  @override
  State<BookingInfo> createState() => _BookingInfoState();
}

class _BookingInfoState extends State<BookingInfo>
    with TickerProviderStateMixin {
  TabController tabController;
  Future<dynamic> docSnapshot;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    docSnapshot = widget.booking.user.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const SizedBox.shrink(),
          title: const Text("Details"),
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              //Text("Hall"),
              Text("User"),
              Text("Form")
            ],
          )),
      body: TabBarView(controller: tabController, children: [
        FutureBuilder(
            future: docSnapshot,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.expand(
                    child: Center(child: CircularProgressIndicator()));
              }
              User user = mapToUser(snapshot.data.data());
              return ListView(
                padding: const EdgeInsets.all(5),
                children: [
                  (user.dp == null)
                      ? SizedBox(
                          child: Icon(Icons.person,
                              size: 80, color: Colors.grey[350]))
                      : Image.network(user.dp),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 5),
                      Text(user.name),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 5),
                      Text(user.phoneNumber),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
        (widget.booking.form == null)
            ? const SizedBox.expand(
                child: Center(
                    child: Text(
                  "No form was submitted with this booking",
                  textAlign: TextAlign.center,
                )),
              )
            : ListView(padding: const EdgeInsets.all(5), children: [
                const Text(
                  "Submitted Form",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Divider(),
                Text(
                    "Seating Capacity: ${(widget.booking.form.seatCapacity == null) ? "-" : widget.booking.form.seatCapacity}"),
                const SizedBox(height: 5),
                Text(
                    "Parking Capacity: ${(widget.booking.form.parkingCapacity == null) ? "-" : widget.booking.form.parkingCapacity}"),
                const SizedBox(height: 5),
                Text(
                    "Description: ${(widget.booking.form.description == null) ? "-" : widget.booking.form.description}")
              ])
      ]),
      floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.red,
          child: const Icon(Icons.delete,color:Colors.white),
          onPressed: () async {
            Ukumbi ukumbi = await getHallFromBooking(widget.booking);
            await deleteBooking(widget.booking);
          }),
    );
  }
}
