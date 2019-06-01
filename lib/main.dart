import 'dart:async';
import 'dart:convert';

import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

void main() {
  runApp(new MaterialApp(home: new BlogList()));
}

class BlogList extends StatefulWidget {
  @override
  BlogListState createState() => new BlogListState();
}

class BlogListState extends State<BlogList> {
  List bloglist;

  Future<String> getbloglist() async {
    var response = await http.get(
        Uri.encodeFull("http://ted-bud-blog.herokuapp.com/api/"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      bloglist = json.decode(response.body);
    });
    return "Success";
  }

  void navigateToDetail(int id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlogDetail(
                  id: id,
                )));
  }

  @override
  void initState() {
    this.getbloglist();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("BUDTED BLOG"), backgroundColor: Colors.deepPurple),
      body: new Container(
          padding: new EdgeInsets.all(15.0),
          child: new RefreshIndicator(
            child: new ListView.builder(
              itemCount: bloglist == null ? 0 : bloglist.length,
              itemBuilder: (BuildContext context, int index) {
                return new Padding(
                  padding: new EdgeInsets.only(bottom: 15),
                  child: new Card(
                  child: new InkWell(
                    onTap: () {
                      navigateToDetail(bloglist[index]['id']);
                    },
                    child: new Container(
                      padding: new EdgeInsets.all(15.0),
                      child: new Column(
                        children: <Widget>[
                          new Text(
                            bloglist[index]['title'].toUpperCase(),
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          new Padding(
                            padding: new EdgeInsets.only(bottom: 15),
                          ),
                          bloglist[index]['imageurl'] == null
                              ? new Text('')
                              : new Image.network(
                                  bloglist[index]['imageurl']),
                          new Padding(
                            padding: new EdgeInsets.only(bottom: 15),
                          ),
                          new Text(
                            bloglist[index]['description'],
                            textAlign: TextAlign.justify,
                            style: new TextStyle(fontSize: 15),
                          )
                        ],
                      ),
                    ))),
                );
              },
            ),
            onRefresh: getbloglist,
          )),
    );
  }
}

class BlogDetail extends StatefulWidget {
  final int id;
  BlogDetail({this.id});
  @override
  BlogDetailState createState() => new BlogDetailState();
}

class BlogDetailState extends State<BlogDetail> {
  Map detail;
  String title;
  String content;
  String image;

  Future<String> getdetail() async {
    var response = await http.get(
        Uri.encodeFull("http://ted-bud-blog.herokuapp.com/api/${widget.id}"),
        headers: {"Accept": "application/json"});
    this.setState(() {
      detail = json.decode(response.body);
      title = detail['title'];
      content = detail['content'];
      image = detail['imageurl'];
    });
    return "Success";
  }

  @override
  void initState() {
    this.getdetail();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('BUDTED BLOG'), backgroundColor: Colors.deepPurple),
      body: new Container(
          padding: new EdgeInsets.all(15.0),
          child: new SingleChildScrollView(
            child: new Card(
                child: new Container(
              padding: new EdgeInsets.all(15),
              child: new Column(
                children: <Widget>[
                  new Text(
                    '${title ?? ''}'.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 15),
                  ),
                  image == null
                      ? new Text('')
                      : new Image.network('${image ?? ''}'),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 15),
                  ),
                  new Html(data: '${content ?? ''}'),
                ],
              ),
            )),
          )
          ),
    );
  }
}
