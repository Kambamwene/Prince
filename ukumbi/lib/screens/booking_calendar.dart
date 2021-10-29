import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ukumbi/custom_widgets.dart';

import '../modules.dart';

class BookingCalendar extends StatefulWidget {
  Ukumbi ukumbi;
  final User user;
  BookingCalendar({Key key, this.ukumbi, this.user}) : super(key: key);

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  List<DateTime> bookedDays = [];
  DateTime rangeStart, rangeEnd;
  BookingForm form;
  StreamController<String> feedback = BehaviorSubject();
  @override
  Widget build(BuildContext context) {
    bookedDays = getBookedDates(widget.ukumbi);
    return ListView(
      children: [
        TableCalendar(
            onCalendarCreated: (controller) {},
            rangeStartDay: rangeStart,
            rangeEndDay: rangeEnd,
            rangeSelectionMode: RangeSelectionMode.enforced,
            onDayLongPressed: (date, focusedDate) {
              if (rangeEnd != null) {
                setState(() {
                  rangeStart = null;
                  rangeEnd = null;
                });
              }
              if (rangeStart == null) {
                setState(() {
                  rangeStart = date;
                });
              } else {
                setState(() {
                  rangeEnd = date;
                });
              }
            },
            calendarFormat: CalendarFormat.month,
            calendarBuilders:
                CalendarBuilders(defaultBuilder: (context, date, focusedDate) {
              bool available = true;
              for (int n = 0; n < bookedDays.length; ++n) {
                if (bookedDays[n].day == date.day &&
                    bookedDays[n].month == date.month &&
                    bookedDays[n].year == date.year) {
                  available = false;
                  break;
                }
              }
              return Text(date.day.toString(),
                  style: TextStyle(
                      color: (available == true) ? Colors.black : Colors.red));
            }),
            focusedDay: DateTime.now(),
            firstDay: DateTime.now(),
            lastDay: DateTime(DateTime.now().year + 1, 12, 31)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ButtonWidget(
            caption: "Book",
            onClick: () async {
              if (widget.user.username == "NULL") {
                feedback.add("You must be logged in to perform this function");
                return;
              }
              if (rangeStart == null) {
                feedback.add("You must select a date or a date range");
                return;
              }
              rangeEnd ??= rangeStart;
              feedback.add("Booking...");
              List<DateTime> selectedDates =
                  calculateDaysInterval(rangeStart, rangeEnd);
              bool invalid = false;
              for (int n = 0; n < selectedDates.length; ++n) {
                for (int m = 0; m < bookedDays.length; ++m) {
                  if (selectedDates[n].day == bookedDays[m].day &&
                      selectedDates[n].month == bookedDays[m].month &&
                      selectedDates[n].year == bookedDays[m].year) {
                    invalid = true;
                    break;
                  }
                }
                if (invalid) {
                  break;
                }
              }
              if (invalid) {
                feedback
                    .add("One or more of the selected dates is unavailable");
                return;
              }
              await showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController seats = TextEditingController();
                    TextEditingController parking = TextEditingController();
                    TextEditingController description = TextEditingController();
                    return Dialog(
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextBox(
                                      hint: "Seats required?",
                                      controller: seats),
                                  const SizedBox(height: 10),
                                  TextBox(
                                      hint: "Parking Space?",
                                      controller: parking),
                                  const SizedBox(height: 10),
                                  TextBox(
                                      hint: "Services desired?",
                                      controller: description),
                                  const SizedBox(height: 20),
                                  ButtonWidget(
                                      caption: "Submit",
                                      onClick: () {
                                        if (seats.text.isEmpty &&
                                            parking.text.isEmpty &&
                                            parking.text.isEmpty) {
                                          Navigator.of(context).pop();
                                          return;
                                        }
                                        form = BookingForm(
                                            description: description.text,
                                            parkingCapacity: parking.text,
                                            seatCapacity: seats.text);
                                        Navigator.of(context).pop();
                                        return;
                                      })
                                ],
                              ),
                            )));
                  });
              //feedback.add("done");
              //return;
              User user = await readUser();
              DateTime end;
              if (rangeEnd == null) {
                end = rangeStart;
              } else {
                end = rangeEnd;
              }
              dynamic response =
                  await book(user, rangeStart, widget.ukumbi, end: end,form:form);
              if (response != null) {
                feedback.add("Success");
                /*setState(() {
                  widget.ukumbi.bookings.add(response);
                });*/
                return;
              } else {
                feedback.add("There was an unexpected error");
                return;
              }
            },
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: StreamBuilder(
              initialData: "",
              stream: feedback.stream,
              builder: (context, snapshot) {
                return Text(snapshot.data, textAlign: TextAlign.center);
              }),
        ),
        const SizedBox(height: 5)
      ],
    );
  }
}
