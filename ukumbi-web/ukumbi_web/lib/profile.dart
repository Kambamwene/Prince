import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi_web/widgets.dart';

import 'functions.dart';

class Profile extends StatefulWidget {
  final Owner owner;
  List<Ukumbi> ukumbis;
  Profile({Key key, this.owner, this.ukumbis}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Ukumbis kumbis;
  List<StreamController<String>> feedback = [];
  @override
  void initState() {
    kumbis = Provider.of<Ukumbis>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    for (int n = 0; n < feedback.length; ++n) {
      feedback[n].close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (widget.owner.dp != null)
                    ? CircleAvatar(
                        radius: 100,
                        foregroundImage: NetworkImage(widget.owner.dp))
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[300], shape: BoxShape.circle),
                        child: const Icon(Icons.person, size: 80)),
                const SizedBox(height: 5),
                Text(widget.owner.name)
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 5),
        const Center(child: Text("Your halls")),
        Consumer<Ukumbis>(builder: (context, ukumbis, child) {
          for (int n = 0; n < ukumbis.ukumbis.length; ++n) {
            feedback.add(BehaviorSubject());
          }
          return Expanded(
            child: (ukumbis.ukumbis.isEmpty)
                ? const Center(
                    child: Text("You currently have no halls registered"))
                : ListView.separated(
                    itemCount: ukumbis.ukumbis.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return Card(
                          color: Colors.grey[300],
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          children: [
                                            SizedBox(
                                                height: 150,
                                                child: Image.network(
                                                    ukumbis.ukumbis[index]
                                                        .images[0],
                                                    fit: BoxFit.cover)),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "Price: ${ukumbis.ukumbis[index].price.toString()} TZS"),
                                                SizedBox(height: 5),
                                                Text(
                                                    "Location: ${ukumbis.ukumbis[index].location}"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      //Expanded(child: SizedBox()),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              TextEditingController name =
                                                  TextEditingController(
                                                      text: widget
                                                          .ukumbis[index].name);
                                              TextEditingController price =
                                                  TextEditingController(
                                                      text: widget
                                                          .ukumbis[index].price
                                                          .toString());
                                              TextEditingController location =
                                                  TextEditingController(
                                                      text: widget
                                                          .ukumbis[index]
                                                          .location);
                                              StreamController<String>
                                                  feedback = BehaviorSubject();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                        child: Container(
                                                            width: 400,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            color: Colors.white,
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                TextField(
                                                                  controller:
                                                                      name,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          hintText:
                                                                              "Hall Name"),
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      price,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          hintText:
                                                                              "Price"),
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      location,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          hintText:
                                                                              "Location"),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child: ElevatedButton(
                                                                        onPressed: () async {
                                                                          if (name.text.isEmpty ||
                                                                              location.text.isEmpty ||
                                                                              price.text.isEmpty) {
                                                                            feedback.add("All fields must be filled");
                                                                            return;
                                                                          }
                                                                          feedback
                                                                              .add("Updating...");
                                                                          bool
                                                                              response =
                                                                              await updateHall({
                                                                            "houseId":
                                                                                widget.ukumbis[index].houseId,
                                                                            "name":
                                                                                name.text,
                                                                            "price":
                                                                                int.parse(price.text),
                                                                            "location":
                                                                                location.text
                                                                          });
                                                                          if (response) {
                                                                            List<Ukumbi>
                                                                                halls =
                                                                                await getAllUkumbis();
                                                                            ukumbis.setUkumbis(halls);
                                                                            feedback.add("Success");
                                                                          } else {
                                                                            feedback.add("Error");
                                                                          }
                                                                        },
                                                                        child: const Text("Update"))),
                                                                const SizedBox(
                                                                    height: 3),
                                                                StreamBuilder(
                                                                    initialData:
                                                                        "",
                                                                    stream: feedback
                                                                        .stream,
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      return Text(
                                                                          snapshot
                                                                              .data);
                                                                    })
                                                              ],
                                                            )));
                                                  });
                                            },
                                          ),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              for (int n = 0;
                                                  n < ukumbis.ukumbis.length;
                                                  ++n) {
                                                feedback[n].add(null);
                                              }
                                              String response =
                                                  await deleteUkumbi(
                                                      widget.owner,
                                                      widget.ukumbis[index],
                                                      feedback[index]);
                                              if (response == "SUCCESS") {
                                                ukumbis.deleteUkumbi(
                                                    widget.ukumbis[index]);
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  StreamBuilder(
                                      stream: feedback[index].stream,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }
                                        return Text(snapshot.data,
                                            textAlign: TextAlign.center);
                                      })
                                ],
                              )));
                    }),
          );
        })
      ],
    );
  }
}
