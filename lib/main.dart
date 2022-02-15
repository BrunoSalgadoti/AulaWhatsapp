import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/model/RouteGenerator.dart';
import 'Cadastro.dart';
import 'dart:core';

//Temas diferenciados para android e ios

//thema ANDROID
final ThemeData temaPadrao = ThemeData(
  //primaryColor: Color(0xff075e54),
  scaffoldBackgroundColor: Color(0xff022b29),
  scrollbarTheme: ScrollbarThemeData(
    showTrackOnHover: false,
    mainAxisMargin: 0.0,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff008482),
  ),);

//thema IOS
final ThemeData temaIos = ThemeData(
  //primaryColor: Color(0xffe3fffc),
  scaffoldBackgroundColor: Colors.grey[200],
  scrollbarTheme: ScrollbarThemeData(
    showTrackOnHover: false,
    mainAxisMargin: 0.0,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xffc1f6f5),
  ),);




void main() async {

  //Iniciar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //Teste inicial cadastro de usuário no firebase
  //Future<dynamic>  user  = cadastroUsuario();
  //user;

   runApp(  MaterialApp(

     home: Login(),

//----------tema de cores e estilos para todas as páginas do APP----------------

     theme: Platform.isIOS ? temaIos : temaPadrao,
//------------------------------------------------------------------------------
//----------------------------Rotas Nomeadas------------------------------------

   initialRoute: "/",

     onGenerateRoute: RouteGenerator.generateRoute,

     //outro método
     /*routes: {
       "/login" : (context) => Login(),
      "/home" : (context) => Login()

    },*/

    title: "Aula Flutter WatssApp",
    debugShowCheckedModeBanner: false,
  ));
}
