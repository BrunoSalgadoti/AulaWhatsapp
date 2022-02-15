import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {

  dynamic _idRemetente;
  dynamic _idDestinatario;
  dynamic _nome;
  dynamic _mensagem;
  dynamic _caminhoFoto;
  dynamic _tipoMensagem; //Define se é do tipo TEXTO ou IMAGEM

  Conversa();

  Future<dynamic> salvar ( ) async{

    FirebaseFirestore db = FirebaseFirestore.instance;

    await db.collection("conversas")
    .doc( this._idRemetente)
    .collection( "ultima_conversa")
    .doc( this._idDestinatario)
    .set( this.toMap() );
  }

  toMap() {

    Map<String, dynamic>  map ={
      "idRemetente"    : this.idRemetente,
      "idDestinatario" : this.idDestinatario,
      "nome"           : this.nome,
      "mensagem"       : this.mensagem,
      "caminhoFoto"    : this.caminhoFoto,
      "tipoMensagem"   : this.tipoMensagem,
    };

    return map;

  }



  dynamic get idRemetente => _idRemetente;

  set idRemetente(dynamic value) {
    _idRemetente = value;
  }

  dynamic get caminhoFoto => _caminhoFoto;

  set caminhoFoto(dynamic value) {
    _caminhoFoto = value;
  }

  dynamic get mensagem => _mensagem;

  set mensagem(dynamic value) {
    _mensagem = value;
  }

  dynamic get nome => _nome;

  set nome(dynamic value) {
    _nome = value;
  }

  dynamic get idDestinatario => _idDestinatario;

  set idDestinatario(dynamic value) {
    _idDestinatario = value;
  }

  dynamic get tipoMensagem => _tipoMensagem;

  set tipoMensagem(dynamic value) {
    _tipoMensagem = value;
  }
}