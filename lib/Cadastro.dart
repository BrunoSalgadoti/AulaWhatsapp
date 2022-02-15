import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/RouteGenerator.dart';
import 'package:whatsapp/model/Usuario.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  //Controles
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";


  _validarCampos (){

    //Recuperar dados dos campos
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if( nome.isNotEmpty && nome.length > 3 ){

      if( email.isNotEmpty && email.contains("@")){

        if( senha.isNotEmpty && senha.length > 6 ){

          if( nome.isNotEmpty && nome.length > 3 &&
              email.isNotEmpty && email.contains("@") &&
              senha.isNotEmpty && senha.length > 5) {

            setState(() {
              _mensagemErro = "";
            });
            //model/usuario
            Usuario usuario = Usuario();
            usuario.nome = nome;
            usuario.senha = senha;
            usuario.email = email;

            _cadastrarUsuario( usuario );
          }
        }else{
          setState(() {
            _mensagemErro = "Senha deve conter no mínimo 6 caracteres";
          });
        }
      }else{
        setState(() {
          _mensagemErro = "Preencha com um email válido";
        });
      }
    }else{
      setState(() {
        _mensagemErro = "Preencha o Nome e maior que 3 caracteres";
      });
    }
  }

  _cadastrarUsuario( Usuario usuario ) async{

    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.createUserWithEmailAndPassword(
        email:usuario.email,
        password: usuario.senha
    ).then( ( dynamic User ){

//-----------------------Salvar dados do usuário--------------------------------
      FirebaseFirestore db = FirebaseFirestore.instance;

      dynamic uid = auth.currentUser?.uid;

        db.collection( "usuarios" )
        .doc( uid.toString() )
        .set( usuario.toMap());

//------------------------------------------------------------------------------

      //remove rota anterior não deixa aparecer na nova rota o botão voltar neste comando
      Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.ROTA_HOME, (_) => false);

/*
      Navigator.pushReplacement(//Replacement desabilita botão de voltar no Appbar
         context,
         MaterialPageRoute(
             builder: ( context ) => Home()
         )
     );
*/

    }).catchError((erro) {
      print("erro " + erro.toString());
      setState(() {
        _mensagemErro = "Erro ao cadastrar o Usuário, \n verifique os Campos e tente novamente";
      });

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Cadastro"),
      ),

      body: Container(
        padding: EdgeInsets.all(16),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children:<Widget> [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),

                  child: Image.asset("imagens/usuario.png",
                    width: 200,
                    height: 150,
                  ),),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),

                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                  child: TextField(
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),

                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-Mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                  child: TextField(
                    controller: _controllerSenha,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),

                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Senha",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),

                Padding(padding: EdgeInsets.only(top: 16, bottom: 10),

                  child: ElevatedButton(
                    onPressed: () {
                      _validarCampos();

                    },
                    child: Text(
                      "Cadastrar",
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
                Center(
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20
                    ),
                  ),
                )

              ],),
          ),
        ),),
    );

  }
}
