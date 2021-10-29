import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi_web/widgets.dart';

import 'functions.dart';
import 'responsive.dart';

class RegisterHall extends StatefulWidget {
  final Owner owner;
  const RegisterHall({Key key, this.owner}) : super(key: key);

  @override
  State<RegisterHall> createState() => _RegisterHallState();
}

class _RegisterHallState extends State<RegisterHall> {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  StreamController<String> feedback = BehaviorSubject();
  TextEditingController seatingCapacity = TextEditingController();
  TextEditingController parkingCapacity = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController services = TextEditingController();
  StreamController<String> imageFiles = BehaviorSubject();
  StreamController<String> videoFiles = BehaviorSubject();
  FilePickerResult images, videos;
  @override
  void dispose() {
    name.dispose();
    seatingCapacity.dispose();
    parkingCapacity.dispose();
    location.dispose();
    imageFiles.close();
    feedback.close();
    videoFiles.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextBox(
                hint: "Hall name",
                width: (!Responsive.isMobile(context))
                    ? MediaQuery.of(context).size.width * 0.3
                    : 250,
                height: 40,
                controller: name),
            const SizedBox(height: 10),
            TextBox(
                hint: "Seating Capacity",
                width: (!Responsive.isMobile(context))
                    ? MediaQuery.of(context).size.width * 0.3
                    : 250,
                height: 40,
                controller: seatingCapacity),
            const SizedBox(height: 10),
            TextBox(
                hint: "Parking Capacity",
                width: (!Responsive.isMobile(context))
                    ? MediaQuery.of(context).size.width * 0.3
                    : 250,
                height: 40,
                controller: parkingCapacity),
            const SizedBox(height: 10),
            TextBox(
                hint: "Price",
                width: (!Responsive.isMobile(context))
                    ? MediaQuery.of(context).size.width * 0.3
                    : 250,
                height: 40,
                controller: price),
            const SizedBox(height: 10),
            TextBox(
                hint: "Location",
                width: (!Responsive.isMobile(context))
                    ? MediaQuery.of(context).size.width * 0.3
                    : 250,
                height: 40,
                controller: location),
            const SizedBox(height: 10),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Images"),
                      onPressed: () async {
                        try {
                          String names = "";
                          images = await FilePicker.platform.pickFiles(
                              allowMultiple: true, type: FileType.image);
                          for (int n = 0; n < images.files.length; ++n) {
                            names += images.files[n].name + ", ";
                          }
                          imageFiles.add(names);
                        } catch (err) {
                          images = null;
                        }
                      }),
                  StreamBuilder(
                      stream: imageFiles.stream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return Text(snapshot.data,
                            overflow: TextOverflow.ellipsis, maxLines: 3);
                      })
                ]),
            const SizedBox(height: 10),
            Column(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Videos"),
                  onPressed: () async {
                    try {
                      String names = "";
                      videos = await FilePicker.platform
                          .pickFiles(allowMultiple: true, type: FileType.video);
                      for (int n = 0; n < videos.count; ++n) {
                        names += videos.files[n].name + ", ";
                      }
                      videoFiles.add(names);
                    } catch (err) {
                      videos = null;
                    }
                  }),
              StreamBuilder(
                  stream: videoFiles.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    return Text(snapshot.data,
                        overflow: TextOverflow.ellipsis, maxLines: 3);
                  })
            ]),
            const SizedBox(height: 10),
            TextBox(
                hint: "Services",
                height: 100,
                controller: services,
                width: MediaQuery.of(context).size.width * 0.5),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    //height:60,
                    child: ElevatedButton(
                        child: const Text("Register"),
                        onPressed: () async {
                          if (name.text.isEmpty ||
                              location.text.isEmpty ||
                              price.text.isEmpty) {
                            feedback.add(
                                "Name, price or location should not be empty");
                            return;
                          }
                          Ukumbi ukumbi = Ukumbi(
                              price: int.parse(price.text),
                              location: location.text,
                              name: name.text);
                          //int seats,parking;
                          ukumbi.description = services.text;
                          if (seatingCapacity.text.isNotEmpty) {
                            ukumbi.seatCapacity =
                                int.parse(seatingCapacity.text);
                          }
                          if (parkingCapacity.text.isNotEmpty) {
                            ukumbi.parkingCapacity =
                                int.parse(parkingCapacity.text);
                          }
                          Ukumbi response = await submitUkumbi(
                              widget.owner, ukumbi, images, videos, feedback);
                          if (response != null) {
                            Ukumbis ukumbis =
                                Provider.of<Ukumbis>(context, listen: false);
                            ukumbis.addUkumbi(response);
                          }
                        })),
              ],
            ),
            StreamBuilder(
                stream: feedback.stream,
                initialData: "",
                builder: (context, snapshot) {
                  return Text(snapshot.data);
                }),
          ],
        ),
      ],
    );
  }
}

Widget footer() {
  return Row(children: []);
}
