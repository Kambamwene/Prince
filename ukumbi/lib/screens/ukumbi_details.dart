import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ukumbi/screens/feedback_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets.dart';
import '../modules.dart';
import 'booking_calendar.dart';
import 'ukumbi_app_theme.dart';

List<Color> tabColors = [
  HotelAppTheme.buildLightTheme().primaryColorDark,
  HotelAppTheme.buildLightTheme().primaryColor,
  HotelAppTheme.buildLightTheme().primaryColor
];
int tabSelect = 0;

class UkumbiDetailsPage extends StatefulWidget {
  Ukumbi ukumbi;
  UkumbiDetailsPage({Key key, this.ukumbi}) : super(key: key);

  @override
  State<UkumbiDetailsPage> createState() => _UkumbiDetailsPageState();
}

class _UkumbiDetailsPageState extends State<UkumbiDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UkumbiProvider>(builder: (context, ukumbi, child) {
        ukumbi.ukumbi = widget.ukumbi;
        return ListView(
          padding: const EdgeInsets.only(top: 0),
          //clipBehavior:Clip.hardEdge,
          children: <Widget>[
            Stack(children: [
              Container(
                  foregroundDecoration:
                      const BoxDecoration(color: Colors.black26),
                  height: 300,
                  child: Swiper(
                      pagination: const SwiperPagination(),
                      itemCount: ukumbi.ukumbi.images.length,
                      //autoplay: true,
                      //pagination:const SwiperPagination(),
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                            imageUrl: ukumbi.ukumbi.images[index],
                            placeholder: (context, _) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                            fit: BoxFit.cover);
                      })),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                ),
              ),
              Positioned.fill(
                  top: (MediaQuery.of(context).padding.top) + 10,
                  right: 5,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.person),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    child: FutureBuilder(
                                        future: getUkumbiOwner(ukumbi.ukumbi),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox(
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            );
                                          }
                                          return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      color: Colors.grey[300],
                                                      width: double.infinity,
                                                      //radius:60,
                                                      child: snapshot.data.dp ==
                                                              null
                                                          ? const Icon(
                                                              Icons.person)
                                                          : CachedNetworkImage(
                                                              imageUrl: snapshot
                                                                  .data.dp,
                                                              height: 250),
                                                    ),
                                                    Positioned(
                                                        //top: 10,
                                                        right: 5,
                                                        child: PopupMenuButton<
                                                            int>(
                                                          itemBuilder:
                                                              (context) {
                                                            return const [
                                                              PopupMenuItem(
                                                                  child: Text(
                                                                    "Call",
                                                                  ),
                                                                  value: 0),
                                                              PopupMenuItem(
                                                                  child: Text(
                                                                      "Message"),
                                                                  value: 1)
                                                            ];
                                                          },
                                                          onSelected:
                                                              (value) async {
                                                            if (snapshot.data !=
                                                                null) {
                                                              switch (value) {
                                                                case 0:
                                                                  await launch(
                                                                      "tel:${snapshot.data.phoneNumber}");
                                                                  break;
                                                                case 1:
                                                                  await launch(
                                                                      "sms:${snapshot.data.phoneNumber}");
                                                                  break;
                                                                default:
                                                                  return;
                                                              }
                                                            }
                                                          },
                                                        ))
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(snapshot.data.name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                //const SizedBox(height:15),
                                              ]);
                                        }));
                              });
                        },
                      ),
                    ),
                  )),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //const SizedBox(height: 250),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            ukumbi.ukumbi.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: <Widget>[
                              const SizedBox(width: 16.0),
                              GestureDetector(
                                onTap: () {
                                  //print("tapped");
                                  Get.bottomSheet(FutureBuilder(
                                      future: readUser(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return FeedbackScreen(
                                              ukumbi: ukumbi.ukumbi,
                                              user: snapshot.data);
                                        }
                                        return const SizedBox.shrink();
                                      }));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: Text(
                                    "${ukumbi.ukumbi.reviews.length.toString()} review(s)",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13.0),
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ]),
            Container(
              padding: const EdgeInsets.only(top: 32.0, right: 32, left: 32),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text.rich(
                              TextSpan(children: [
                                const WidgetSpan(
                                    child: Icon(
                                  Icons.location_on,
                                  size: 21.0,
                                  color: Colors.grey,
                                )),
                                TextSpan(text: ukumbi.ukumbi.location)
                              ]),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 18.0),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "${currencyFormatter(ukumbi.ukumbi.price)} TZS",
                            style: TextStyle(
                                color: HotelAppTheme.buildLightTheme()
                                    .primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                          /*Text("/per night",style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey
                                ),)*/
                        ],
                      )
                    ],
                  ),
                  //const SizedBox(height: 30.0),
                  SizedBox(
                    width: double.infinity,
                    child: FutureBuilder(
                        future: readUser(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          return Builder(builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              //mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    color: HotelAppTheme.buildLightTheme()
                                        .primaryColor,
                                    textColor: Colors.white,
                                    child: const Text(
                                      "Book Now",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal: 32.0,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                                child: BookingCalendar(
                                                    user: snapshot.data,
                                                    ukumbi: ukumbi.ukumbi));
                                          });
                                    })
                              ],
                            );
                          });
                        }),
                  ),
                  const SizedBox(height: 10.0),
                  StatefulBuilder(builder: (context, setState) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(
                                "Services".toUpperCase(),
                                style: TextStyle(
                                    color: tabColors[0],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  tabColors = [
                                    HotelAppTheme.buildLightTheme()
                                        .primaryColorDark,
                                    HotelAppTheme.buildLightTheme()
                                        .primaryColor,
                                    HotelAppTheme.buildLightTheme().primaryColor
                                  ];
                                  tabSelect = 0;
                                });
                              },
                            ),
                            TextButton(
                                child: Text(
                                  "Related".toUpperCase(),
                                  style: TextStyle(
                                      color: tabColors[1],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    tabColors = [
                                      HotelAppTheme.buildLightTheme()
                                          .primaryColor,
                                      HotelAppTheme.buildLightTheme()
                                          .primaryColorDark,
                                      HotelAppTheme.buildLightTheme()
                                          .primaryColor
                                    ];
                                    tabSelect = 1;
                                  });
                                }),
                          ],
                        ),
                        //const SizedBox(height: 10.0),
                        Builder(builder: (context) {
                          switch (tabSelect) {
                            case 0:
                              return Text(
                                ukumbi.ukumbi.description,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0),
                              );
                              break;
                            case 1:
                              return FutureBuilder(
                                  future: getRelatedUkumbi(ukumbi.ukumbi,
                                      range: 600000),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data.length == 0) {
                                        return const SizedBox(
                                          height: 100,
                                          child: Text(
                                              "No related halls could be found"),
                                        );
                                      }
                                      return SizedBox(
                                        height: 150,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          fullscreenDialog:
                                                              true,
                                                          builder: (context) =>
                                                              UkumbiDetailsPage(
                                                                  ukumbi: snapshot
                                                                          .data[
                                                                      index])));
                                                },
                                                child: RelatedCard(
                                                    snapshot.data[index]));
                                          },
                                          separatorBuilder: (context, index) {
                                            return const SizedBox(width: 5);
                                          },
                                        ),
                                      );
                                    }
                                    return const SizedBox(
                                      height: 100,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  });
                              break;

                            default:
                              return Text(
                                ukumbi.ukumbi.description,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0),
                              );
                          }
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget RelatedCard(Ukumbi ukumbi) {
  return Container(
    width: 150,
    margin: const EdgeInsets.symmetric(horizontal: 11.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: ukumbi.images[0],
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: HotelAppTheme.buildLightTheme().primaryColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(ukumbi.location,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(
                    "TZS ${currencyFormatter(ukumbi.price)}",
                    style: HotelAppTheme.buildLightTheme()
                        .textTheme
                        .subtitle
                        .apply(color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}
