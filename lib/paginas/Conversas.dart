import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whatsapp/model/RouteGenerator.dart';
import 'package:whatsapp/model/Usuario.dart';

class Conversas extends StatefulWidget {
  const Conversas({Key? key}) : super(key: key);

  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {

  List<Conversa> _listaConversas = [];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late String _idUsuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario(User);
  }

  Stream<QuerySnapshot>? _adicionarListenerConversas ( ) {

    final stream = db.collection("conversas")
        .doc( _idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen(( dados ){
      _controller.add( dados );
    });
  }

  Future<dynamic> _recuperarDadosUsuario(dynamic User) async {
    FirebaseAuth auth = await FirebaseAuth.instance;

    User = await auth.currentUser?.uid;
    dynamic usuarioLogado = User;
    _idUsuarioLogado = usuarioLogado;

    _adicionarListenerConversas();

    setState(() {
      _idUsuarioLogado;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(

        stream: _controller.stream,

        builder: (context, AsyncSnapshot snapshot){

          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Carregando Conversas"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;

            case ConnectionState.active:
            case ConnectionState.done:

              if(snapshot.hasError) {
                return Text("Erro ao carregar os dados!!");
              }else{

                QuerySnapshot querySnapshot = snapshot.data;

                if( querySnapshot.docs.length == 0 ){
                  return Center(
                    child: Text("Você não tem nenhuma mensagem ainda :( ",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: querySnapshot.docs.length,

                    itemBuilder: ( context, indice ){

                      List<DocumentSnapshot> conversas = querySnapshot.docs.toList();
                      DocumentSnapshot item = conversas[ indice ];

                      String urlImagem      = item["caminhoFoto"];
                      String tipo           = item["tipoMensagem"];
                      String mensagem       = item["mensagem"];
                      String nome           = item["nome"];
                      String idDestinatario = item["idDestinatario"];

                      //Criando usuario para o navagator.push.Named
                      Usuario usuario = Usuario();
                      usuario.nome = nome;
                      usuario.urlImagem = urlImagem;
                      usuario.idUsuario = idDestinatario;

                      return ListTile(
                        onTap: (){
                          Navigator.pushNamed(
                              context,
                              RouteGenerator.ROTA_MENSAGENS,
                              arguments: usuario
                          );
                        },
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor:  Colors.grey,
                          backgroundImage: urlImagem != null
                              ?NetworkImage (urlImagem)
                              :null,
                        ),

                        title: Text(
                          nome,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white
                          ),),
                        subtitle: Text(
                          tipo == "texto"
                              ? mensagem
                              : "Imagem ...",
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14
                          ),
                        ),
                      );
                    }
                );
              }
          }
        }
    );
  }
}
