import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'shopping.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'dart:math';

List<String> placeholder = ["Mamut", "Sarki kisbolt", "Fapuma", "Eltört kiskanál", "Irtó büdös szúnyogirtó", "Borravaló a pizzásnak", "Buszjegy", "COO HD Piros Multivit 100% 1L",
"Egy tökéletes kakaóscsiga", "Sajt sajttal", "Gyíkhúsos melegszendvics", "56 alma", "Csigaszerű játékizé", "10 batka", "Egész napos kirándulás", "Paradicsomos kenyér",
"Kőrözöttes-szardíniás szendvics", "Menő napszemcsi", "Sokadik halálcsillag", "Draco Raphus Cuculatus", "Üres doboz", "Büdös zokni", "Nyikorgó szekér", "Emelt díjas SMS",
"Teve, sok teve", "Helytartó", "Balatoni jacht", "Kacsajelmez", "Légycsapó", "Pisztáciás fagylalt", "Csocsó", "Egy működő app", "Lekváros couscous", "Nagy bevásárlás"];
Random random = Random();

class SavedExpense{
  String name, note;
  List<String> names;
  int amount;
  int iD;
  SavedExpense({this.name, this.names, this.amount, this.note, this.iD});
}

enum ExpenseType{
  fromShopping, fromSavedExpense, newExpense
}

class NewExpense extends StatefulWidget {
  final ExpenseType type;
  final SavedExpense expense;
  final ShoppingData shoppingData;
  NewExpense({@required this.type, this.expense, this.shoppingData});
  @override
  _NewExpenseState createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<String>> names;
  Future<bool> success;
  Map<String,bool> checkboxBool = Map<String,bool>();
  FocusNode _focusNode = FocusNode();


  Future<List<String>> getNames() async {
    http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/names');
    Map<String, dynamic> response2 = jsonDecode(response.body);

    List<String> list = response2['names'].cast<String>();
    return list;

  }

