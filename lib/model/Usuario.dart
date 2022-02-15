import 'dart:core';

class Usuario {

  dynamic _idUsuario;
  dynamic _nome;
  dynamic _email;
  dynamic _senha;
  dynamic _urlImagem;

  Usuario();

   toMap() {

      Map<String, dynamic>  map ={
      "nome"  : this.nome,
      "email" : this.email
    };
      return map;
  }


  dynamic get idUsuario => _idUsuario;

  set idUsuario(dynamic value) {
    _idUsuario = value;
  }

  dynamic get urlImagem => _urlImagem;

  set urlImagem(dynamic value) {
    _urlImagem = value;
  }

  dynamic get senha => _senha;

  set senha(dynamic value) {
    _senha = value;
  }

  dynamic get email => _email;

  set email(dynamic value) {
    _email = value;
  }

  dynamic get nome => _nome;

  set nome(dynamic value) {
    _nome = value;
  }
}