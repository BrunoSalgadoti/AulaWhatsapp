import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/RouteGenerator.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contatos extends StatefulWidget {
  const Contatos({Key? key}) : super(key: key);

  @override
  _ContatosState createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {

  dynamic _idUsuarioLogado;
  dynamic _emailUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {

    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").get();

    List<Usuario> listaUsuarios = [];

    for (DocumentSnapshot item in querySnapshot.docs) {

      dynamic dados = item.data();

      //um teste para não mandar mensagem para vc mesmo
      if ( dados["email"] == _emailUsuarioLogado ) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagem = dados["urlImagem"];

      listaUsuarios.add(usuario);
    }
    return listaUsuarios;
  }

  //-----------Recuperando dados do usuário Logado no Firebase -------------------

  Future<dynamic> _recuperarDadosUsuario ( dynamic User) async {
    FirebaseAuth auth = await FirebaseAuth.instance;

    User = await auth.currentUser?.uid;
    User = await auth.currentUser?.email;

    dynamic usuarioLogado = User;
    _idUsuarioLogado = usuarioLogado;
    _emailUsuarioLogado = usuarioLogado;

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario(User);
  }

  //@override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando Contatos"),
                  CircularProgressIndicator()
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:

            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, indice) {

                  List<Usuario>? listaItens = snapshot.data;
                  Usuario usuario = listaItens![indice];

                  return ListTile(
                    //para iniciar abrir a aba de conversa de um contato
                    onTap: (){
                      Navigator.pushNamed(
                          context,
                         RouteGenerator.ROTA_MENSAGENS,
                          arguments: usuario
                      );
                    },
                    //--------------------------------------------------
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                        usuario.urlImagem != null
                            ?NetworkImage(usuario.urlImagem)
                            :null
                    ),
                    title: Text(
                      usuario.nome,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  );
                });
        }
      },
    );
  }
}
