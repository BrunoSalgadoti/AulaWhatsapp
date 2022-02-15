import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Configuracoes extends StatefulWidget {
   Configuracoes({Key? key}) : super(key: key);

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {

  //Controles
  TextEditingController _controllerNome = TextEditingController();


  //Variáveis do ambiente
  XFile? _imagem;
  bool _subindoImagem = false;
  dynamic _idUsuarioLogado;
  dynamic _urlImagemRecuperada;


//---------------Recuperando imagem da galeria ou da câmera --------------------
  Future<dynamic> _recuperarImagem (String origemImagem) async {

    ImagePicker Piker = ImagePicker();

    XFile? imagemSelecionada;


    switch ( origemImagem ){

      case "camera" :
        imagemSelecionada = await Piker.pickImage(source: ImageSource.camera);
        break;

      case "galeria" :
        imagemSelecionada = await Piker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if( _imagem != null){
        _subindoImagem = true;
        _uploadImagem();
      }
    });

  }

//------------- Fazendo o Upload da imagem selecionada para Storage-------------
  Future<dynamic> _uploadImagem( ) async {

    FirebaseStorage storage = await FirebaseStorage.instance;

    var file = File(_imagem!.path);

    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child('perfil')
        .child( "${_idUsuarioLogado}" + ".jpg" );

    //upload da imagem
    UploadTask task = arquivo.putFile(file);

    //controlar progresso do upload
    task.snapshotEvents.listen(( TaskSnapshot storageEvent ) {

      if ( storageEvent.state == TaskState.running){

        setState(() {
          _subindoImagem = true;
        });

      }else if( storageEvent.state == TaskState.success){

        setState(() {
          _subindoImagem = false;
        });

      }
    });

//-------------Recuperando a url da Imagem do Upload ---------------------------
    Future<dynamic> _recuperarUrlImagem (TaskSnapshot snapshot) async {

      String url = await snapshot.ref.getDownloadURL();
      //print("Resultado  url  " + url);

//recuperar imagem do banco firebaseFIRESTORE da função _atualizarUrlImagemFirestore
      _atualizarUrlImagemFirestore( url );

      setState(() {
        _urlImagemRecuperada = url;
      });
    }
    ////*
    task.then((TaskSnapshot snapshot){
      _recuperarUrlImagem( snapshot);
    });
  }

//----------Atualizar a URL da Imagem no FirebaseFIRESTORE----------------------
  Future<dynamic> _atualizarUrlImagemFirestore( dynamic url) async {

    FirebaseFirestore db = await FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "urlImagem" : url
    };

    await db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update( dadosAtualizar);
  }

//-----------Recuperando dados do usuário Logado no Firebase -------------------
  Future<dynamic> _recuperarDadosUsuario ( dynamic User) async {
    FirebaseAuth auth = await FirebaseAuth.instance;

    User = await auth.currentUser?.uid;

    String usuarioLogado = User;
    _idUsuarioLogado = usuarioLogado;


  //Recuperando dados do usuario do FIRESTORE (para menu "configurações)
    FirebaseFirestore db = await FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await db.collection("usuarios")
        .doc(_idUsuarioLogado!)
        .get();

    dynamic dados = await snapshot.data();

       _controllerNome.text = dados["nome"];

    if( dados["urlImagem"] != null ) {
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
        _controllerNome.text = dados["nome"];
      });

    }
  }

  //----------Atualizar o TEXTO no campofild FirebaseFIRESTORE------------------
  Future<dynamic> _atualizarNomeFirestore( ) async {

    String nome = _controllerNome.text; //Comentar esta linha se usar sem botão
    FirebaseFirestore db = await FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "nome" : nome
    };

    await db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update( dadosAtualizar);
  }
//------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario(User);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Configurações"),),

      body: Container(
        padding: EdgeInsets.all(16),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>  [

                //carregando
               Container(
                 padding: EdgeInsets.all(16),
                 child:  _subindoImagem == true
                     ? CircularProgressIndicator()
                     : Container(),
               ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                    _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada!)
                        :null
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget> [

                    ElevatedButton(
                      onPressed: (){
                        _recuperarImagem("camera");
                      },
                      child: Text("Câmera",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff075e54),),
                    ),

                    ElevatedButton(
                      onPressed: (){
                        _recuperarImagem("galeria");
                      },
                      child: Text("Galeria",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff075e54),),
                    )
                  ],),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
/*
                    //Salvando diretamente do textfild sem pressionar o botão
                    onChanged: (texto){
                      _atualizarNomeFirestore( texto );
                      //OBS: na função _atualizarNomeFirestore mudar a variável...
                      // nome do corpo para o parametro da função
                    },
                    //---------------------------------------------------------
*/
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),

                Padding(padding: EdgeInsets.only(top: 16, bottom: 10),

                  child: ElevatedButton(
                    onPressed: () {
                      _atualizarNomeFirestore();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shadowColor: Colors.black54,
                        elevation: 15,
                        padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),
              ],),
          ),

        ),),
    );
  }
}
