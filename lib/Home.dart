import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/model/RouteGenerator.dart';
import 'package:whatsapp/paginas/Contatos.dart';
import 'package:whatsapp/paginas/Conversas.dart';
import 'dart:io';

class Home extends StatefulWidget {
   Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with
    SingleTickerProviderStateMixin{

  late TabController  _tabController;
  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];

  //------------------------Recuperar dados do usuário -------------------------

  String? _emailUsuario = "";
  _recuperarDadosUsuario () async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    setState(() {
      _emailUsuario = usuarioLogado!.email;
    });
  }

// -----------------Verificação se o usuário está logado------------------------
  Future<dynamic> _verificaUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;

    User? usuarioLogado = await auth.currentUser;

    if ( usuarioLogado == null ){

      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
    }
  }
//------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _verificaUsuarioLogado();
    _recuperarDadosUsuario();

    _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 0
    );}

  _escolhaMenuItem( String itemEscolhido){

    switch ( itemEscolhido ) {
      case "Configurações" :
        Navigator.pushNamed(context, RouteGenerator.ROTA_CONFIGURACOES);
        //print("Configurações");
        break;
      case "Deslogar" :
        _deslogarUsuario();
        break;
    }
    print("Item escolhido: " + itemEscolhido);
  }

 Future<dynamic> _deslogarUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);

    /*  Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Login()
        )
    );*/

  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(
          elevation: Platform.isIOS ?  0 : 4,
          title: Text("WhatssApp"),

          bottom: TabBar(
            indicatorWeight: 4,
            indicatorColor: Platform.isIOS ?  Colors.grey[400] : Colors.amberAccent,
            labelColor: Platform.isIOS ? Colors.black : Colors.white,

            labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),

            controller: _tabController,

            tabs:  [

              Tab(
                  child: Text("Conversas")
              ),

              Tab(
                  child: Text("Contatos")
              )
            ],),

          actions: <Widget> [
            PopupMenuButton<String>(

                onSelected: _escolhaMenuItem,
                itemBuilder: ( context ) {
                  return itensMenu.map( (String item){
                    return PopupMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList();
                }
            )],

        ),

        body: TabBarView(
          controller: _tabController,

          children: <Widget> [

            Conversas(),

            Contatos()

          ],)

    );
  }
}

