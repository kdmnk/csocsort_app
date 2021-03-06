import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class ChangePin extends StatefulWidget {
  @override
  _ChangePinState createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  TextEditingController oldPinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();
  TextEditingController confirmPinController = TextEditingController();


  Future<bool> postNewPin(int oldPin, int newPin) async{
    try{

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
    }catch(_){
      throw 'Hiba';
    }
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
            Row(
              children: <Widget>[
                Text('Jelenlegi PIN kód', style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 15,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '1234',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,\\.-]'))],
                    controller: oldPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('Új PIN kód', style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 15,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '5678',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,\\.-]'))],
                    controller: newPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('Új PIN kód megerősítése', style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 15,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '5678',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,\\.-]'))],
                    controller: confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            Center(
              child: RaisedButton.icon(
                color: Theme.of(context).colorScheme.secondary,
                label: Text('Küldés', style: Theme.of(context).textTheme.button),
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if(confirmPinController.text==newPinController.text){
                    Future<bool> success = postNewPin(int.parse(oldPinController.text), int.parse(newPinController.text));
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        child: Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: FutureBuilder(
                            future: success,
                            builder: (context, snapshot){
                              if(snapshot.connectionState==ConnectionState.done){
                                if(snapshot.hasData && snapshot.data){
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(child: Text("A pin megváltoztatása sikeres volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                      SizedBox(height: 15,),
                                      FlatButton.icon(
                                        icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        label: Text('Rendben', style: Theme.of(context).textTheme.button,),
                                        color: Theme.of(context).colorScheme.secondary,
                                      )
                                    ],
                                  );
                                }else{
                                  return Container(
                                    color: Colors.transparent ,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                        SizedBox(height: 15,),
                                        FlatButton.icon(
                                          icon: Icon(Icons.clear, color: Colors.white,),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
                                          color: Colors.red,
                                        )
                                      ],
                                    ),
                                  );
                                }
                              }
                              return Center(child: CircularProgressIndicator());

                            },
                          ),
                        )
                    );
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