  Future<bool> _deleteExpense(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "Transaction_Id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    return response.statusCode==200;
  }
  Future<bool> _fulfillShopping(int id) async {
    Map<String, dynamic> map = {
      "type":'fulfill',
      "fulfilled_by":currentUser,
      "id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/list/', body: encoded);

    return response.statusCode==200;
  }

  Future<bool> postNewExpense(List<String> names, int amount, String note) async{
    try{
      Map<String, dynamic> map = {
        "type":"new_expense",
        "from_name":currentUser,
        "to_names":names,
        "amount":amount,
        "note":note
      };

      String encoded = json.encode(map);

      http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

      return response.statusCode==200;
    }catch(Exception){
      return false;
    }


  }

  void setInitialValues(){
    if(widget.type==ExpenseType.fromSavedExpense){
      noteController.text = widget.expense.note;
      amountController.text=widget.expense.amount.toString();
    }else{
      noteController.text=widget.shoppingData.quantity+' '+widget.shoppingData.item;
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.type==ExpenseType.fromSavedExpense || widget.type==ExpenseType.fromShopping){
      setInitialValues();
    }
    names = getNames();
    
    _focusNode.addListener((){
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bevásárlás')),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Végösszeg', style: Theme.of(context).textTheme.body2,),
                            SizedBox(width: 20,),
                            Flexible(
                              child: TextField(
                                focusNode: _focusNode,
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
                                controller: amountController,
                                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                                cursorColor: Theme.of(context).colorScheme.secondary,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,=]'))],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: <Widget>[
                            Text('Megjegyzés', style: Theme.of(context).textTheme.body2,),
                            SizedBox(width: 15,),
                            Flexible(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: placeholder[random.nextInt(placeholder.length)],
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
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
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Divider(),
                  Center(
                    child: FutureBuilder(
                      future: names,
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          for(String name in snapshot.data){
                            checkboxBool.putIfAbsent(name, () => false);
                          }
                          if(widget.type==ExpenseType.fromSavedExpense && widget.expense.names!=null){
                            for(String name in widget.expense.names){
                              checkboxBool[name]=true;
                            }
                            widget.expense.names=null;
                          }else if(widget.type==ExpenseType.fromShopping){
                            checkboxBool[widget.shoppingData.user]=true;
                          }
                          return Wrap(
                            spacing: 10,
                            children: snapshot.data.map<ChoiceChip>((String name)=>
                                ChoiceChip(
                                  label: Text(name),
                                  pressElevation: 30,
                                  selected: checkboxBool[name],
                                  onSelected: (bool newValue){
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      checkboxBool[name]=newValue;
                                    });
                                  },
                                  labelStyle: checkboxBool[name]
                                      ?Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).colorScheme.onSecondary)
                                      :Theme.of(context).textTheme.body2,
                                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                                  selectedColor: Theme.of(context).colorScheme.secondary,
                                )
                            ).toList(),
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Material(
                          type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
                              onTap: (){
                                FocusScope.of(context).unfocus();
                                for(String name in checkboxBool.keys){
                                  checkboxBool[name]=!checkboxBool[name];
                                }
                                setState(() {

                                });
                              },
                              child: Padding(
                                padding:EdgeInsets.all(10.0),
                                child: Icon(
                                    Icons.swap_horiz, color: Theme.of(context).colorScheme.secondary
                                ),
                              ),
                            ),
                          )
                      ),
//                            OutlineButton.icon(
//                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
//                              shape: RoundedRectangleBorder(
//                                borderRadius: BorderRadius.circular(30)
//                              ),
//                              label: Text('Inverz kijelölés', style: Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).colorScheme.secondary)),
//                              icon: Icon(Icons.check_box, color: Theme.of(context).colorScheme.secondary),
//                              onPressed: (){
//                                FocusScope.of(context).unfocus();
//                                for(String name in checkboxBool.keys){
//                                  checkboxBool[name]=!checkboxBool[name];
//                                }
//                                setState(() {
//
//                                });
//                              },
//                            ),

                      Flexible(
                        child: GestureDetector(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              amountController.text!='' && checkboxBool.values.where((element)=>element==true).toList().length>0?
                              (double.parse(amountController.text)/checkboxBool.values.where((element)=>element==true).toList().length).toStringAsFixed(2)+' Ft/fő':
                              '',
                              style: Theme.of(context).textTheme.body1,

                            ),
                          ),
                        ),
                      ),
                      Material(
                          type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
                              onTap: (){
                                FocusScope.of(context).unfocus();
                                for(String name in checkboxBool.keys){
                                  checkboxBool[name]=false;
                                }
                                setState(() {

                                });
                              },
                              child: Padding(
                                padding:EdgeInsets.all(10.0),
                                child: Icon(
                                    Icons.clear, color: Colors.red
                                ),
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
//            Balances()
          ],

        ),
      ),
      floatingActionButton: FloatingActionButton(
      child: Icon(Icons.send),
      onPressed: (){
        FocusScope.of(context).unfocus();
        //TODO: round will not be needed
        //TODO:validator everywhere
        if(amountController.text==''){
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
                Flexible(child: Text("Nem adtál meg összeget", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
              ],
            ),
          );
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          return;
        }
        if(!checkboxBool.containsValue(true)){
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
                Flexible(child: Text("Nem választottál ki senkit!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
              ],
            ),
          );
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          return;
        }

        int amount = double.parse(amountController.text).round();
        if(amount<0){

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
                Flexible(child: Text("A végösszeg nem lehet negatív!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
              ],
            ),
          );
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          return;
        }
        String note = noteController.text;
        List<String> names = new List<String>();
        checkboxBool.forEach((String key, bool value) {
          if(value) names.add(key);
        });
        Function f;
        var param;
        if(widget.type==ExpenseType.fromSavedExpense){
          f=_deleteExpense;
          param=widget.expense.iD;
        }else if(widget.type==ExpenseType.fromShopping){
          f=_fulfillShopping;
          param=widget.shoppingData.shoppingId;
        }else{
          f=(par){return true;};
          param=5;
        }
        f(param);
        Future<bool> success = postNewExpense(names, amount, note);
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
                              setState(() {
                                amountController.text='';
                                noteController.text='';
                                for(String key in checkboxBool.keys){
                                  checkboxBool[key]=false;
                                }
                              });
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
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            )
        );
      },
    ),
    );
  }
}
