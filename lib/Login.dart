import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/model/RouteGenerator.dart';
import 'package:whatsapp/model/Usuario.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //controladores login
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampos (){

    //Recuperar dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if( email.isNotEmpty && email.contains("@") ){

      if( senha.isNotEmpty ){

        setState(() {
          _mensagemErro = "";
        });

        //model/usuario
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);

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
  }

 Future<dynamic> _logarUsuario ( Usuario usuario ) async{

    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then(( dynamic User){

      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);

    }).catchError((erro){

      setState(() {
        _mensagemErro = "Erro ao autenticar o usuário, \n verifique e-mail e senha e tente novamente";
      });
    });
  }

  Future<dynamic> _verificaUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut(); //Teste para deslogar usuario toda as vezes que reiniciar o app

    User? usuarioLogado = await auth.currentUser;

//De     Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
//   finindo a rota (arquivo de config. em model RouteGenerator)
    if ( usuarioLogado != null ){
      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
   }
  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(
        padding: EdgeInsets.all(16),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children:<Widget> [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),

                  child: Image.asset("imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
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
                      "Entrar",
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
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? cadastre-se!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17
                      ),),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ( context ) => Cadastro()
                          )
                      );
                    },
                  ) ,),
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _mensagemErro,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20
                        ),
                      ),)
                )
              ],),
          ),
        ),),
    );

  }
}
