import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';

class SoapServiceLogin {

  final url ='http://localhost:2376/app?xsd=1/login';

  Future<String> login(String email, String password) async {
     // Reemplaza con la acción SOAP correcta si es diferente
    final methodName = 'login';

    final soapHeaders = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': "http://soap/Service/loginResponse",
    };

    final envelope = '''
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="$url">
        <soapenv:Header/>
        <soapenv:Body>
          <$methodName>
            <email>$email</email>
            <password>$password</password>
          </$methodName>
        </soapenv:Body>
      </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(url),
      headers: soapHeaders,
      body: envelope,
    );

    if (response.statusCode == 202) {
      final responseBody = response.body;
      final document = xml.XmlDocument.parse(responseBody);
      final body = document.rootElement.findElements('Body').first;

      // Encuentra el elemento que contiene el token JWT
      final tokenElement = body.findElements('token').first;

      // Extrae el valor del token JWT
      final token = tokenElement.toString();

      return token;
    } else {
      // Handle error response
      throw Exception('Error en la solicitud SOAP: ${response.statusCode}');
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String loginResult = '';

  final soapService = SoapServiceLogin();

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final result = await soapService.login(email, password);

      setState(() {
        loginResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login SOAP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar sesión'),
            ),
            SizedBox(height: 20),
            Text('Resultado de inicio de sesión:'),
            Text(loginResult),
          ],
        ),
      ),
    );
  }
}
