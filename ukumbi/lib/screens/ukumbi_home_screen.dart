import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ukumbi/custom_widgets.dart';
import 'package:ukumbi/screens/bookings.dart';
import '../modules.dart';
import '../ukumbi_listing.dart';
import 'filters_screen.dart';
import 'profile.dart';
import 'ukumbi_app_theme.dart';

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({Key key}):super(key:key);
  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  //List<HotelListData> hotelList = HotelListData.hotelList;
  final ScrollController _scrollController = ScrollController();
  Future<List<Ukumbi>> ukumbis;
  LoginStatus authentication;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 5));
  NavigationIndex navigator;
  Ukumbis ukumbiprovider;
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    ukumbis = getUkumbis();
    navigator = Provider.of<NavigationIndex>(context, listen: false);
    ukumbiprovider = Provider.of<Ukumbis>(context, listen: false);
    ukumbis.then((halls){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
        ukumbiprovider.initialize(halls);
      });
    });
    authentication = Provider.of<LoginStatus>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      navigator.changeIndex(0);
    });

    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HotelAppTheme.buildLightTheme(),
      child: Consumer<LoginStatus>(builder: (context, loginStatus, child) {
        return FutureBuilder(
            initialData: User(username: "NULL"),
            future: readUser(),
            builder: (context, snapshot) {
              return Consumer<NavigationIndex>(
                  builder: (context, navigationIndex, child) {
                return Scaffold(
                    //drawer: const HomeDrawer(),
                    body: Stack(
                      children: <Widget>[
                        InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Builder(
                                //stream: null,
                                builder: (context) {
                              switch (navigationIndex.index) {
                                case 0:
                                  return ukumbiListBody(context);
                                  break;
                                case 1:
                                  return (snapshot.data.username == "NULL")
                                      ? const Profile()
                                      : Bookings(snapshot.data);
                                case 2:
                                  return const Profile();
                                default:
                                  return ukumbiListBody(context);
                                  break;
                              }
                            })),
                      ],
                    ),
                    bottomNavigationBar: Container(
                        decoration: const BoxDecoration(boxShadow: [
                          BoxShadow(color: Colors.black, blurRadius: 1)
                        ]),
                        child: Builder(
                            //stream: null,
                            builder: (context) {
                          List<BottomNavigationBarItem> items = [];
                          items.add(const BottomNavigationBarItem(
                              icon: Icon(Icons.home), label: "Home"));
                          if (snapshot.data.username != "NULL") {
                            items.add(const BottomNavigationBarItem(
                                icon: Icon(Icons.bookmarks),
                                label: "My Bookings"));
                          }
                          items.add(BottomNavigationBarItem(
                              icon: const Icon(Icons.person),
                              label: (snapshot.data.username == "NULL")
                                  ? "Login"
                                  : "Profile"));
                          return BottomNavigationBar(
                            currentIndex: navigationIndex.index,
                            items: items,
                            onTap: (index) {
                              NavigationIndex navigator =
                                  Provider.of<NavigationIndex>(context,
                                      listen: false);
                              navigator.changeIndex(index);
                            },
                          );
                        })));
              });
            });
      }),
    );
  }

  Widget ukumbiListBody(BuildContext context) {
    return Column(
      children: <Widget>[
        getAppBarUI(),
        Expanded(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        getSearchBarUI(),
                        //getTimeDateUI(),
                      ],
                    );
                  }, childCount: 1),
                ),
              ];
            },
            body: Container(
              color: HotelAppTheme.buildLightTheme().backgroundColor,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    ukumbis = getUkumbis();
                  });
                },
                child: FutureBuilder(
                    future: ukumbis,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Consumer<Ukumbis>(
                          builder: (context, halls, child) {
                        return Column(
                          children: [
                            getFilterBarUI(halls.ukumbis),
                            Expanded(
                              child: ListView.builder(
                                itemCount: halls.ukumbis.length,
                                padding: const EdgeInsets.only(top: 8),
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  final int count = halls.ukumbis.length > 10
                                      ? 10
                                      : halls.ukumbis.length;
                                  final Animation<double> animation =
                                      Tween<double>(begin: 0.0, end: 1.0)
                                          .animate(CurvedAnimation(
                                              parent: animationController,
                                              curve: Interval(
                                                  (1 / count) * index, 1.0,
                                                  curve:
                                                      Curves.fastOutSlowIn)));
                                  animationController.forward();

                                  return UkumbiListView(
                                    callback: () {},
                                    ukumbi: halls.ukumbis[index],
                                    animation: animation,
                                    animationController: animationController,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      });
                    }),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getUkumbiViewList(List<Ukumbi> ukumbis) {
    final List<Widget> ukumbiListViews = <Widget>[];
    for (int i = 0; i < ukumbis.length; i++) {
      final int count = ukumbis.length;
      final Animation<double> animation =
          Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval((1 / count) * i, 1.0, curve: Curves.fastOutSlowIn),
        ),
      );
      ukumbiListViews.add(
        UkumbiListView(
          callback: () {},
          ukumbi: ukumbis[i],
          animation: animation,
          animationController: animationController,
        ),
      );
    }
    animationController.forward();
    return Column(
      children: ukumbiListViews,
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: HotelAppTheme.buildLightTheme().backgroundColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(38.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 4, bottom: 4),
                  child: TextField(
                    controller: search,
                    onSubmitted: (String txt) {
                      if (search.text.isEmpty) {
                        ukumbiprovider.resetDefault();
                      } else {
                        List<Ukumbi> filtered =
                            searchEngine(ukumbiprovider.defaultUkumbis, txt);
                        ukumbiprovider.updateHalls(filtered);
                      }
                    },
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    cursorColor: HotelAppTheme.buildLightTheme().primaryColor,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for a hall',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: HotelAppTheme.buildLightTheme().primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(38.0),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 8.0),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (search.text.isEmpty) {
                    ukumbiprovider.resetDefault();
                  } else {
                    List<Ukumbi> filtered = searchEngine(
                        ukumbiprovider.defaultUkumbis, search.text);
                    ukumbiprovider.updateHalls(filtered);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.search,
                      size: 20,
                      color: HotelAppTheme.buildLightTheme().backgroundColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getFilterBarUI(List<Ukumbi> ukumbis) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: HotelAppTheme.buildLightTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 8.0),
              ],
            ),
          ),
        ),
        Container(
          color: HotelAppTheme.buildLightTheme().backgroundColor,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${ukumbiprovider.ukumbis.length.toString()} hall(s) available',
                      style: const TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => const FiltersScreen(),
                            fullscreenDialog: true),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          const Text(
                            'Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.sort,
                                color: HotelAppTheme.buildLightTheme()
                                    .primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  void showDemoDialog({BuildContext context}) {

  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: HotelAppTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[

            SizedBox(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: const Center(
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

class ContestTabHeader extends SliverPersistentHeaderDelegate {
  ContestTabHeader(
    this.searchUI,
  );
  final Widget searchUI;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return searchUI;
  }

  @override
  double get maxExtent => 52.0;

  @override
  double get minExtent => 52.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
