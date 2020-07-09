import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePin extends StatefulWidget {
  @override
  _ChangePinState createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  TextEditingController oldPin = TextEditingController();
  TextEditingController newPin = TextEditingController();
  TextEditingController confirmPin = TextEditingController();

  Future<bool> success;
  bool waiting=false;

  Future<bool> postNewPin(int oldPin, int newPin) async{
    waiting=true;
    Map<String,dynamic> map ={
      'type':'change',
      'name':currentUser,
      'pin':oldPin,
      'new_pin':newPin
    };

    String encoded = jsonEncode(map);

    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/validate/', body: encoded);

    Map<String,dynamic> decoded = jsonDecode(response.body);

    return (response.statusCode==200 && decoded['valid']);

  }

  @override
  Widget build(BuildContext context) {
    return Card(
      
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(child: Text('Pin megváltoztatása', style: Theme.of(context).textTheme.title,)),
            SizedBox(height: 10,),
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                child: Text('Mi a mostani pined?', style: Theme.of(context).textTheme.button,)
            ),
            TextField(
              controller: oldPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 20,),
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                child: Text('Mi legyen az új pined?', style: Theme.of(context).textTheme.button,)
            ),
            TextField(
              controller: newPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 20,),
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                child: Text('Még egyszer', style: Theme.of(context).textTheme.button,)
            ),
            TextField(
              controller: confirmPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 30,),
            Center(
              child: RaisedButton.icon(
                color: Theme.of(context).colorScheme.secondary,
                label: Text('Küldés', style: Theme.of(context).textTheme.button),
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  success=null;
                  if(confirmPin.text==newPin.text){
                    if(await postNewPin(int.parse(oldPin.text), int.parse(newPin.text))){
                      Widget toast = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Colors.green,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check),
                            SizedBox(
                              width: 12.0,
                            ),
                            Flexible(child: Text("A pint sikeresen megváltoztattuk!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                          ],
                        ),
                      );
                      FlutterToast ft = FlutterToast(context);
                      ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                    }else{
                      Widget toast = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Colors.red,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear),
                            SizedBox(
                              width: 12.0,
                            ),
                            Flexible(child: Text("A pin megváltoztatása sikertelen volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                          ],
                        ),
                      );
                      FlutterToast ft = FlutterToast(context);
                      ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                    }
                  }else{
                    Widget toast = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.red,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, color: Colors.white,),
                          SizedBox(
                            width: 12.0,
                          ),
                          Flexible(child: Text("A két megadott pin nem egyezik!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                        ],
                      ),
                    );
                    FlutterToast ft = FlutterToast(context);
                    ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
