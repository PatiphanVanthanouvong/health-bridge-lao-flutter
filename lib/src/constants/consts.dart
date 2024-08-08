import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class AppConstants {
  var factype = [
    "ທັງໝົດ",
    "ໂຮງໝໍ",
    "ຮ້ານຂາຍຢາ",
    "ຄຣີນິກ",
  ];
  static const String urlTemplate =
      "https://api.mapbox.com/styles/v1/shokoon/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}";
  static const String mapBoxAccessToken =
      'pk.eyJ1Ijoic2hva29vbiIsImEiOiJjbHF4bTVhaTcwZmdrMmpwbnQ3b2FuOGZjIn0.LVhMtRulH3CH7Rhv-z6gFg';

  static const String mapBoxStyleId = 'clrkgfe35001k01o30vhh774o';
  static const myLocation = LatLng(17.93989780704017, 102.62446715506951);
}

const kprimaryColor = Color(0xff212C42);
const ksecondryColor = Color(0xff9CA2FF);
const ksecondryLightColor = Color(0xffEDEFFE);
const klightContentColor = Color(0xffF1F2F7);

const double kbigFontSize = 25;
const double knormalFontSize = 18;
const double ksmallFontSize = 15;
