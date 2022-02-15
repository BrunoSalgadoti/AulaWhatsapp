import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Mensagens extends StatefulWidget {

  Usuario contato;
  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

  XFile? _imagem;
  late String  _idUsuarioLogado;
  late String _idUsuarioDestinatario;
  bool _subindoImagem = false;
  var origemImagem;
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

class _MensagensState extends State<Mensagens> {

  _eviarMensagem() {

    dynamic textoMensagem = _controllerMensagem.text;

    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = "texto";

      // Salvar mensagem para remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      // Salvar mensagem para destinatário
      _salvarMensagem( _idUsuarioDestinatario, _idUsuarioLogado,  mensagem);

      //salvar Conversa
      _salvarConversa( mensagem );


    }
  }

  _salvarConversa ( Mensagem msg /* mensagem*/ ){

    //Mensagem(); teste para o futuro se não funcionar novamente
    //dynamic msg = Mensagem;

    //Salvar conversa Remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //Salvar cconversa Destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();

  }

  Future<dynamic> _salvarMensagem(dynamic idRementente, dynamic IdDestinatario, Mensagem msg) async {

    //instancia do Firebase iniciada como atributo (onde declara as variáveis)

    await db.collection("mensagens")
        .doc(idRementente)
        .collection(IdDestinatario)
        .add(msg.toMap());

    //limpar texto
    _controllerMensagem.clear();
  }

  Future<dynamic> _eviarFoto( ) async {

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
      }
    });

    String nomeImagem = DateTime.now().microsecondsSinceEpoch.toString();
    var file = File(_imagem!.path);

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpg");

    //upload da imagem
    UploadTask task = arquivo.putFile(file);

    //controlar progresso do upload
    task.snapshotEvents.listen((TaskSnapshot storageEvent) {
      if (storageEvent.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.state == TaskState.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    //recupera url imagem
    task.then((TaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  //-------------Recuperando a url da Imagem do Upload ---------------------------
  Future<dynamic> _recuperarUrlImagem (TaskSnapshot snapshot) async {

    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = "imagem";

    // Salvar mensagem para remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    // Salvar mensagem para destinatário
    _salvarMensagem( _idUsuarioDestinatario, _idUsuarioLogado,  mensagem);

  }

  Future<dynamic> _recuperarDadosUsuario(dynamic User) async {
    FirebaseAuth auth = await FirebaseAuth.instance;

    User = await auth.currentUser?.uid;
    dynamic usuarioLogado = User;
    _idUsuarioLogado = usuarioLogado;

    _idUsuarioDestinatario = widget.contato.idUsuario;

    _adicionarListenerMensagens();

    setState(() {
      _idUsuarioLogado;
      _idUsuarioDestinatario;
    });
  }

  Stream<QuerySnapshot>? _adicionarListenerMensagens ( ) {

    final stream = db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
         .orderBy("data", descending: false)
        .snapshots();

    stream.listen(( dados ){
      _controller.add( dados );
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario(User);
  }

  @override
  Widget build(BuildContext context) {
// uma variável que contém um Container() --OBS: Pode-se fazer em uma página...-

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),

      child: Row(
        children: <Widget>[

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),

                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    suffixIcon:
                    _subindoImagem
                        ? CircularProgressIndicator()
                        : IconButton(
                        color: Color(0xfff20a393),
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Text("Escolha de onde deseja enviar a Foto"),
                                  ),

                                  actions: <Widget>[
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[

                                          ElevatedButton(
                                            onPressed: (){
                                              origemImagem = "camera";
                                              _eviarFoto();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Camera",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.redAccent,
                                              shadowColor: Colors.black,
                                            ),
                                          ),

                                          ElevatedButton(
                                            onPressed: () {
                                              origemImagem = "galeria";
                                              _eviarFoto();
                                              Navigator.pop(context);
                                            },

                                            child: const Text("Galeria",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              shadowColor: Colors.black,
                                              elevation: 8,
                                              //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                            ),
                                          ),
                                        ])
                                  ],);
                              });}
                    )
                ),
              ),
            ),),

          Platform.isIOS
              ? CupertinoButton(
            child: Text("Enviar"),
            onPressed:  _eviarMensagem,
          )
              : FloatingActionButton(
            backgroundColor: Color(0xff075e54),
            child: Icon(Icons.send, color: Colors.white,),
            mini: true,
            onPressed: _eviarMensagem,
          )

        ],
      ),
    );
//------------------------------------------------------------------------------
    var stream = StreamBuilder(

        stream: _controller.stream,

        builder: (context,
            AsyncSnapshot snapshot) { //para o stream colocar AsyncSnapshot

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Carregando Mensagens"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;

              if (snapshot.hasError) {
                return Text("Erro ao carregar os dados!!");
              } else {
                return Expanded(

                  child: ListView.builder(
                      controller: _scrollController,

                      itemCount: querySnapshot.docs.length,

                      itemBuilder: (context, indice) {
                        //recuperar mensagem
                        List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();
                        DocumentSnapshot item = mensagens[ indice ];

                        double larguraContainer =
                            MediaQuery.of(context).size.width * 0.8; //////

                        // Regra de 3  //////
                        //larguraContainer  -> x 80 / 100
                        //x                 -> 80

                        //Definir cores e alinhamentos das mensagens------------
                        Alignment alinhamento = Alignment.centerRight;
                        Color cor = Color(0xffd2ffa5);
//---------------------------só para teste de inicio e explicação --------------
                        //testando condições para alinhamento das MSG impar e pares ficar na Direita e Esquerda
                        //porcentagem == resto da divisão -> objetivo que o resto da div seja par

                        //if (indice % 2 == 0) { // sendo PAR comando abaixo:
//------------------------------------------------------------------------------
                        if (_idUsuarioLogado != item["idUsuario"]) {
                          alinhamento = Alignment.centerLeft;
                          cor = Colors.white;
                        }

                        return Align(
                          alignment: alinhamento,
                          child: Padding(
                            padding: EdgeInsets.all(6),

                            child: Container(
                              width: larguraContainer, ///////
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),),
                              ),

                              //larguraContainer.toString() + " ++ " + // Ver a largura do Container
                              child: item["tipo"] == "texto"
                                  ? Text(item["mensagem"],style: TextStyle(fontSize: 18),)
                                  : Image.network(item["urlImagem"]),
                            ),
                          ),);
                      }),);
              }
          }
        });

    //var listView = ; // Trocado por StreamBuilder que monitora mudanças

//------------------------------------------------------------------------------
    return Scaffold(

      appBar: AppBar(
          title: Row(
            children: <Widget>[

              CircleAvatar(
                  maxRadius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                  widget.contato.urlImagem != null
                      ? NetworkImage(widget.contato.urlImagem)
                      : null
              ),
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text(widget.contato.nome),
              )
            ],)
      ),

      body: Container(
//----------Colocando uma figura como BackGround -------------------------------
        width: MediaQuery
            .of(context)
            .size
            .width, //faz o container ocupar toda a area disponível
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    "imagens/bg.png"),
                fit: BoxFit
                    .cover // faz o container cobrir toda a área vertical
            )),
//------------------------------------------------------------------------------
        //Safeare ajusta o conteudo na tela do IOS
        child: SafeArea(

          child: Container(
            padding: const EdgeInsets.all(8),

            child: Column(
              children: <Widget>[

                //ListView faz uma unica requisição mas não monitora os dados mudados
                //listView,
                stream,
                caixaMensagem,

              ],),),
        ),),
    );
  }
}
