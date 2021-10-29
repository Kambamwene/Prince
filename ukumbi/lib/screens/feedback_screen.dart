import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi/modules.dart';

import '../custom_widgets.dart';
import 'app_theme.dart';
import 'ukumbi_app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  final Ukumbi ukumbi;
  final User user;
  const FeedbackScreen({Key key, this.ukumbi, this.user}) : super(key: key);
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  StreamController<String> feedback = BehaviorSubject();
  TextEditingController review = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 16,
                        right: 16),
                    child: (widget.ukumbi.reviews.isEmpty)
                        ? Image.asset('assets/images/feedbackImage.png')
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 10),
                            shrinkWrap: true,
                            itemCount: widget.ukumbi.reviews.length,
                            itemBuilder: (context, index) {
                              return ReviewCard(widget.ukumbi.reviews[index],widget.user);
                            },
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                          ),
                  ),
                  (widget.ukumbi.reviews.isEmpty)
                      ? Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: const Text(
                            'Your Review',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      (widget.ukumbi.reviews.isNotEmpty)
                          ? 'Add a review.'
                          : 'Be the first to add a review.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildComposer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: (widget.user.username == "NULL")
                          ? const Text("You must be logged in to add a review",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red))
                          : Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      offset: const Offset(4, 4),
                                      blurRadius: 8.0),
                                ],
                              ),
                              child: Material(
                                color: HotelAppTheme.buildLightTheme()
                                    .primaryColor,
                                child: InkWell(
                                  onTap: () async {
                                    //FocusScope.of(context).requestFocus(FocusNode());
                                    if (review.text.isEmpty) {
                                      feedback.add(
                                          "You cannot submit an empty review");

                                      return;
                                    }
                                    dynamic response = await addReview(
                                        widget.ukumbi,
                                        widget.user,
                                        review.text,
                                        feedback);
                                    if (response != null) {
                                      setState(() {
                                        widget.ukumbi.reviews.add(response);
                                      });
                                      UkumbiProvider ukumbi =
                                          Provider.of<UkumbiProvider>(context,
                                              listen: false);
                                      ukumbi.setUkumbi(widget.ukumbi);
                                    }
                                  },
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text(
                                        'Send',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  StreamBuilder<Object>(
                      stream: feedback.stream,
                      initialData: "",
                      builder: (context, snapshot) {
                        return Text(snapshot.data);
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                offset: const Offset(4, 4),
                blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
            color: AppTheme.white,
            child: TextField(
              controller: review,
              maxLines: null,
              onChanged: (String txt) {},
              style: const TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 16,
                color: AppTheme.dark_grey,
              ),
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Enter your feedback...'),
            ),
          ),
        ),
      ),
    );
  }
}

Widget ReviewCard(Review review,User user) {
  return Card(
      //elevation: 4,
      child: FutureBuilder(
          future: getReviewer(review.user),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                //isThreeLine: true,
                title: Text((snapshot.data.name==user.name)?"You":snapshot.data.name),
                leading: (snapshot.data.dp == null)
                    ? Container(
                        //height:60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.grey[100]),
                        child: const Icon(Icons.person))
                    : CircleAvatar(
                        radius: 30,
                        foregroundImage:
                            CachedNetworkImageProvider(snapshot.data.dp)),
                subtitle: Text(review.comment),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }));
}
