import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';


import 'package:app/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

void main() {
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new HomePage()
  ));
}

const kGoogleApiKey = "AIzaSyDtwCm5qw7S7ruArmqyZxE-pyIs4b9bNcs";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {

  Map data;
  Map res;
  var txt = TextEditingController();
  var place1;
  var txt1 = TextEditingController();
  var place2;
  int target = 1;


  Future<String> getData() async {
    if ((place1 != null)&&(place2 != null)) {

      var response = await http.get(
          Uri.encodeFull("https://maps.googleapis.com/maps/api/directions/json?origin=place_id:${place1}&destination=place_id:${place2}&key=AIzaSyDtwCm5qw7S7ruArmqyZxE-pyIs4b9bNcs"),
          headers: {
            "Accept": "application/json"
          }
      );
      res = json.decode(response.body);
      if(res['status'] == 'ZERO_RESULTS'){
        Fluttertoast.showToast(
            msg: "No Driving Route Found",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1);
        this.setState(() {
          data = null;
        });

      }else if (res['status'] == 'OK'){
        this.setState(() {
          data = json.decode(response.body);
        });
      }
    }
    else if ((place1 == null)&&(place2 != null))
      {
        Fluttertoast.showToast(
            msg: "Enter Starting Point",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1);
      }else if ((place2 == null)&&(place1 != null))
    {
      Fluttertoast.showToast(
          msg: "Enter Destination Point",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1);
    }else
      {
        Fluttertoast.showToast(
            msg: "Enter Starting and Destination Points",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1);
      }





  }


  @override
  Widget build(BuildContext context){
    return new Scaffold(

      appBar: new AppBar(title: new Text("Directions"), backgroundColor: Colors.green),
      body:new Container(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Container(

                height: 70,
                padding: EdgeInsets.all(10.0),
                color: Color(0x006fb7),
                child: TextField(

                  readOnly: true,
                  controller: txt,
                  onTap: () async {

                    Prediction p = await PlacesAutocomplete.show(
                        context: context, apiKey: kGoogleApiKey, mode: Mode.overlay, box:25);


                    if(p != null) {
                      displayPrediction(p);
                      PlacesDetailsResponse detail = await _places
                          .getDetailsByPlaceId(p.placeId);

                      txt.text = detail.result.name;
                      place1 = p.placeId;
                    }

                  },


                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Starting Point',
                    fillColor: Colors.white,
                    filled: true

                  ),
                ),
              ),
              Container(
                height: 70,
                padding: EdgeInsets.all(10.0),
                color: Color(0x006fb7),
                child: TextField(

                  readOnly: true,
                  onTap: () async {
                    Prediction p = await PlacesAutocomplete.show(
                        context: context, apiKey: kGoogleApiKey, mode: Mode.overlay, box:75);

    if(p != null) {
      displayPrediction(p);
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
          p.placeId);

      txt1.text = detail.result.name;
      place2 = p.placeId;
    }
                  },
                  controller: txt1,


                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Destination Point',
                      filled: true,
                      fillColor: Colors.white
                  ),
                ),
              ),
              Container(
                  height: 50,
                  padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                    onPressed:() {getData();},
                    child: Text('Lookup Directions'),

                  ),
              ),

              Container(
                height: MediaQuery.of(context).size.height/1.6,
                color: Color(0x006fb7),
                child: new ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(10.0),
                  itemCount: data == null ? 0 : data["routes"][0]["legs"][0]["steps"].length,
                  itemBuilder: (BuildContext context, int index){
                    return new Card(
                      child: new Container(
                        padding: EdgeInsets.all(10),
                        child: new Column(
                          children: <Widget>[

                            new Html(data: data["routes"][0]["legs"][0]["steps"][index]["html_instructions"],style: {"html": Style(padding: EdgeInsets.only(right:15))},),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: new Text(data["routes"][0]["legs"][0]["steps"][index]["distance"]["text"].toString(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                ),
                                Flexible(
                                  child: new Text(data["routes"][0]["legs"][0]["steps"][index]["duration"]["text"].toString(), textAlign : TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                )
                              ],
                            )
                          ],
                        ),
                      ),

                    );
                  },
                ),
              ),
            ],
          )

      ),
    );
  }
  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      if(target == 1){

      }


    }
  }



}

