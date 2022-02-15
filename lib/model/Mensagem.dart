

class Mensagem {

  dynamic _idUsuario;
  dynamic _mensagem;
  dynamic _urlImagem;

  //Define o tipo da mensagem se é uma imagem ou um texto
  dynamic _tipo;
  dynamic _data;


  Mensagem();

  toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "mensagem" : this.mensagem,
      "urlImagem": this.urlImagem,
      "tipo"     : this.tipo,
      "data"     : this.data
    };
    return map;
  }


  dynamic get data => _data;

  set data(dynamic value) {
    _data = value;
  }

  dynamic get tipo => _tipo;

  set tipo(dynamic value) {
    _tipo = value;
  }

  dynamic get urlImagem => _urlImagem;

  set urlImagem(dynamic value) {
    _urlImagem = value;
  }

  dynamic get mensagem => _mensagem;

  set mensagem(dynamic value) {
    _mensagem = value;
  }

  dynamic get idUsuario => _idUsuario;

  set idUsuario(dynamic value) {
    _idUsuario = value;
  }
}