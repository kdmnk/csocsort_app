import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'balances.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String dropdownValue;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<String>> names;

  Future<List<String>> getNames() async {
    try{
      http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/names');
      Map<String, dynamic> response2 = jsonDecode(response.body);

      List<String> list = response2['names'].cast<String>();
      list.remove(currentUser);
//    list.insert(0, 'Válaszd ki a személyt!');
//    dropdownValue=list[0];
      return list;
    }catch(_){
      throw "Valami baj van getNames";
    }

  }

  Future<bool> postPayment(int amount, String note, String toName) async {
    try{
      Map<String,dynamic> map = {
        'type':'payment',
        'from_name':currentUser,
        'to_name':toName,
        'amount':amount,
        'note':note
      };
      String encoded = json.encode(map);

      http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

      return response.statusCode==200;
    }catch(_){
      throw "Valami baj van postPayment";
    }


  }

  @override
  void initState() {
    super.initState();
    names=getNames();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Fizetés'),),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: (){
          FocusScope.of(context).unfocus();
          if(dropdownValue==null){
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
                  Flexible(child: Text("Nem választottál személyt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                ],
              ),
            );
            FlutterToast ft = FlutterToast(context);
            ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
            return;
          }
          int amount = int.parse(amountController.text);
          String note = noteController.text;
          Future<bool> success = postPayment(amount, note, dropdownValue);
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
                      if(snapshot.hasData){
                        if(snapshot.data){
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: Text("A tranzakciót sikeresen könyveltük!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                onPressed: (){
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                label: Text('Rendben', style: Theme.of(context).textTheme.button,),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              FlatButton.icon(
                                icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
                                onPressed: (){
                                  amountController.text='';
                                  noteController.text='';
                                  dropdownValue=null;
                                  Navigator.pop(context);
                                },
                                label: Text('Új hozzáadása', style: Theme.of(context).textTheme.button,),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
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
                    }else{
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
          );

        },
      ),
      body:
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Row(
                      children: <Widget>[
                        Text('Összeg', style: Theme.of(context).textTheme.body2,),
                        SizedBox(width: 20,),
                        Flexible(
                          child: TextField(
                            controller: amountController,
                            decoration: InputDecoration(
                              hintText: 'Ft',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                //  when the TextFormField in unfocused
                              ) ,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                              ) ,

                            ),
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,-]'))],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Text('Megjegyzés', style: Theme.of(context).textTheme.body2,),
                        SizedBox(width: 20,),
                        Flexible(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Mamut',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                //  when the TextFormField in unfocused
                              ) ,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                              ) ,

                            ),
                            controller: noteController,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Divider(),
                    Center(
                      child: FutureBuilder(
                        future: names,
                        builder: (context, snapshot) {
                          if(snapshot.connectionState==ConnectionState.done) {
                            if (snapshot.hasData) {
                              return Wrap(
                                spacing: 10,
                                children: snapshot.data.map<ChoiceChip>((String name)=>
                                    ChoiceChip(
                                      label: Text(name),
                                      pressElevation: 30,
                                      selected: dropdownValue==name,
                                      onSelected: (bool newValue){
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          dropdownValue=name;
                                        });
                                      },
                                      labelStyle: dropdownValue==name
                                          ?Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).colorScheme.onSecondary)
                                          :Theme.of(context).textTheme.body2,
                                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                                      selectedColor: Theme.of(context).colorScheme.secondary,
                                    )
                                ).toList(),
                              );
                            }
                            else{

                              return InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(snapshot.error.toString()),
                                  ),
                                  onTap: (){
                                    setState(() {
                                    });
                                  }
                              );
                            }
                          }

                          return Center(child: CircularProgressIndicator());

                        },
                      ),
                    ),

                  ],
                ),
              ),
//              Balances()
            ],
          ),
        )

    );
  }
}
